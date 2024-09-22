//
//  Copyright © Marc Schultz. All rights reserved.
//

import SnapshotTesting
import SwiftUI
import XCTest
@testable import Netbob

class ListViewTests: XCTestCase {
    func test_listView() {
        guard let gmt = TimeZone(secondsFromGMT: 0) else {
            XCTFail("GMT could not be initialized")
            return
        }
        TimeZoneProvider.shared.current = gmt

        let view = NavigationView {
            ListView(state: ListViewStateMock())
        }

        assertSnapshot(of: view)
    }
}

class ListViewStateMock: ListViewStateAbstract {
    override init() {
        super.init()

        connections = [
            .init(.fake()),
            .init(.fake(response: nil)),
            .init(.fake(response: .fake(httpUrlResponse: .fake(statusCode: 400))))
        ]
    }
}
