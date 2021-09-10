//
//  Copyright © Marc Schultz. All rights reserved.
//

import Foundation

class NetbobURLProtocol: URLProtocol {
    static let key = "\(NetbobURLProtocol.self)"

    private lazy var session: URLSession = { [unowned self] in
        URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()

    private var connection: HTTPConnection?
    private var response: URLResponse?
    private var responseBody: Data?

    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override public class func canInit(with request: URLRequest) -> Bool {
        return canServeRequest(request)
    }

    override public class func canInit(with task: URLSessionTask) -> Bool {
        guard let request = task.currentRequest else { return false }
        return canServeRequest(request)
    }

    private class func canServeRequest(_ request: URLRequest) -> Bool {
        guard
            !request.hasKey,
            let url = request.url,
            url.absoluteString.hasPrefix("http") || url.absoluteString.hasPrefix("https")
        else {
            return false
        }

        let isBlacklisted = Netbob.shared.blacklistedHosts.contains { url.absoluteString.hasPrefix($0) }

        return !isBlacklisted
    }

    override public func startLoading() {
        connection = HTTPConnection(request: HTTPRequest(from: request))

        session.dataTask(with: request.addKey()).resume()
    }

    override public func stopLoading() {
        session.invalidateAndCancel()
    }
}

extension NetbobURLProtocol: URLSessionDataDelegate {
    func urlSession(_: URLSession, dataTask _: URLSessionDataTask, didReceive data: Data) {
        responseBody?.append(data)

        client?.urlProtocol(self, didLoad: data)
    }

    public func urlSession(_: URLSession, dataTask _: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.response = response
        responseBody = Data()

        let policy = URLCache.StoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .notAllowed

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: policy)
        completionHandler(.allow)
    }

    public func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        defer {
            if let error = error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }
        }

        guard let request = task.originalRequest else { return }
        guard let connection = connection else { return }

        connection.saveRequestBody(request)

        if let error = error {
            connection.store(response: .init(error: error))
        } else if let response = response {
            connection.store(response: .init(from: response, with: responseBody))
        }

        HTTPConnectionRepository.shared.add(connection)
    }

    public func urlSession(_: URLSession, task _: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        let updatedRequest: URLRequest
        if request.hasKey {
            updatedRequest = request.removeKey()
        } else {
            updatedRequest = request
        }

        client?.urlProtocol(self, wasRedirectedTo: updatedRequest, redirectResponse: response)
        completionHandler(updatedRequest)
    }

    public func urlSession(_: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let wrappedChallenge = URLAuthenticationChallenge(authenticationChallenge: challenge, sender: AuthenticationChallengeSender(handler: completionHandler))
        client?.urlProtocol(self, didReceive: wrappedChallenge)
    }

    public func urlSessionDidFinishEvents(forBackgroundURLSession _: URLSession) {
        client?.urlProtocolDidFinishLoading(self)
    }
}

private extension URLRequest {
    var hasKey: Bool {
        URLProtocol.property(forKey: NetbobURLProtocol.key, in: self) != nil
    }

    func addKey() -> URLRequest {
        let mutableRequest = self as! NSMutableURLRequest // swiftlint:disable:this force_cast
        URLProtocol.setProperty(true, forKey: NetbobURLProtocol.key, in: mutableRequest)
        return mutableRequest as URLRequest
    }

    func removeKey() -> URLRequest {
        let mutableRequest = self as! NSMutableURLRequest // swiftlint:disable:this force_cast
        URLProtocol.removeProperty(forKey: NetbobURLProtocol.key, in: mutableRequest)
        return mutableRequest as URLRequest
    }
}
