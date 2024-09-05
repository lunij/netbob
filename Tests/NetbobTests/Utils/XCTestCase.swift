//
//  Copyright © Marc Schultz. All rights reserved.
//

import SnapshotTesting
import SwiftUI
import XCTest

extension XCTestCase {
    func assertSnapshot<Value: View>(
        of value: Value,
        precision: Float = 1,
        perceptualPrecision: Float = 0.95,
        layouts: [SwiftUISnapshotLayout] = [.device(config: .iPhoneSe)],
        named name: String? = nil,
        record recording: Bool = false,
        timeout: TimeInterval = 5,
        file: StaticString = #filePath,
        line: UInt = #line,
        testName: String = #function
    ) {
        for layout in layouts {
            SnapshotTesting.assertSnapshot(
                of: value,
                as: .image(
                    precision: precision,
                    perceptualPrecision: perceptualPrecision,
                    layout: layout,
                    traits: .init(userInterfaceStyle: .light)
                ),
                named: name,
                record: recording,
                timeout: timeout,
                file: file,
                testName: testName,
                line: line
            )
        }
    }
}
