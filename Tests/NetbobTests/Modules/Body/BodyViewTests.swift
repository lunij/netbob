//
//  Copyright © Marc Schultz. All rights reserved.
//

import SnapshotTesting
import UIKit
import XCTest
@testable import Netbob

class BodyViewTests: XCTestCase {
    func test_bodyView_whenImage() {
        let body = UIImage.testImage.jpegData(compressionQuality: 0.9)!
        let view = BodyView(state: BodyViewState(body: body))

        assertSnapshot(matching: view)
    }

    func test_bodyView_whenText() {
        let body = """
        {"key": "value"}
        """.data
        let view = BodyView(state: BodyViewState(body: body))

        assertSnapshot(matching: view)
    }
}

extension UIImage {
    static var testImage: UIImage {
        UIImage(named: "unsplash.jpg", in: .module, with: nil)!
    }
}
