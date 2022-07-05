//
//  Copyright © Marc Schultz. All rights reserved.
//

import Combine
import Foundation

protocol HTTPConnectionRepositoryProtocol: AnyObject {
    var current: [HTTPConnection] { get }
    var latestConnection: AnyPublisher<HTTPConnection, Never> { get }
    var allowedContentTypes: CurrentValueSubject<[HTTPContentType], Never> { get }
    func store(_ connection: HTTPConnection)
    func clear()
}

final class HTTPConnectionRepository: HTTPConnectionRepositoryProtocol {
    private var connections: [HTTPConnection]?

    static let shared = HTTPConnectionRepository()

    let allowedContentTypes = CurrentValueSubject<[HTTPContentType], Never>(HTTPContentType.allCases)

    var current: [HTTPConnection] {
        if connections == nil {
            connections = try? diskStorage.read()
            connections?.sort(by: { $0.request.date > $1.request.date })
        }
        return connections ?? []
    }

    private let connectionSubject = PassthroughSubject<HTTPConnection, Never>()
    var latestConnection: AnyPublisher<HTTPConnection, Never> {
        connectionSubject.eraseToAnyPublisher()
    }

    private let diskStorage: HTTPConnectionDiskStorageProtocol

    init(diskStorage: HTTPConnectionDiskStorageProtocol = HTTPConnectionDiskStorage()) {
        self.diskStorage = diskStorage
    }

    func store(_ connection: HTTPConnection) {
        do {
            try diskStorage.store(connection)
        } catch {
            Netbob.log(String(describing: error))
        }
        connections?.insert(connection, at: 0)
        connectionSubject.send(connection)
    }

    func clear() {
        do {
            try diskStorage.clear()
        } catch {
            Netbob.log(String(describing: error))
        }
        connections?.removeAll()
    }
}
