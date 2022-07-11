//
//  Copyright © Marc Schultz. All rights reserved.
//

import Combine
import XCTest
@testable import Netbob

// swiftlint:disable implicitly_unwrapped_optional

class HTTPConnectionRepositoryTests: XCTestCase {
    var mockDiskStorage: HTTPConnectionDiskStorageMock!

    var sut: HTTPConnectionRepository!

    private var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()

        mockDiskStorage = HTTPConnectionDiskStorageMock()

        sut = HTTPConnectionRepository(diskStorage: mockDiskStorage)
    }

    func test_adding() {
        var connection: HTTPConnection?

        sut.latestConnection.sink { connection = $0 }.store(in: &subscriptions)
        sut.store(.fake())

        XCTAssertEqual(connection, .fake())
    }

    func test_store_and_clearing() {
        // given
        mockDiskStorage.readReturnValue = [.fake(), .fake()]
        XCTAssertEqual(sut.current, [.fake(), .fake()])
        sut.store(.fake())
        sut.store(.fake())
        XCTAssertEqual(sut.current, [.fake(), .fake(), .fake(), .fake()])
        XCTAssertEqual(mockDiskStorage.calls, [.read, .store, .store])

        // when
        sut.clear()

        // then
        XCTAssertEqual(sut.current, [])
    }
}
