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
        var connections: [HTTPConnection]?

        sut.connections.sink { connections = $0 }.store(in: &subscriptions)
        sut.store(.fake())

        XCTAssertEqual(connections, [.fake()])
    }

    func test_clearing() {
        // given
        var connections: [HTTPConnection]?
        sut.connections.sink { connections = $0 }.store(in: &subscriptions)
        sut.store(.fake())
        sut.store(.fake())
        XCTAssertEqual(connections, [.fake(), .fake()])

        // when
        sut.clear()

        // then
        XCTAssertEqual(connections, [])
    }
}
