//
//  Copyright © Marc Schultz. All rights reserved.
//

import XCTest
@testable import Netbob

// swiftlint:disable implicitly_unwrapped_optional

class ListViewStateTests: XCTestCase {
    let mockHttpConnectionRepository = HTTPConnectionRepositoryMock()

    var sut: ListViewState!

    override func setUp() {
        super.setUp()

        sut = ListViewState(
            httpConnectionRepository: mockHttpConnectionRepository,
            scheduler: .test
        )
    }

    func test_no_subscription_without_onAppear() {
        XCTAssertEqual(sut.connections.count, 0)
        mockHttpConnectionRepository.connectionSubject.send(.fake())
        XCTAssertEqual(sut.connections.count, 0)

    }

    func test_createsViewData() throws {
        guard let gmt = TimeZone(secondsFromGMT: 0) else {
            XCTFail("GMT could not be initialized")
            return
        }
        TimeZoneProvider.shared.current = gmt

        sut.onAppear()

        mockHttpConnectionRepository.connectionSubject.send(.fake())
        mockHttpConnectionRepository.connectionSubject.send(.fake(response: nil))
        mockHttpConnectionRepository.connectionSubject.send(.fake())

        XCTAssertEqual(sut.connections.count, 3)
        let firstConnection = try XCTUnwrap(sut.connections.first)
        XCTAssertEqual(firstConnection.requestTime, "00:00:00.000")
        XCTAssertEqual(firstConnection.requestMethod, "GET")
        XCTAssertEqual(firstConnection.requestScheme, "http://")
        XCTAssertEqual(firstConnection.requestHost, "fake.abc")
        XCTAssertEqual(firstConnection.requestPath, "/fake/path")
        XCTAssertEqual(firstConnection.requestQuery, "?a=1,b=2,c=3")
        XCTAssertEqual(firstConnection.responseStatusCode, "200")
        XCTAssertEqual(firstConnection.status, .success)
    }

    func test_no_subscription_after_onDisappear() {
        XCTAssertEqual(sut.connections.count, 0)

        sut.onAppear()
        mockHttpConnectionRepository.connectionSubject.send(.fake())

        XCTAssertEqual(sut.connections.count, 1)

        sut.onDisappear()
        mockHttpConnectionRepository.connectionSubject.send(.fake())

        XCTAssertEqual(sut.connections.count, 0)
    }
}
