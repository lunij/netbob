//
//  Copyright © Marc Schultz. All rights reserved.
//

import Foundation
@testable import Netbob

class HTTPConnectionDiskStorageMock: HTTPConnectionDiskStorageProtocol {
    enum Call: Equatable {
        case read
        case store
        case clear
    }

    var calls: [Call] = []

    var readReturnValue: [HTTPConnection] = []
    func read() throws -> [HTTPConnection] {
        calls.append(.read)
        return readReturnValue
    }

    func store(_: HTTPConnection) throws {
        calls.append(.store)
    }

    func clear() throws {
        calls.append(.clear)
    }
}
