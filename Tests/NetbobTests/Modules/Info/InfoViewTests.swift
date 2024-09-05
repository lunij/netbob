//
//  Copyright © Marc Schultz. All rights reserved.
//

import SnapshotTesting
import XCTest
@testable import Netbob

class InfoViewTests: XCTestCase {
    func test_infoView() {
        let view = InfoView(state: InfoViewState())

        assertSnapshot(of: view)
    }
}
