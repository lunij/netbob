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

        if let body = httpBodyStream?.data {
            command.append("-d \u{22}\(body.string)\u{22}")
        }

        return command.joined(separator: " ")
    }
}

extension URLRequest.CachePolicy {
    var string: String {
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
