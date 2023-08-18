//
//  Copyright © Marc Schultz. All rights reserved.
//

import Foundation
import UIKit
@testable import Netbob

extension HTTPConnection {
    static func fake(
        request: HTTPRequest = .fake(),
        response: HTTPResponse? = .fake()
    ) -> HTTPConnection {
        let connection = HTTPConnection(request: request)
        if let response = response {
            connection.store(response: response)
        }
        return connection
    }
}

extension HTTPRequest {
    static func fake(
        urlRequest: URLRequest = .fake(),
        body: Data? = .fake,
        date: Date = .init(timeIntervalSince1970: 0)
    ) -> Self {
        var request = HTTPRequest(from: urlRequest, date: date)
        request.body = body
        return request
    }
}

extension URLRequest {
    static func fake() -> URLRequest {
        .init(
            url: URL(string: "http://fake.abc/fake/path?a=1,b=2,c=3")!,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10
        )
    }
}

extension HTTPResponse {
    static func fake(
        httpUrlResponse: HTTPURLResponse = .fake(),
        body: Data? = .fake,
        date: Date = .init(timeIntervalSince1970: 2)
    ) -> HTTPResponse {
        .init(from: httpUrlResponse, with: body, error: nil, date: date)
    }
}

extension HTTPURLResponse {
    static func fake(statusCode: Int = 200) -> HTTPURLResponse {
        .init(
            url: URL(string: "http://fake.abc?a=1,b=2,c=3")!,
            statusCode: statusCode,
            httpVersion: "1337",
            headerFields: [
                "Content-Type": "application/json"
            ]
        )!
    }
}

extension Data {
    static var fake: Self {
        .init(repeating: 0, count: 500)
    }
}
