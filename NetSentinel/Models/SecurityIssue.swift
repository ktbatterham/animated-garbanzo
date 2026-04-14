import Foundation

enum Severity: String, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

struct SecurityIssue: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let severity: Severity
    let recommendation: String

    init(id: UUID = UUID(), title: String, description: String, severity: Severity, recommendation: String) {
        self.id = id
        self.title = title
        self.description = description
        self.severity = severity
        self.recommendation = recommendation
    }
}
