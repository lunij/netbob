//
//  Copyright © Marc Schultz. All rights reserved.
//

import SnapshotTesting
import SwiftUI
import XCTest

extension XCTestCase {
    func assertSnapshot<Value: View>(
        matching value: Value,
        precision: Float = 1,
        perceptualPrecision: Float = 0.95,
        named name: String? = nil,
        record recording: Bool = false,
        timeout: TimeInterval = 5,
        file: StaticString = #filePath,
        line: UInt = #line,
        testName: String = #function
    ) {
        SnapshotTesting.assertSnapshot(
            matching: value,
            as: .image(
                precision: precision,
                perceptualPrecision: perceptualPrecision,
                layout: .device(config: .iPhoneSe),
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
