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

    lazy var connections: AnyPublisher<[HTTPConnection], Never> = connectionsSubject.eraseToAnyPublisher()
    let connectionsSubject = PassthroughSubject<[HTTPConnection], Never>()

    lazy var filteredConnections: AnyPublisher<[HTTPConnection], Never> = filteredConnectionsSubject.eraseToAnyPublisher()
    let filteredConnectionsSubject = PassthroughSubject<[HTTPConnection], Never>()

    var allowedContentTypes = CurrentValueSubject<[HTTPContentType], Never>(HTTPContentType.allCases)

    func store(_ connection: HTTPConnection) {
        calls.append(.store(connection))
    }

    func clear() {
        calls.append(.clear)
    }
}
