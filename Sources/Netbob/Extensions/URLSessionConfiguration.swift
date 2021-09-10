//
//  Copyright © Marc Schultz. All rights reserved.
//

import Foundation

@objc private extension URLSessionConfiguration {
    private static var firstOccurrence = true

    static func implementNetbob() {
        guard firstOccurrence else { return }
        firstOccurrence = false

        swizzleProtocolSetter()
        swizzleDefault()
        swizzleEphemeral()
    }

    private static func swizzleProtocolSetter() {
        guard
            let origMethod = class_getInstanceMethod(Self.self, #selector(setter: Self.protocolClasses)),
            let newMethod = class_getInstanceMethod(Self.self, #selector(setter: Self.protocolClassesSwizzled))
        else {
            assertionFailure("\(URLSessionConfiguration.self).protocolClasses could not be swizzled")
            return
        }

        method_exchangeImplementations(origMethod, newMethod)
    }

    private var protocolClassesSwizzled: [AnyClass]? {
        get {
            self.protocolClassesSwizzled
        }
        set {
            guard let newTypes = newValue else {
                self.protocolClassesSwizzled = nil
                return
            }

            var types: [AnyClass] = []

            for newType in newTypes where !types.contains(where: { $0 == newType }) {
                types.append(newType)
            }

            self.protocolClassesSwizzled = types
        }
    }

    private static func swizzleDefault() {
        guard
            let origMethod = class_getClassMethod(Self.self, #selector(getter: Self.default)),
            let newMethod = class_getClassMethod(Self.self, #selector(getter: Self.defaultSwizzled))
        else {
            assertionFailure("\(URLSessionConfiguration.self).default could not be swizzled")
            return
        }

        method_exchangeImplementations(origMethod, newMethod)
    }

    private static func swizzleEphemeral() {
        guard
            let origMethod = class_getClassMethod(Self.self, #selector(getter: Self.ephemeral)),
            let newMethod = class_getClassMethod(Self.self, #selector(getter: Self.ephemeralSwizzled))
        else {
            assertionFailure("\(URLSessionConfiguration.self).ephemeral could not be swizzled")
            return
        }

        method_exchangeImplementations(origMethod, newMethod)
    }

    private class var defaultSwizzled: URLSessionConfiguration {
        let config = URLSessionConfiguration.defaultSwizzled
        config.protocolClasses?.insert(NetbobURLProtocol.self, at: 0)
        return config
    }

    private class var ephemeralSwizzled: URLSessionConfiguration {
        let config = URLSessionConfiguration.ephemeralSwizzled
        config.protocolClasses?.insert(NetbobURLProtocol.self, at: 0)
        return config
    }
}
