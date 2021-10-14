//
//  Copyright © Marc Schultz. All rights reserved.
//

import Combine
import Foundation

protocol HTTPConnectionDiskStorageProtocol: AnyObject {
    func read() throws -> [HTTPConnection]
    func store(_ connection: HTTPConnection) throws
    func clear() throws
}

final class HTTPConnectionDiskStorage: HTTPConnectionDiskStorageProtocol {
    private let fileManager: FileManagerProtocol

    private let jsonDecoder: JSONDecoderProtocol
    private let jsonEncoder: JSONEncoderProtocol

    private let readAction: (URL) throws -> Data
    private let writeAction: (Data, URL) throws -> Void

    private var documentDirectoryUrl: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    private var logDirectoryUrl: URL? {
        documentDirectoryUrl?.appendingPathComponent("netbob")
    }

    init(
        fileManager: FileManagerProtocol = FileManager.default,
        jsonDecoder: JSONDecoderProtocol = JSONDecoder(),
        jsonEncoder: JSONEncoderProtocol = JSONEncoder(),
        readAction: @escaping (URL) throws -> Data = defaultReadAction,
        writeAction: @escaping (Data, URL) throws -> Void = defaultWriteAction
    ) {
        self.fileManager = fileManager
        self.jsonDecoder = jsonDecoder
        self.jsonEncoder = jsonEncoder
        self.readAction = readAction
        self.writeAction = writeAction
    }

    func read() throws -> [HTTPConnection] {
        try contentsOfLogDirectory().map { url in
            let data = try readAction(url)
            let connection = try jsonDecoder.decode(HTTPConnection.self, from: data)
            connection.isFromCurrentSession = false
            return connection
        }
    }

    func store(_ connection: HTTPConnection) throws {
        guard let logDirectoryUrl = logDirectoryUrl else { return }

        try fileManager.createDirectory(at: logDirectoryUrl, withIntermediateDirectories: true)
        let fileName = Date().formatted("yyyy-MM-dd_HH-mm-ss-SSS").appending(".log")
        let fileUrl = logDirectoryUrl.appendingPathComponent(fileName)
        let data = try jsonEncoder.encode(connection)
        try writeAction(data, fileUrl)
    }

    func clear() throws {
        guard let logDirectoryUrl = logDirectoryUrl else { return }
        try fileManager.removeItem(at: logDirectoryUrl)
    }

    private func contentsOfLogDirectory() -> [URL] {
        guard let url = logDirectoryUrl else { return [] }
        return (try? fileManager.contentsOfDirectory(at: url)) ?? []
    }
}

private let defaultReadAction: (URL) throws -> Data = { url in
    try Data(contentsOf: url)
}

private let defaultWriteAction: (Data, URL) throws -> Void = { data, url in
    try data.write(to: url, options: .atomic)
}
