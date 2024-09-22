//
//  Copyright © Marc Schultz. All rights reserved.
//

import SnapshotTesting
import SwiftUI
import XCTest
@testable import Netbob

class DetailViewTests: XCTestCase {
    func test_detailView() {
        TimeZoneProvider.shared.current = TimeZone(abbreviation: "GMT")!

        let view = NavigationView {
            DetailView(state: DetailViewState(connection: .fake()))
        }

        assertSnapshot(of: view)
    }
}
