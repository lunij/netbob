//
//  Copyright © Marc Schultz. All rights reserved.
//

import UIKit

class DetailViewState: ObservableObject {
    @Published var actionSheetState: ActionSheetState?
    @Published var activitySheetState: ActivitySheetState?

    let viewData: ViewData

    private let logFileProvider: LogFileProviderProtocol

    init(
        connection: HTTPConnection,
        logFileProvider: LogFileProviderProtocol = LogFileProvider()
    ) {
        viewData = ViewData(from: connection)
        self.logFileProvider = logFileProvider
    }

    func handleShareAction() {
        actionSheetState = .init(
            title: "Choose what to share",
            message: nil,
            actions: [
                .default(text: "Share without body") { [weak self] in
                    self?.shareSingleLog(includeBody: false)
                },
                .default(text: "Share with body") { [weak self] in
                    self?.shareSingleLog(includeBody: true)
                },
                .default(text: "Export request as curl") { [weak self, viewData] in
                    self?.activitySheetState = .init(items: [viewData.requestCurl])
                },
                .cancel
            ].compactMap { $0 }
        )
    }

    private func shareSingleLog(includeBody: Bool) {
        do {
            let logFileUrl = try logFileProvider.createSingleLog(from: viewData.connection, includeBody: includeBody)
            activitySheetState = .init(items: [logFileUrl])
        } catch {
            Netbob.log(String(describing: error))
        }
    }

    struct ViewData {
        let requestBody: Data?
        let requestCachePolicy: String
        let requestCurl: String
        let requestDate: String
        let requestHeaders: [Header]
        let requestMethod: String
        let requestTimeout: String
        let requestURL: String
        let requestURLQueryItems: [QueryItem]

        let responseBody: Data?
        let responseDate: String
        let responseHeaders: [Header]
        let responseStatus: String

        let timeInterval: String

        fileprivate let connection: HTTPConnection

        init(from connection: HTTPConnection) {
            self.connection = connection

            requestBody = connection.request.body
            requestCachePolicy = connection.request.cachePolicy
            requestCurl = connection.request.curl
            requestDate = connection.request.date.formatted
            requestMethod = connection.request.method ?? "-"
            requestTimeout = String(format: "%.1f s", connection.request.timeoutInterval)
            requestURL = connection.request.url?.absoluteString ?? "-"
            responseBody = connection.response?.body

            requestURLQueryItems = connection.request.urlQueryItems
                .map { QueryItem(key: $0.name, value: $0.value ?? "") }

            requestHeaders = connection.request.headers
                .map { key, value in Header(key: "\(key)", value: "\(value)") }
                .sorted(by: <)

            responseHeaders = (connection.response?.headers ?? [:])
                .map { key, value in Header(key: "\(key)", value: "\(value)") }
                .sorted(by: <)

            if let timeInterval = connection.timeInterval {
                self.timeInterval = "\(timeInterval)"
            } else {
                timeInterval = "-"
            }

            responseDate = connection.response?.date.formatted ?? "-"

            if let statusCode = connection.response?.statusCode {
                responseStatus = "\(statusCode)"
            } else {
                responseStatus = "-"
            }
        }
    }
}

struct Header: Identifiable, Comparable {
    let key: String
    let value: String

    var id: String { key }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.key < rhs.key
    }
}

struct QueryItem: Identifiable {
    let key: String
    let value: String

    var id: String { key }
}
