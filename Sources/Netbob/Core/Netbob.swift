//
//  Copyright © Marc Schultz. All rights reserved.
//

import SwiftUI

public final class Netbob {
    public static let shared = Netbob()
    public static let version = "0.1.0"

    public var blacklistedHosts: [String] = []

    var allowedContentTypes: [HTTPContentType] {
        get { HTTPConnectionRepository.shared.allowedContentTypes.value }
        set { HTTPConnectionRepository.shared.allowedContentTypes.value = newValue }
    }

    private(set) var isStarted = false

    private init() {}

    public func start() {
        guard !isStarted else { return }
        URLProtocol.registerClass(NetbobURLProtocol.self)
        isStarted = true
    }

    public func stop() {
        URLProtocol.unregisterClass(NetbobURLProtocol.self)
        isStarted = false
    }

    public func createView() -> AnyView {
        AnyView(ListView(state: ListViewState()))
    }
}
