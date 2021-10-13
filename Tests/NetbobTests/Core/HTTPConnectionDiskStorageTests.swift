//
//  Copyright © Marc Schultz. All rights reserved.
//

// swiftlint:disable force_unwrapping implicitly_unwrapped_optional

import XCTest
@testable import Netbob

class HTTPConnectionDiskStorageTests: XCTestCase {
    var mockFileManager: FileManagerMock!
    var mockJSONDecoder: JSONDecoderMock!
    var mockJSONEncoder: JSONEncoderMock!

    var sut: HTTPConnectionDiskStorage!

    override func setUp() {
        super.setUp()

        mockFileManager = FileManagerMock()
        mockJSONDecoder = JSONDecoderMock()
        mockJSONEncoder = JSONEncoderMock()

        sut = HTTPConnectionDiskStorage(
            fileManager: mockFileManager,
            jsonDecoder: mockJSONDecoder,
            jsonEncoder: mockJSONEncoder,
            readAction: { _ in .fake },
            writeAction: { _, _ in }
        )
    }

    func test_read_whenNoLogFiles() throws {
        mockFileManager.urlsReturnValue = [.fake]

        let connections = try sut.read()

        XCTAssertEqual(mockFileManager.calls, [.urls, .contentsOfDirectory("fake/netbob")])
        XCTAssertEqual(mockJSONDecoder.calls, [])
        XCTAssertEqual(connections, [])
    }

    func test_read_whenLogFiles() throws {
        mockFileManager.urlsReturnValue = [.fake]
        mockFileManager.contentsOfDirectoryReturnValue = [.fake]
        mockJSONDecoder.decodeReturnValue = HTTPConnection.fake()

        let connections = try sut.read()

        XCTAssertEqual(mockFileManager.calls, [.urls, .contentsOfDirectory("fake/netbob")])
        XCTAssertEqual(mockJSONDecoder.calls, [.decode(type: "HTTPConnection", data: .fake)])
        XCTAssertEqual(connections, [.fake()])
    }

    func test_store() throws {
        mockFileManager.urlsReturnValue = [.fake]
        mockJSONEncoder.encodeReturnValue = .fake

        try sut.store(.fake())

        XCTAssertEqual(mockFileManager.calls, [.urls, .createDirectory("fake/netbob")])
        XCTAssertEqual(mockJSONEncoder.encodeCalls.count, 1)
        guard let connection = mockJSONEncoder.encodeCalls.first as? HTTPConnection else {
            XCTFail("One call is expected")
            return
        }
        XCTAssertEqual(connection, .fake())
    }

    func test_clear() throws {
        mockFileManager.urlsReturnValue = [.fake]

        try sut.clear()

        XCTAssertEqual(mockFileManager.calls, [.urls, .removeItem("fake/netbob")])
    }
}

private extension URL {
    static let fake = URL(string: "fake")!
}
