//
//  Copyright © Marc Schultz. All rights reserved.
//

import SnapshotTesting
import XCTest
@testable import Netbob

// swiftlint:disable force_unwrapping

class DetailViewTests: XCTestCase {
    func test_detailView() {
        TimeZoneProvider.shared.current = TimeZone(abbreviation: "GMT")!

        let view = DetailView(state: DetailViewState(connection: .fake()))

        assertSnapshot(matching: view, as: .image(layout: .device(config: .iPhoneSe), traits: .init(userInterfaceStyle: .light)))
    }
}
