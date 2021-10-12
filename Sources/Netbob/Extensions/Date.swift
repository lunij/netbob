//
//  Copyright © Marc Schultz. All rights reserved.
//

import Foundation

extension Date {
    var formatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        formatter.locale = .current
        formatter.timeZone = TimeZoneProvider.shared.current
        return formatter.string(from: self)
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        formatter.locale = .current
        formatter.timeZone = TimeZoneProvider.shared.current
        return formatter.string(from: self)
    }
}

final class TimeZoneProvider {
    static let shared = TimeZoneProvider()

    var current: TimeZone = .current
}
