//
//  Copyright © Marc Schultz. All rights reserved.
//

import Foundation

struct HTTPRequest: Codable, Equatable {
    var body: Data?
    let cachePolicy: String
    let contentType: String?
    let curl: String
    let date: Date
    let headers: [String: String]
    let method: String?
    let timeoutInterval: TimeInterval
    let url: URL?
    let urlQueryItems: [URLQueryItem]

    init(
        from request: URLRequest,
        date: Date = Date()
    ) {
        self.date = date
        cachePolicy = request.cachePolicy.description
        contentType = request.allHTTPHeaderFields?["Content-Type"]
        curl = request.createCurl()
        headers = request.allHTTPHeaderFields ?? [:]
        method = request.httpMethod
        timeoutInterval = request.timeoutInterval
        url = request.url
        urlQueryItems = request.components?.queryItems ?? []
    }
}

struct HTTPResponse: Codable, Equatable {
    let body: Data?
    let contentType: HTTPContentType?
    let date: Date
    let headers: [String: String]
    let statusCode: Int?
    let error: String?

    init(
        from response: URLResponse? = nil,
        with body: Data? = nil,
        error: Error? = nil,
        date: Date = Date()
    ) {
        self.body = body
        self.date = date

        let httpUrlResponse = response as? HTTPURLResponse
        headers = httpUrlResponse?.allHeaderFields as? [String: String] ?? [:]
        statusCode = httpUrlResponse?.statusCode

        if let contentTypes = headers["Content-Type"] {
            let firstContentType = contentTypes.components(separatedBy: ";")[0]
            contentType = HTTPContentType(from: firstContentType)
        } else {
            contentType = nil
        }

        if let error = error {
            self.error = String(describing: error)
        } else {
            self.error = nil
        }
    }
}

enum HTTPContentType: Codable, CaseIterable {
    case json
    case xml
    case html
    case image
    case unknown

    init(from contentType: String) {
        switch contentType {
        case "application/json":
            self = .json; return
        case "application/xml", "text/xml":
            self = .xml; return
        case "text/html":
            self = .html; return
        default:
            break
        }

        if contentType.hasPrefix("image/") {
            self = .image
        } else {
            self = .unknown
        }
    }
}

class HTTPConnection: Codable, Equatable {
    private(set) var request: HTTPRequest
    private(set) var response: HTTPResponse?

    var timeInterval: TimeInterval? {
        response?.date.timeIntervalSince(request.date).absolute
    }

    var isSuccessful: Bool {
        guard let statusCode = response?.statusCode else { return false }
        return statusCode < 400
    }

    init(request: HTTPRequest) {
        self.request = request
    }

    func saveRequestBody(_ request: URLRequest) {
        self.request.body = request.httpBodyStream?.data
    }

    func store(response: HTTPResponse) {
        self.response = response
    }

    static func == (lhs: HTTPConnection, rhs: HTTPConnection) -> Bool {
        lhs.request == rhs.request && lhs.response == rhs.response
    }
}

extension URLQueryItem: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let value = try container.decodeIfPresent(String.self, forKey: .value)
        self.init(name: name, value: value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(value, forKey: .value)
    }

    enum CodingKeys: CodingKey {
        case name
        case value
    }
}

private extension URLResponse {
    var httpUrlResponse: HTTPURLResponse? {
        self as? HTTPURLResponse
    }
}

private extension TimeInterval {
    var absolute: Self {
        abs(self)
    }
}

extension HTTPConnection {
    func toString(includeBody: Bool) -> String {
        """
        \(infoString)

        \(requestString(includeBody))

        \(responseString(includeBody))
        """
    }

    private var infoString: String {
        var string = "## INFO\n"

        string += "[URL]\n\(request.url?.absoluteString ?? "-")\n\n"
        string += "[Method]\n\(request.method ?? "-")\n\n"

        if let statusCode = response?.statusCode {
            string += "[Status]\n\(statusCode)\n\n"
        }

        string += "[Request date]\n\(request.date)\n\n"

        if let response = response {
            string += "[Response date]\n\(response.date)\n\n"
        }

        if let timeInterval = timeInterval {
            string += "[Time interval]\n\(timeInterval)\n\n"
        }

        string += "[Timeout]\n\(request.timeoutInterval)\n\n"
        string += "[Cache policy]\n\(request.cachePolicy)"

        return string
    }

    private func requestString(_ includeBody: Bool) -> String {
        var string = "## REQUEST\n\n### Headers\n\n"

        if request.headers.count > 0 {
            for (key, value) in request.headers {
                string += "[\(key)]\n\(value)\n\n"
            }
        } else {
            string += "Request headers are empty\n\n"
        }

        guard includeBody else { return string }

        string += "### Body\n\n"

        if let body = request.body, let bodyString = body.prettyJson ?? String(data: body, encoding: .utf8) {
            string += bodyString
        } else if let body = request.body {
            string += String(describing: body)
        } else {
            string += "Request body is empty"
        }

        return string
    }

    private func responseString(_ includeBody: Bool) -> String {
        var string = "## RESPONSE\n\n"

        guard let response = response else {
            return string + "No response"
        }

        string += "### Headers\n\n"

        if response.headers.count > 0 {
            for (key, value) in response.headers {
                string += "[\(key)]\n\(value)\n\n"
            }
        } else {
            string += "Response headers are empty\n\n"
        }

        guard includeBody else { return string }

        string += "### Body\n\n"

        if let body = response.body, let bodyString = body.prettyJson ?? String(data: body, encoding: .utf8) {
            string += bodyString
        } else if let body = response.body {
            string += String(describing: body)
        } else {
            string += "Response body is empty"
        }

        return string
    }
}
