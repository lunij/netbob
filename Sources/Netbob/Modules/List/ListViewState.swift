//
//  Copyright © Marc Schultz. All rights reserved.
//

import Combine
import Foundation

class ListViewStateAbstract: ObservableObject {
    @Published var connections: [HTTPConnectionViewData] = []
    @Published var activitySheetState: ActivitySheetState?
    @Published var searchText: String = ""

    func onAppear() {}
    func onDisappear() {}
    func handleShareAction() {}
    func handleSaveAction() {}
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
    }

    override func onAppear() {
        initViewData()
        configureSubscriptions()
    }

    override func onDisappear() {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        connections.removeAll()
    }

    override func handleShareAction() {
        do {
            let logFileUrl = try logFileProvider.createFullLog()
            activitySheetState = ActivitySheetState(items: [logFileUrl])
        } catch {
            Netbob.log(String(describing: error))
        }
    }

    override func handleSaveAction() {
        do {
            try logFileProvider.saveFullLog()
        } catch {
            Netbob.log(String(describing: error))
        }
    }

    // MARK: - Private

    private func initViewData() {
        connections = listOfConnections
    }

    private var listOfConnections: [HTTPConnectionViewData] {
        httpConnectionRepository.current
            .prefix(Netbob.shared.maxListItems ?? .max)
            .map(HTTPConnectionViewData.init)
    }

    private func configureSubscriptions() {
        httpConnectionRepository
            .latestConnection
            .map(HTTPConnectionViewData.init)
            .receive(on: scheduler)
            .sink { [weak self] connection in
                guard let self = self else { return }
                if self.searchText == "" || connection.requestUrl.contains(self.searchText.lowercased()) {
                    self.connections.insert(connection, at: 0)
                }
            }
            .store(in: &subscriptions)

        $searchText
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.searchText != "" {
                    self.connections = listOfConnections
                        .filter { $0.requestUrl.contains(self.searchText.lowercased()) }
                } else {
                    self.connections = listOfConnections
                }
            }
            .store(in: &subscriptions)
    }
}

private extension HTTPConnectionViewData {
    var requestUrl: String {
        requestHost + requestPath
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
