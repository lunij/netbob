//
//  Copyright © Marc Schultz. All rights reserved.
//

import Combine
import Foundation

protocol HTTPConnectionRepositoryProtocol: AnyObject {
    var current: [HTTPConnection] { get }
    var connections: AnyPublisher<[HTTPConnection], Never> { get }
    var filteredConnections: AnyPublisher<[HTTPConnection], Never> { get }
    var allowedContentTypes: CurrentValueSubject<[HTTPContentType], Never> { get }
    func store(_ connection: HTTPConnection)
    func clear()
}

final class HTTPConnectionRepository: HTTPConnectionRepositoryProtocol {
    static let shared = HTTPConnectionRepository()

    let allowedContentTypes = CurrentValueSubject<[HTTPContentType], Never>(HTTPContentType.allCases)

    var current: [HTTPConnection] { connectionsSubject.value }

    private let connectionsSubject: CurrentValueSubject<[HTTPConnection], Never>
    lazy var connections: AnyPublisher<[HTTPConnection], Never> = connectionsSubject.eraseToAnyPublisher()

    lazy var filteredConnections: AnyPublisher<[HTTPConnection], Never> = Publishers
        .CombineLatest(connections, allowedContentTypes)
        .map { connections, allowedContentTypes in
            connections.filter {
                guard let contentType = $0.response?.contentType else { return false }
                return allowedContentTypes.contains(contentType)
            }
        }
        .eraseToAnyPublisher()

    private let diskStorage: HTTPConnectionDiskStorageProtocol

    init(diskStorage: HTTPConnectionDiskStorageProtocol = HTTPConnectionDiskStorage()) {
        let storedConnections: [HTTPConnection]
        do {
            storedConnections = try diskStorage.read()
        } catch {
            Netbob.log(String(describing: error))
            storedConnections = []
        }

        self.diskStorage = diskStorage
        connectionsSubject = CurrentValueSubject<[HTTPConnection], Never>(storedConnections)
    }

    func store(_ connection: HTTPConnection) {
        connectionsSubject.value.insert(connection, at: 0)
        do {
            try diskStorage.store(connection)
        } catch {
            Netbob.log(String(describing: error))
        }
    }

    func clear() {
        connectionsSubject.send([])
        do {
            try diskStorage.clear()
        } catch {
            Netbob.log(String(describing: error))
        }
    }
}
