//
//  Copyright © Marc Schultz. All rights reserved.
//

import Combine
@testable import Netbob

class HTTPConnectionRepositoryMock: HTTPConnectionRepositoryProtocol {
    enum Call: Equatable {
        case store(HTTPConnection)
        case clear
    }

    var calls: [Call] = []

    var current: [HTTPConnection] = []

    lazy var latestConnection: AnyPublisher<HTTPConnection, Never> = connectionSubject.eraseToAnyPublisher()
    let connectionSubject = PassthroughSubject<HTTPConnection, Never>()

    var allowedContentTypes = CurrentValueSubject<[HTTPContentType], Never>(HTTPContentType.allCases)

    func store(_ connection: HTTPConnection) {
        calls.append(.store(connection))
    }

    func clear() {
        calls.append(.clear)
    }
}
