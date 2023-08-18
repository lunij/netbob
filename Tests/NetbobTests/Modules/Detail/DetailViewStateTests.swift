//
//  Copyright © Marc Schultz. All rights reserved.
//

import XCTest
@testable import Netbob

class DetailViewStateTests: XCTestCase {
    override func setUp() {
        super.setUp()
        TimeZoneProvider.shared.current = TimeZone(abbreviation: "GMT")!
    }

    func test_createsViewData_whenResponseUnavailable() {
        let sut = DetailViewState(connection: .fake(response: nil))

        XCTAssertEqual(sut.viewData.requestBody, .fake)
        XCTAssertEqual(sut.viewData.requestCurl, "curl http://fake.abc/fake/path?a=1,b=2,c=3 -X GET")
        XCTAssertEqual(sut.viewData.requestDate, "1970-01-01 00:00:00 GMT")
        XCTAssertEqual(sut.viewData.requestHeaders, [])
        XCTAssertEqual(sut.viewData.requestMethod, "GET")
        XCTAssertEqual(sut.viewData.requestTimeout, "10.0 s")
        XCTAssertEqual(sut.viewData.requestURL, "http://fake.abc/fake/path?a=1,b=2,c=3")

        XCTAssertEqual(sut.viewData.responseBody, nil)
        XCTAssertEqual(sut.viewData.responseDate, "-")
        XCTAssertEqual(sut.viewData.responseHeaders, [])
        XCTAssertEqual(sut.viewData.responseStatus, "-")
    }

    func test_createsViewData_whenResponseAvailable() {
        let sut = DetailViewState(connection: .fake(response: .fake()))

        XCTAssertEqual(sut.viewData.requestBody, .fake)
        XCTAssertEqual(sut.viewData.requestCurl, "curl http://fake.abc/fake/path?a=1,b=2,c=3 -X GET")
        XCTAssertEqual(sut.viewData.requestDate, "1970-01-01 00:00:00 GMT")
        XCTAssertEqual(sut.viewData.requestHeaders, [])
        XCTAssertEqual(sut.viewData.requestMethod, "GET")
        XCTAssertEqual(sut.viewData.requestTimeout, "10.0 s")
        XCTAssertEqual(sut.viewData.requestURL, "http://fake.abc/fake/path?a=1,b=2,c=3")

        XCTAssertEqual(sut.viewData.responseBody, .fake)
        XCTAssertEqual(sut.viewData.responseDate, "1970-01-01 00:00:02 GMT")
        XCTAssertEqual(sut.viewData.responseHeaders, [Header(key: "Content-Type", value: "application/json")])
        XCTAssertEqual(sut.viewData.responseStatus, "200")
    }
}
