//
//  Copyright © Marc Schultz. All rights reserved.
//

import Foundation
@testable import Netbob

class JSONEncoderMock: JSONEncoderProtocol {
    var encodeError: Error?
    var encodeReturnValue: Data?
    var encodeCalls: [Any] = []
    func encode<T: Encodable>(_ value: T) throws -> Data {
        encodeCalls.append(value)
        if let data = encodeReturnValue {
            return data
        }

        throw encodeError ?? ErrorMock()
    }
}
