//
//  Copyright © Marc Schultz. All rights reserved.
//

import XCTest
@testable import Netbob

class BodyViewStateTests: XCTestCase {
    func test_initializesWithImageBody() {
        let data = UIImage.testImage.pngData()!
        let sut = BodyViewState(body: data)

        if case let .image(uiImage) = sut.body {
            XCTAssertEqual(uiImage.pngData()!, data)
        } else {
            XCTFail("Body is expected to be an image")
        }
    }

    func test_initializesWithJsonBody() {
        let data = "{}".data
        let sut = BodyViewState(body: data)
        XCTAssertEqual(sut.body, .json("{\n\n}"))
    }

    func test_initializesWithTextBody() {
        let data = "fake".data
        let sut = BodyViewState(body: data)
        XCTAssertEqual(sut.body, .text("fake"))
    }
}
