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

    func test_createsViewData() throws {
        XCTAssertEqual(sut.connections.count, 0)

        mockHttpConnectionRepository.connectionsSubject.send([
            .fake(), .fake(response: nil), .fake()
        ])

        XCTAssertEqual(sut.connections.count, 3)
        let firstConnection = try XCTUnwrap(sut.connections.first)
        XCTAssertEqual(firstConnection.requestDate, "1970-01-01 00:00:00 +0000")
        XCTAssertEqual(firstConnection.requestMethod, "GET")
        XCTAssertEqual(firstConnection.requestURL, "http://fake.abc?a=1,b=2,c=3")
        XCTAssertEqual(firstConnection.responseStatusCode, "200")
        XCTAssertEqual(firstConnection.status, .success)
    }
}
