//
//  Copyright © Marc Schultz. All rights reserved.
//

import Combine
@testable import Netbob

class HTTPConnectionRepositoryMock: HTTPConnectionRepositoryProtocol {
    enum Call: Equatable {
        case add(HTTPConnection)
        case clear
    }

    var calls: [Call] = []

    lazy var connections: AnyPublisher<[HTTPConnection], Never> = connectionsSubject.eraseToAnyPublisher()
    let connectionsSubject = PassthroughSubject<[HTTPConnection], Never>()

    var allowedContentTypes = CurrentValueSubject<[HTTPContentType], Never>(HTTPContentType.allCases)

    func add(_ connection: HTTPConnection) {
        calls.append(.add(connection))
    }

    func clear() {
        calls.append(.clear)
    }
}
