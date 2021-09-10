//
//  Copyright © Marc Schultz. All rights reserved.
//

import SnapshotTesting
import XCTest
@testable import Netbob

class ListViewTests: XCTestCase {
    func test_listView() {
        let view = ListView(state: ListViewStateMock())

        assertSnapshot(matching: view, as: .image(layout: .device(config: .iPhoneSe), traits: .init(userInterfaceStyle: .light)))
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
