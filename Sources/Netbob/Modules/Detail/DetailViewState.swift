//
//  Copyright © Marc Schultz. All rights reserved.
//

import UIKit

protocol DetailViewStateDelegate: AnyObject {
    func presentBody(_ bodyString: String)
    func presentImageBody(_ bodyString: String)
}

class DetailViewState: ObservableObject {
    weak var delegate: DetailViewStateDelegate?

    @Published var actionSheetState: ActionSheetState?
    @Published var activityItem: ActivityItem?

    let viewData: ViewData

    init(connection: HTTPConnection) {
        viewData = ViewData(from: connection)
    }

    func handleShareAction() {
        var curlExportAction: ActionSheetState.Action?
        curlExportAction = ActionSheetState.Action.default(text: "Export request as curl") { [weak self, viewData] in
            self?.activityItem = ActivityItem(text: viewData.requestCurl, placeholder: "placeholder")
        }

        actionSheetState = .init(
            title: "Choose what to share",
            message: nil,
            actions: [
                .default(text: "Share without body") { [weak self, viewData] in
                    self?.activityItem = ActivityItem(text: viewData.toString(includeBody: false), placeholder: "placeholder")
                },
                .default(text: "Share with body") { [weak self, viewData] in
                    self?.activityItem = ActivityItem(text: viewData.toString(includeBody: true), placeholder: "placeholder")
                },
                curlExportAction,
                .cancel
            ].compactMap { $0 }
        )
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

        private let connection: HTTPConnection

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

        func toString(includeBody: Bool) -> String {
            connection.toString(includeBody: includeBody)
        }
    }
}

struct ActivityItem: ActivityItemProtocol, Identifiable {
    let text: String
    var placeholder: Any

    var id: String { text }

    func item(for _: UIActivity.ActivityType?) -> Any? {
        text
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
