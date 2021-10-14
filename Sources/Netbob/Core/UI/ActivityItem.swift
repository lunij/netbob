//
//  Copyright © Marc Schultz. All rights reserved.
//

import UIKit

protocol ActivityItemProtocol {
    var placeholder: Any { get }
    func item(for activityType: UIActivity.ActivityType?) -> Any?
    func subject(for activityType: UIActivity.ActivityType?) -> String
}

struct ActivityItem: ActivityItemProtocol, Identifiable {
    let text: String
    let subject: String
    let placeholder: Any = ""

    var id: String { text }

    func item(for _: UIActivity.ActivityType?) -> Any? {
        text
    }

    func subject(for _: UIActivity.ActivityType?) -> String {
        subject
    }
}
