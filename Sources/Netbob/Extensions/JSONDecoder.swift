//
//  Copyright © Marc Schultz. All rights reserved.
//

import Foundation

public protocol JSONDecoderProtocol {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

public extension JSONDecoderProtocol {
    func decode<T: Decodable>(from data: Data) throws -> T {
        try decode(T.self, from: data)
    }
}

extension JSONDecoder: JSONDecoderProtocol {}
