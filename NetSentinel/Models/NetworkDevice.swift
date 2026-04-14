import Foundation

enum SecurityStatus: String, Codable {
    case secure = "Secure"
    case warning = "Warning"
    case danger = "Danger"
    case unknown = "Unknown"
}

struct NetworkDevice: Identifiable, Codable {
    let id: UUID
    let name: String
    let ipAddress: String
    var discoveredServices: [String]
    var openPorts: [Int]
    var securityStatus: SecurityStatus

    init(id: UUID = UUID(), name: String, ipAddress: String, discoveredServices: [String] = [], openPorts: [Int] = [], securityStatus: SecurityStatus = .unknown) {
        self.id = id
        self.name = name
        self.ipAddress = ipAddress
        self.discoveredServices = discoveredServices
        self.openPorts = openPorts
        self.securityStatus = securityStatus
    }
}
