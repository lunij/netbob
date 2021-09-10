//
//  Copyright © Marc Schultz. All rights reserved.
//

import Combine
import XCTest
@testable import Netbob

// swiftlint:disable implicitly_unwrapped_optional

class HTTPConnectionRepositoryTests: XCTestCase {
    var sut: HTTPConnectionRepository!

    private var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()

        sut = HTTPConnectionRepository()
    }

    func test_adding() {
        var connections: [HTTPConnection]?

        sut.connections.sink { connections = $0 }.store(in: &subscriptions)
        sut.add(.fake())

        XCTAssertEqual(connections, [.fake()])
    }

    func test_clearing() {
        // given
        var connections: [HTTPConnection]?
        sut.connections.sink { connections = $0 }.store(in: &subscriptions)
        sut.add(.fake())
        sut.add(.fake())
        XCTAssertEqual(connections, [.fake(), .fake()])

        // when
        sut.clear()

        // then
        XCTAssertEqual(connections, [])
    }
}
