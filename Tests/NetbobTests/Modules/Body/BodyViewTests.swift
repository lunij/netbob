//
//  Copyright © Marc Schultz. All rights reserved.
//

import SnapshotTesting
import UIKit
import XCTest
@testable import Netbob

// swiftlint:disable force_unwrapping

class BodyViewTests: XCTestCase {
    func test_bodyView_whenImage() {
        let body = UIImage.testImage.jpegData(compressionQuality: 0.9)!
        let view = BodyView(state: BodyViewState(body: body))

        assertSnapshot(matching: view, as: .image(layout: .device(config: .iPhoneSe), traits: .init(userInterfaceStyle: .light)))
    }

    func test_bodyView_whenText() {
        let body = """
        {"key": "value"}
        """.data(using: .utf8)!
        let view = BodyView(state: BodyViewState(body: body))

        assertSnapshot(matching: view, as: .image(layout: .device(config: .iPhoneSe), traits: .init(userInterfaceStyle: .light)))
    }
}

extension UIImage {
    static var testImage: UIImage {
        UIImage(named: "unsplash.jpg", in: .module, with: nil)!
    }
}
