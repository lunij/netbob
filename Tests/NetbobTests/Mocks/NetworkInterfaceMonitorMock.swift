//
//  Copyright © Marc Schultz. All rights reserved.
//

import Combine
@testable import Netbob

class NetworkInterfaceMonitorMock: NetworkInterfaceMonitorProtocol {
    lazy var interface: AnyPublisher<[Interface], Never> = interfaceSubject.eraseToAnyPublisher()
    var interfaceSubject = PassthroughSubject<[Interface], Never>()
}
