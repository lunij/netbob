//
//  Copyright © Marc Schultz. All rights reserved.
//

import Foundation
@testable import Netbob

class LogFileProviderMock: LogFileProviderProtocol {
    enum Calls: Equatable {
        case createFullLog
        case saveFullLog
        case createSingleLog(connection: HTTPConnection, includeBody: Bool)
    }

    var calls: [Calls] = []

    var createFullLogReturnValue = URL(string: "http://fake.fake")!
    func createFullLog() throws -> URL {
        calls.append(.createFullLog)
        return createFullLogReturnValue
    }

    func saveFullLog() throws {
        calls.append(.saveFullLog)
    }

    var createSingleLogReturnValue = URL(string: "http://fake.fake")!
    func createSingleLog(from connection: HTTPConnection, includeBody: Bool) throws -> URL {
        calls.append(.createSingleLog(connection: connection, includeBody: includeBody))
        return createSingleLogReturnValue
    }
}
