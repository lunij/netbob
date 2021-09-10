//
//  Copyright © Marc Schultz. All rights reserved.
//

import Combine
import Foundation

protocol HTTPConnectionRepositoryProtocol: AnyObject {
    var connections: AnyPublisher<[HTTPConnection], Never> { get }
    var allowedContentTypes: CurrentValueSubject<[HTTPContentType], Never> { get }
    func add(_ connection: HTTPConnection)
    func clear()
}

final class HTTPConnectionRepository: HTTPConnectionRepositoryProtocol {
    static let shared = HTTPConnectionRepository()

    let allowedContentTypes = CurrentValueSubject<[HTTPContentType], Never>(HTTPContentType.allCases)

    private let connectionsSubject = CurrentValueSubject<[HTTPConnection], Never>([])
    private lazy var _connections: AnyPublisher<[HTTPConnection], Never> = connectionsSubject.eraseToAnyPublisher()

    lazy var connections: AnyPublisher<[HTTPConnection], Never> = Publishers
        .CombineLatest(_connections, allowedContentTypes)
        .map { connections, allowedContentTypes in
            connections.filter {
                guard let contentType = $0.response?.contentType else { return false }
                return allowedContentTypes.contains(contentType)
            }
        }
        .eraseToAnyPublisher()

    func add(_ connection: HTTPConnection) {
        connectionsSubject.value.insert(connection, at: 0)
    }

    func clear() {
        connectionsSubject.send([])
    }
}
