//
//  Copyright © Marc Schultz. All rights reserved.
//

import Foundation
import UIKit

protocol LogFileProviderProtocol {
    func createFullLog() throws -> URL
    func createSingleLog(from connection: HTTPConnection, includeBody: Bool) throws -> URL
}

class LogFileProvider: LogFileProviderProtocol {
    let fileManager: FileManagerProtocol
    let httpConnectionRepository: HTTPConnectionRepositoryProtocol

    private let writeAction: (String, URL) throws -> Void

    init(
        fileManager: FileManagerProtocol = FileManager.default,
        httpConnectionRepository: HTTPConnectionRepositoryProtocol = HTTPConnectionRepository.shared,
        writeAction: @escaping (String, URL) throws -> Void = defaultWriteAction
    ) {
        self.fileManager = fileManager
        self.httpConnectionRepository = httpConnectionRepository
        self.writeAction = writeAction
    }

    func createFullLog() throws -> URL {
        let fullLog = .logHeader +
            httpConnectionRepository
                .current
                .map { $0.toString(includeBody: true) }
                .joined(separator: "\n\n\n\(String(repeating: "-", count: 30))\n\n\n")
        let logFileUrl = fileManager.temporaryDirectory.appendingPathComponent("session.log")
        try writeAction(fullLog, logFileUrl)
        return logFileUrl
    }

    func createSingleLog(from connection: HTTPConnection, includeBody: Bool) throws -> URL {
        let string = .logHeader +
            connection.toString(includeBody: includeBody)

        let logFileUrl = fileManager.temporaryDirectory.appendingPathComponent("single-connection.log")
        try writeAction(string, logFileUrl)
        return logFileUrl
    }
}

private func defaultWriteAction(string: String, url: URL) throws {
    try string.write(to: url, atomically: true, encoding: .utf8)
}

private extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
}

private extension HTTPConnection {
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

        if let body = request.body {
            string += body.prettyJson ?? body.string
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

        if let body = response.body {
            string += body.prettyJson ?? body.string
        } else {
            string += "Response body is empty"
        }

        return string
    }
}

private extension String {
    static var logHeader: Self {
        let deviceModel = UIDevice.current.model
        let osVersion = UIDevice.current.systemVersion
        let appVersion = Bundle.main.appVersion

        return "Device: \(deviceModel)\n" +
            "OS Version: \(osVersion)\n" +
            "App Version: \(appVersion)\n\n"
    }
}
