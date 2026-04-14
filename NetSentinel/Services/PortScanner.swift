import Foundation
import Network

class PortScanner {
    static let shared = PortScanner()

    let criticalPorts = [21, 22, 23, 80, 445, 3306, 3389]

    func scanPorts(for host: String, progress: @escaping (Int) -> Void, completion: @escaping ([Int]) -> Void) {
        let group = DispatchGroup()
        var openPorts: [Int] = []
        var scannedCount = 0

        guard host != "Resolving..." && !host.isEmpty else {
            completion([])
            return
        }

        for port in criticalPorts {
            group.enter()
            checkPort(host: host, port: port) { isOpen in
                if isOpen {
                    openPorts.append(port)
                }
                scannedCount += 1
                progress(scannedCount)
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(openPorts.sorted())
        }
    }

    private func checkPort(host: String, port: Int, completion: @escaping (Bool) -> Void) {
        let portEndpoint = NWEndpoint.Port(integerLiteral: UInt16(port))
        let endpoint = NWEndpoint.hostPort(host: NWEndpoint.Host(host), port: portEndpoint)

        let parameters = NWParameters.tcp
        parameters.prohibitedInterfaceTypes = [.cellular]

        let connection = NWConnection(to: endpoint, using: parameters)
        var hasResponded = false

        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                if !hasResponded {
                    hasResponded = true
                    completion(true)
                    connection.cancel()
                }
            case .failed, .waiting:
                break
            default:
                break
            }
        }

        connection.start(queue: .global())

        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            if !hasResponded {
                hasResponded = true
                connection.cancel()
                completion(false)
            }
        }
    }
}
