//
//  Copyright © Marc Schultz. All rights reserved.
//

import Combine
import Foundation

class ListViewStateAbstract: ObservableObject {
    @Published var connections: [HTTPConnectionViewData] = []
    @Published var activitySheetState: ActivitySheetState?
    func handleShareAction() {}
}

final class ListViewState: ListViewStateAbstract {
    private let httpConnectionRepository: HTTPConnectionRepositoryProtocol
    private let logFileProvider: LogFileProviderProtocol

    private let scheduler: AnyScheduler<DispatchQueue>
    private var subscriptions = Set<AnyCancellable>()

    init(
        httpConnectionRepository: HTTPConnectionRepositoryProtocol = HTTPConnectionRepository.shared,
        logFileProvider: LogFileProviderProtocol = LogFileProvider(),
        scheduler: AnyScheduler<DispatchQueue> = .main
    ) {
        self.httpConnectionRepository = httpConnectionRepository
        self.logFileProvider = logFileProvider
        self.scheduler = scheduler

        super.init()

        configureSubscriptions()
    }

    override func handleShareAction() {
        do {
            let logFileUrl = try logFileProvider.createFullLog()
            activitySheetState = ActivitySheetState(items: [logFileUrl])
        } catch {
            Netbob.log(String(describing: error))
        }
    }

    private func configureSubscriptions() {
        httpConnectionRepository
            .connections
            .receive(on: scheduler)
            .sink { [weak self] connections in
                self?.connections = connections.map(HTTPConnectionViewData.init)
            }
            .store(in: &subscriptions)
    }
}

struct HTTPConnectionViewData: Identifiable {
    let id = UUID()
    let requestTime: String
    let requestMethod: String
    let requestScheme: String
    let requestHost: String
    let requestPath: String
    let requestQuery: String
    let responseStatusCode: String
    let status: Status
    let isFromCurrentSession: Bool

    let connection: HTTPConnection

    enum Status {
        case success, failure, timeout
    }
}

extension HTTPConnectionViewData {
    init(_ connection: HTTPConnection) {
        if let scheme = connection.request.url?.scheme {
            requestScheme = "\(scheme)://"
        } else {
            requestScheme = ""
        }

        if let query = connection.request.url?.query {
            requestQuery = "?\(query)"
        } else {
            requestQuery = ""
        }

        requestTime = connection.request.date.formattedTime
        requestMethod = connection.request.method ?? "-"
        requestHost = connection.request.url?.host ?? ""
        requestPath = connection.request.url?.path ?? ""
        responseStatusCode = connection.response?.statusCode ?? ""
        status = connection.status
        isFromCurrentSession = connection.isFromCurrentSession
        self.connection = connection
    }
}

private func ?? (lhs: Int?, rhs: String) -> String {
    if let lhs = lhs {
        return String(lhs)
    }
    return rhs
}

private extension HTTPConnection {
    var status: HTTPConnectionViewData.Status {
        guard let statusCode = response?.statusCode else {
            return .timeout
        }
        if statusCode < 400 {
            return .success
        }
        return .failure
    }
}
