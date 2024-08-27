//
//  Copyright © Marc Schultz. All rights reserved.
//

import XCTest
@testable import Netbob

class LogFileProviderTests: XCTestCase {
    var mockFileManager: FileManagerMock!
    var mockConnectionRepository: HTTPConnectionRepositoryMock!

    var sut: LogFileProvider!

    var writeActionURLs: [String] = []

    override func setUp() {
        super.setUp()

        mockFileManager = FileManagerMock()
        mockConnectionRepository = HTTPConnectionRepositoryMock()

        sut = LogFileProvider(
            fileManager: mockFileManager,
            httpConnectionRepository: mockConnectionRepository,
            writeAction: { _, url in
                self.writeActionURLs.append(url.absoluteString)
            }
        )
    }

    func test_singleLog() throws {
        let url = try sut.createSingleLog(from: .fake(), includeBody: true)

        XCTAssertEqual(mockFileManager.calls, [])
        XCTAssertEqual(mockConnectionRepository.calls, [])
        XCTAssertEqual(url.absoluteString, "tmp/single-connection.log")
        XCTAssertEqual(writeActionURLs, ["tmp/single-connection.log"])
    }

    func test_fullLog() throws {
        let url = try sut.createFullLog()

        XCTAssertEqual(mockFileManager.calls, [])
        XCTAssertEqual(mockConnectionRepository.calls, [])
        XCTAssertEqual(url.absoluteString, "tmp/session.log")
        XCTAssertEqual(writeActionURLs, ["tmp/session.log"])
    }
}
