//
//  Copyright © Marc Schultz. All rights reserved.
//

import Foundation

extension Data {
    var string: String {
        String(decoding: self, as: UTF8.self)
    }
}

extension String {
    var data: Data {
        .init(utf8)
    }
}
