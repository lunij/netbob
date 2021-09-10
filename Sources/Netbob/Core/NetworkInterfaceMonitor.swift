//
//  Copyright © Marc Schultz. All rights reserved.
//

import Combine
import Foundation
import Network

struct Interface {
    let name: String
    let type: InterfaceType
    let ipAddresses: [String]
}

enum InterfaceType: String {
    case cellular
    case wifi
    case wired
    case loopback
    case other
}

protocol NetworkInterfaceMonitorProtocol {
    var interface: AnyPublisher<[Interface], Never> { get }
}

class NetworkInterfaceMonitor: NetworkInterfaceMonitorProtocol {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "network_interface_monitor_queue")

    private let interfaceSubject = CurrentValueSubject<[Interface], Never>([])
    lazy var interface: AnyPublisher<[Interface], Never> = interfaceSubject
        .compactMap { $0 }
        .eraseToAnyPublisher()

    init() {
        monitor.pathUpdateHandler = { [interfaceSubject] path in
            interfaceSubject.send(path.availableInterfaces.map(\.bridged))
        }
        monitor.start(queue: queue)
    }
}

private extension NWInterface {
    var bridged: Interface {
        .init(
            name: name,
            type: type.bridged,
            ipAddresses: ipAddresses
        )
    }

    var ipAddresses: [String] {
        var addresses: [String] = []
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        if getifaddrs(&ifaddr) == 0 {
            var storedPointer = ifaddr

            while let pointer = storedPointer {
                defer {
                    storedPointer = pointer.pointee.ifa_next
                }

                let interface = pointer.pointee
                let addrFamily = interface.ifa_addr.pointee.sa_family

                guard addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) else { continue }

                guard name == String(cString: interface.ifa_name) else { continue }

                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(
                    interface.ifa_addr,
                    socklen_t(interface.ifa_addr.pointee.sa_len),
                    &hostname,
                    socklen_t(hostname.count),
                    nil,
                    socklen_t(0),
                    NI_NUMERICHOST
                )
                addresses.append(String(cString: hostname))
            }
        }

        freeifaddrs(ifaddr)

        return addresses
    }
}

private extension NWInterface.InterfaceType {
    var bridged: InterfaceType {
        switch self {
        case .cellular:
            return .cellular
        case .loopback:
            return .loopback
        case .other:
            return .other
        case .wifi:
            return .wifi
        case .wiredEthernet:
            return .wired
        @unknown default:
            assertionFailure("unknown type")
            return .other
        }
    }
}
