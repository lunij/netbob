//
//  Copyright © Marc Schultz. All rights reserved.
//

import Combine
import XCTest
@testable import Netbob

class InfoViewStateTests: XCTestCase {
    private let mockHttpConnectionRepository = HTTPConnectionRepositoryMock()
    private let mockNetworkInterfaceMonitor = NetworkInterfaceMonitorMock()

    var sut: InfoViewState!

    override func setUp() {
        super.setUp()

        sut = InfoViewState(
            httpConnectionRepository: mockHttpConnectionRepository,
            networkInterfaceMonitor: mockNetworkInterfaceMonitor,
            scheduler: .test
        )
    }

    func test_createsViewData_whenConnectionsUnavailable() {
        XCTAssertEqual(sut.interfaceViewData, [])
        XCTAssertEqual(sut.summaryViewData.requestCount, "0")
        XCTAssertEqual(sut.summaryViewData.failedRequests, "0")
        XCTAssertEqual(sut.summaryViewData.successfulRequests, "0")
        XCTAssertEqual(sut.summaryViewData.averageRequestBodySize, "-")
        XCTAssertEqual(sut.summaryViewData.averageResponseBodySize, "-")
        XCTAssertEqual(sut.summaryViewData.averageResponseTime, "-")
        XCTAssertEqual(sut.summaryViewData.fastestResponseTime, "-")
        XCTAssertEqual(sut.summaryViewData.slowestResponseTime, "-")
        XCTAssertEqual(sut.summaryViewData.totalRequestBodySize, "-")
        XCTAssertEqual(sut.summaryViewData.totalResponseBodySize, "-")
    }

    func test_no_subscription_without_onAppear() {
        mockHttpConnectionRepository.connectionSubject.send(.fake())
        XCTAssertEqual(sut.summaryViewData.requestCount, "0")
    }

    func test_createsViewData_whenConnectionsWithoutResponses() {
        mockHttpConnectionRepository.current = [
            .fake(response: nil),
            .fake(response: nil),
            .fake(response: nil)
        ]
        sut.onAppear()

        mockHttpConnectionRepository.connectionSubject.send(.fake())

        XCTAssertEqual(sut.interfaceViewData, [])
        XCTAssertEqual(sut.summaryViewData.requestCount, "3")
        XCTAssertEqual(sut.summaryViewData.failedRequests, "3")
        XCTAssertEqual(sut.summaryViewData.successfulRequests, "0")
        XCTAssertEqual(sut.summaryViewData.averageRequestBodySize, "500 bytes")
        XCTAssertEqual(sut.summaryViewData.averageResponseBodySize, "-")
        XCTAssertEqual(sut.summaryViewData.averageResponseTime, "-")
        XCTAssertEqual(sut.summaryViewData.fastestResponseTime, "-")
        XCTAssertEqual(sut.summaryViewData.slowestResponseTime, "-")
        XCTAssertEqual(sut.summaryViewData.totalRequestBodySize, "1.5 kilobytes")
        XCTAssertEqual(sut.summaryViewData.totalResponseBodySize, "-")
    }

    func test_createsViewData_whenConnectionsWithResponses() {
        mockHttpConnectionRepository.current = [.fake(), .fake(), .fake()]
        sut.onAppear()

        mockHttpConnectionRepository.connectionSubject.send(.fake())

        XCTAssertEqual(sut.interfaceViewData, [])
        XCTAssertEqual(sut.summaryViewData.requestCount, "3")
        XCTAssertEqual(sut.summaryViewData.failedRequests, "0")
        XCTAssertEqual(sut.summaryViewData.successfulRequests, "3")
        XCTAssertEqual(sut.summaryViewData.averageRequestBodySize, "500 bytes")
        XCTAssertEqual(sut.summaryViewData.averageResponseBodySize, "500 bytes")
        XCTAssertEqual(sut.summaryViewData.averageResponseTime, "2 seconds")
        XCTAssertEqual(sut.summaryViewData.fastestResponseTime, "2 seconds")
        XCTAssertEqual(sut.summaryViewData.slowestResponseTime, "2 seconds")
        XCTAssertEqual(sut.summaryViewData.totalRequestBodySize, "1.5 kilobytes")
        XCTAssertEqual(sut.summaryViewData.totalResponseBodySize, "1.5 kilobytes")
    }

    func test_no_subscription_after_onDisappear() {
        mockHttpConnectionRepository.current = [.fake()]
        sut.onAppear()
        mockHttpConnectionRepository.connectionSubject.send(.fake())

        XCTAssertEqual(sut.summaryViewData.requestCount, "1")

        mockHttpConnectionRepository.current = [.fake(), .fake()]

        sut.onDisappear()
        mockHttpConnectionRepository.connectionSubject.send(.fake())

        XCTAssertEqual(sut.summaryViewData.requestCount, "1")
    }
}
