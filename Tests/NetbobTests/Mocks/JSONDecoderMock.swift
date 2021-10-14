//
//  Copyright © Marc Schultz. All rights reserved.
//

import Foundation
@testable import Netbob

class JSONDecoderMock: JSONDecoderProtocol {
    enum Call: Equatable {
        case decode(type: String, data: Data)
    }

    var calls: [Call] = []

    var decodeError: Error?
    var decodeReturnValue: Any?
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        calls.append(.decode(type: .init(describing: type), data: data))

        if let value = decodeReturnValue as? T {
            return value
        }

        throw decodeError ?? ErrorMock()
    }
}
