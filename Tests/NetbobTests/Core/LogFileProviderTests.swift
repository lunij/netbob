//
//  Copyright © Marc Schultz. All rights reserved.
//

// swiftlint:disable implicitly_unwrapped_optional

import XCTest
@testable import Netbob

class LogFileProviderTests: XCTestCase {
    var mockFileManager: FileManagerMock!
    var mockConnectionRepository: HTTPConnectionRepositoryMock!

    var sut: LogFileProvider!

    override func setUp() {
        super.setUp()

        mockFileManager = FileManagerMock()
        mockConnectionRepository = HTTPConnectionRepositoryMock()

        sut = LogFileProvider(
            fileManager: mockFileManager,
            httpConnectionRepository: mockConnectionRepository,
            writeAction: { _, _ in }
        )
    }

    func test_singleLog() throws {
        let url = try sut.createSingleLog(from: .fake(), includeBody: true)

        XCTAssertEqual(mockFileManager.calls, [])
        XCTAssertEqual(mockConnectionRepository.calls, [])
        XCTAssertEqual(url.absoluteString, "tmp/single-connection.log")
    }

    func test_fullLog() throws {
        let url = try sut.createFullLog()

        XCTAssertEqual(mockFileManager.calls, [])
        XCTAssertEqual(mockConnectionRepository.calls, [])
        XCTAssertEqual(url.absoluteString, "tmp/session.log")
    }
}
