//
//  Copyright © Marc Schultz. All rights reserved.
//

import Foundation
@testable import Netbob

class FileManagerMock: FileManagerProtocol {
    enum Call: Equatable {
        case contentsOfDirectory(String)
        case createDirectory(String)
        case removeItem(String)
        case urls
    }

    var calls: [Call] = []

    var contentsOfDirectoryReturnValue: [URL] = []
    func contentsOfDirectory(at url: URL, includingPropertiesForKeys _: [URLResourceKey]?, options _: FileManager.DirectoryEnumerationOptions) throws -> [URL] {
        calls.append(.contentsOfDirectory(url.absoluteString))
        return contentsOfDirectoryReturnValue
    }

    func createDirectory(at url: URL, withIntermediateDirectories _: Bool, attributes _: [FileAttributeKey: Any]?) throws {
        calls.append(.createDirectory(url.absoluteString))
    }

    func removeItem(at url: URL) throws {
        calls.append(.removeItem(url.absoluteString))
    }

    var urlsReturnValue: [URL] = []
    func urls(for _: FileManager.SearchPathDirectory, in _: FileManager.SearchPathDomainMask) -> [URL] {
        calls.append(.urls)
        return urlsReturnValue
    }
}
