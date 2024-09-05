//
//  Copyright © Marc Schultz. All rights reserved.
//

import SnapshotTesting
import XCTest
@testable import Netbob

class SettingsViewTests: XCTestCase {
    func test_settingsView() {
        let view = SettingsView(state: SettingsViewStateMock())

        assertSnapshot(of: view, perceptualPrecision: 0.5)
    }
}

private class SettingsViewStateMock: SettingsViewStateAbstract {
    override init() {
        super.init()

        blacklistedHosts = [
            "https://blacklisted.fake"
        ]
        contentTypes = [
            .init(name: "HTML", isEnabled: true),
            .init(name: "Image", isEnabled: true),
            .init(name: "JSON", isEnabled: true),
            .init(name: "XML", isEnabled: true),
            .init(name: "unknown", isEnabled: false)
        ]
    }
}
