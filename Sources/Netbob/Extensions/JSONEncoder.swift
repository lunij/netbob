//
//  Copyright © Marc Schultz. All rights reserved.
//

import Foundation

public protocol JSONEncoderProtocol {
    func encode<T: Encodable>(_ value: T) throws -> Data
}

extension JSONEncoder: JSONEncoderProtocol {}
