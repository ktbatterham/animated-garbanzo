import Foundation

class SecurityAnalyzer {
    static func analyze(device: NetworkDevice) -> [SecurityIssue] {
        var issues: [SecurityIssue] = []

        for port in device.openPorts {
            switch port {
            case 21:
                issues.append(SecurityIssue(
                    title: "Insecure FTP Service",
                    description: "FTP (Port 21) transmits data and credentials in plain text.",
                    severity: .high,
                    recommendation: "Disable FTP and use SFTP or a secure cloud alternative."
                ))
            case 23:
                issues.append(SecurityIssue(
                    title: "Telnet Detected",
                    description: "Telnet (Port 23) is an unencrypted legacy protocol.",
                    severity: .high,
                    recommendation: "Disable Telnet and use SSH for remote management."
                ))
            case 80:
                issues.append(SecurityIssue(
                    title: "Unencrypted HTTP",
                    description: "HTTP (Port 80) does not encrypt traffic, making it prone to eavesdropping.",
                    severity: .medium,
                    recommendation: "Enforce HTTPS (Port 443) for all web communications."
                ))
            case 445:
                issues.append(SecurityIssue(
                    title: "Exposed SMB Share",
                    description: "SMB (Port 445) is often targeted by ransomware like WannaCry.",
                    severity: .high,
                    recommendation: "Ensure SMBv1 is disabled and the service is not exposed to the public internet."
                ))
            case 3306:
                issues.append(SecurityIssue(
                    title: "Database Port Open",
                    description: "MySQL (Port 3306) should not be accessible from the local network unless necessary.",
                    severity: .medium,
                    recommendation: "Restrict database access to specific IP addresses or localhost."
                ))
            case 3389:
                issues.append(SecurityIssue(
                    title: "Remote Desktop (RDP) Open",
                    description: "RDP (Port 3389) is a common entry point for brute-force attacks.",
                    severity: .high,
                    recommendation: "Disable RDP if not needed, or use a VPN to access it securely."
                ))
            default:
                break
            }
        }

        return issues
    }

    static func getStatus(for issues: [SecurityIssue]) -> SecurityStatus {
        if issues.isEmpty {
            return .secure
        }

        if issues.contains(where: { $0.severity == .high }) {
            return .danger
        }

        return .warning
    }
}
