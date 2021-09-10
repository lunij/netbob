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
            requestURL = connection.request.url
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

        string += "[URL]\n\(request.url)\n\n"
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
        } else {
            string += "Response body is empty"
        }

        return string
    }
}
