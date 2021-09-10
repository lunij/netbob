//
//  Copyright © Marc Schultz. All rights reserved.
//

import Foundation

extension URLRequest {
    var components: URLComponents? {
        guard let url = url else {
            return nil
        }
        return URLComponents(string: url.absoluteString)
    }

    func createCurl() -> String {
        guard let url = url else { return "" }
        let baseCommand = "curl \(url.absoluteString)"

        var command = [baseCommand]

        if let method = httpMethod {
            command.append("-X \(method)")
        }

        for (key, value) in allHTTPHeaderFields ?? [:] {
            command.append("-H \u{22}\(key): \(value)\u{22}")
        }

        if let bodyData = httpBodyStream?.data, let body = String(data: bodyData, encoding: .utf8) {
            command.append("-d \u{22}\(body)\u{22}")
        }

        return command.joined(separator: " ")
    }
}

extension URLRequest.CachePolicy: CustomStringConvertible {
    public var description: String {
        switch self {
        case .useProtocolCachePolicy:
            return "UseProtocolCachePolicy"
        case .reloadIgnoringLocalCacheData:
            return "ReloadIgnoringLocalCacheData"
        case .reloadIgnoringLocalAndRemoteCacheData:
            return "ReloadIgnoringLocalAndRemoteCacheData"
        case .returnCacheDataElseLoad:
            return "ReturnCacheDataElseLoad"
        case .returnCacheDataDontLoad:
            return "ReturnCacheDataDontLoad"
        case .reloadRevalidatingCacheData:
            return "ReloadRevalidatingCacheData"
        @unknown default:
            return "Unknown \(self)"
        }
    }
}
