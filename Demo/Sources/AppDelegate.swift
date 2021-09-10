//
//  Copyright © Marc Schultz. All rights reserved.
//

import Netbob
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Netbob.shared.start()

        let defaultProtocolClasses = URLSessionConfiguration.default.protocolClasses?.map { String(describing: $0) } ?? []
        let ephemeralProtocolClasses = URLSessionConfiguration.ephemeral.protocolClasses?.map { String(describing: $0) } ?? []

        print("  default: \(defaultProtocolClasses)")
        print("ephemeral: \(ephemeralProtocolClasses)")

        return true
    }
}
