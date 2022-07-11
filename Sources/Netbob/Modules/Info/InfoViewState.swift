//
//  Copyright © Marc Schultz. All rights reserved.
//

import Combine
import Network
import SwiftUI

class InfoViewState: ObservableObject {
    @Published var summaryViewData = ConnectionSummaryViewData()
    @Published var interfaceViewData: [InterfaceViewData] = []

    private let httpConnectionRepository: HTTPConnectionRepositoryProtocol
    private let networkInterfaceMonitor: NetworkInterfaceMonitorProtocol

    private let scheduler: AnyScheduler<DispatchQueue>
    private var subscriptions = Set<AnyCancellable>()

    init(
        httpConnectionRepository: HTTPConnectionRepositoryProtocol = HTTPConnectionRepository.shared,
        networkInterfaceMonitor: NetworkInterfaceMonitorProtocol = NetworkInterfaceMonitor(),
        scheduler: AnyScheduler<DispatchQueue> = .main
    ) {
        self.httpConnectionRepository = httpConnectionRepository
        self.networkInterfaceMonitor = networkInterfaceMonitor
        self.scheduler = scheduler
    }

    func onAppear() {
        initViewData()
        configureSubscriptions()
    }

    func onDisappear() {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        interfaceViewData.removeAll()
    }

    // MARK: - Private

    private func initViewData() {
        createViewData(connections: httpConnectionRepository.current)
    }

    private func configureSubscriptions() {
        httpConnectionRepository
            .latestConnection
            .receive(on: scheduler)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.createViewData(connections: self.httpConnectionRepository.current)
            }
            .store(in: &subscriptions)

        networkInterfaceMonitor
            .interface
            .receive(on: scheduler)
            .sink { [weak self] interfaces in
                self?.createViewData(interfaces: interfaces)
            }
            .store(in: &subscriptions)
    }

    private func createViewData(connections: [HTTPConnection]) {
        let requestCount = connections.count
        var successfulRequests = 0
        var failedRequests = 0
        var totalRequestBodySize: Measurement<UnitInformationStorage>?
        var totalResponseBodySize: Measurement<UnitInformationStorage>?
        var totalResponseTime: Measurement<UnitDuration>?
        var fastestResponseTime: Measurement<UnitDuration>?
        var slowestResponseTime: Measurement<UnitDuration>?
        var averageRequestBodySize: Measurement<UnitInformationStorage>?
        var averageResponseBodySize: Measurement<UnitInformationStorage>?
        var averageResponseTime: Measurement<UnitDuration>?

        for connection in connections {
            if connection.isSuccessful {
                successfulRequests += 1
            } else {
                failedRequests += 1
            }

            if let requestBodySize = connection.request.body?.count {
                totalRequestBodySize = totalRequestBodySize ?? .init(value: 0, unit: .bytes)
                totalRequestBodySize?.value += Double(requestBodySize)
            }

            guard let response = connection.response, let timeInterval = connection.timeInterval else { continue }

            if let responseBodySize = response.body?.count {
                totalResponseBodySize = totalResponseBodySize ?? .init(value: 0, unit: .bytes)
                totalResponseBodySize?.value += Double(responseBodySize)
            }

            totalResponseTime = totalResponseTime ?? .init(value: 0, unit: .seconds)
            totalResponseTime?.value += timeInterval

            if timeInterval < fastestResponseTime?.value ?? .infinity {
                fastestResponseTime = fastestResponseTime ?? .init(value: .infinity, unit: .seconds)
                fastestResponseTime?.value = timeInterval
            }

            if timeInterval > slowestResponseTime?.value ?? 0 {
                slowestResponseTime = slowestResponseTime ?? .init(value: 0, unit: .seconds)
                slowestResponseTime?.value = timeInterval
            }
        }

        if let totalRequestBodySize = totalRequestBodySize {
            averageRequestBodySize = totalRequestBodySize / Double(requestCount)
        }

        if let totalResponseBodySize = totalResponseBodySize {
            averageResponseBodySize = totalResponseBodySize / Double(requestCount)
        }

        if let totalResponseTime = totalResponseTime {
            averageResponseTime = totalResponseTime / Double(requestCount)
        }

        summaryViewData = ConnectionSummaryViewData(
            requestCount: "\(requestCount)",
            successfulRequests: "\(successfulRequests)",
            failedRequests: "\(failedRequests)",
            totalRequestBodySize: totalRequestBodySize?.formatted ?? "-",
            averageRequestBodySize: averageRequestBodySize?.formatted ?? "-",
            totalResponseBodySize: totalResponseBodySize?.formatted ?? "-",
            averageResponseBodySize: averageResponseBodySize?.formatted ?? "-",
            averageResponseTime: averageResponseTime?.formatted ?? "-",
            fastestResponseTime: fastestResponseTime?.formatted ?? "-",
            slowestResponseTime: slowestResponseTime?.formatted ?? "-"
        )
    }

    private func createViewData(interfaces: [Interface]) {
        interfaceViewData = interfaces.map(InterfaceViewData.init)
    }

    struct InterfaceViewData: Identifiable, Equatable {
        let name: String
        let ipAddresses: String

        var id: String { name }

        init(_ interface: Interface) {
            name = interface.name + "/" + interface.type.rawValue
            ipAddresses = interface.ipAddresses.joined(separator: "\n")
        }
    }

    struct ConnectionSummaryViewData {
        let requestCount: String
        let successfulRequests: String
        let failedRequests: String
        let totalRequestBodySize: String
        let averageRequestBodySize: String
        let totalResponseBodySize: String
        let averageResponseBodySize: String
        let averageResponseTime: String
        let fastestResponseTime: String
        let slowestResponseTime: String

        init(
            requestCount: String = "0",
            successfulRequests: String = "0",
            failedRequests: String = "0",
            totalRequestBodySize: String = "-",
            averageRequestBodySize: String = "-",
            totalResponseBodySize: String = "-",
            averageResponseBodySize: String = "-",
            averageResponseTime: String = "-",
            fastestResponseTime: String = "-",
            slowestResponseTime: String = "-"
        ) {
            self.requestCount = requestCount
            self.successfulRequests = successfulRequests
            self.failedRequests = failedRequests
            self.totalRequestBodySize = totalRequestBodySize
            self.averageRequestBodySize = averageRequestBodySize
            self.totalResponseBodySize = totalResponseBodySize
            self.averageResponseBodySize = averageResponseBodySize
            self.averageResponseTime = averageResponseTime
            self.fastestResponseTime = fastestResponseTime
            self.slowestResponseTime = slowestResponseTime
        }
    }
}

private extension Measurement {
    var formatted: String {
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.numberStyle = .decimal
        formatter.unitOptions = .naturalScale
        formatter.unitStyle = .long
        return formatter.string(from: self)
    }
}
