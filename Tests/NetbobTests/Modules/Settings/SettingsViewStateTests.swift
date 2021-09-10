//
//  Copyright © Marc Schultz. All rights reserved.
//

import XCTest
@testable import Netbob

// swiftlint:disable implicitly_unwrapped_optional

class SettingsViewStateTests: XCTestCase {
    let mockHttpConnectionRepository = HTTPConnectionRepositoryMock()

    var sut: SettingsViewState!

    override func setUp() {
        super.setUp()

        sut = SettingsViewState(
            isEnabled: true,
            allowedContentTypes: [.json],
            blacklistedHosts: [],
            httpConnectionRepository: mockHttpConnectionRepository
        )
    }

    func test_createsViewData() {
        XCTAssertEqual(sut.isEnabled, true)
        XCTAssertEqual(sut.contentTypes, [
            .init(name: "JSON", isEnabled: true),
            .init(name: "XML", isEnabled: false),
            .init(name: "HTML", isEnabled: false),
            .init(name: "Image", isEnabled: false),
            .init(name: "unknown", isEnabled: false)
        ])
    }

    func test_clearsRepository() {
        // given
        XCTAssertNil(sut.actionSheetState)

        // when
        sut.handleClearAction()

        // then
        XCTAssertEqual(mockHttpConnectionRepository.calls, [])
        XCTAssertEqual(
            sut.actionSheetState,
            ActionSheetState(
                title: "Clear session?",
                message: nil,
                actions: [
                    .default(text: "Yes") {},
                    .default(text: "No") {}
                ]
            )
        )

        // when
        guard case let .default(_, action) = sut.actionSheetState?.actions.first else {
            XCTFail("An action is expected")
            return
        }
        action()

        // then
        XCTAssertEqual(mockHttpConnectionRepository.calls, [.clear])
    }
}
