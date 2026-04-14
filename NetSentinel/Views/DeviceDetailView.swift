import SwiftUI

struct DeviceDetailView: View {
    let device: NetworkDevice
    @ObservedObject var viewModel: DeviceDiscoveryViewModel
    @State private var issues: [SecurityIssue] = []

    var body: some View {
        List {
            Section(header: Text("Device Info")) {
                InfoRow(label: "Name", value: device.name)
                InfoRow(label: "Endpoint", value: device.ipAddress)
                InfoRow(label: "Services", value: device.discoveredServices.joined(separator: ", "))
            }

            Section {
                Button(action: {
                    viewModel.auditDevice(device)
                }) {
                    HStack {
                        Spacer()
                        if viewModel.isScanningPorts {
                            ProgressView()
                                .padding(.trailing, 10)
                        }
                        Text(device.securityStatus == .unknown ? "Start Security Audit" : "Re-Audit Device")
                            .fontWeight(.bold)
                        Spacer()
                    }
                }
                .disabled(viewModel.isScanningPorts)
            }

            Section(header: Text("Security Findings")) {
                if device.securityStatus == .unknown {
                    Text("Audit this device to check for vulnerabilities.")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                } else if issues.isEmpty {
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(.green)
                        Text("No critical open ports found.")
                            .font(.body)
                    }
                } else {
                    ForEach(issues) { issue in
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(issue.severity == .high ? .red : .orange)
                                Text(issue.title)
                                    .font(.headline)
                                Spacer()
                                SeverityBadge(severity: issue.severity)
                            }
                            Text(issue.description)
                                .font(.caption)

                            Divider()

                            Text("Recommendation")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            Text(issue.recommendation)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }

            if !device.openPorts.isEmpty {
                Section(header: Text("Raw Scan Data")) {
                    Text("Open Ports: \(device.openPorts.map(String.init).joined(separator: ", "))")
                        .font(.system(.caption, design: .monospaced))
                }
            }
        }
        .navigationTitle(device.name)
        .onAppear {
            self.issues = SecurityAnalyzer.analyze(device: device)
        }
        .onChange(of: device.openPorts) { _ in
            self.issues = SecurityAnalyzer.analyze(device: device)
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct SeverityBadge: View {
    let severity: Severity

    var body: some View {
        Text(severity.rawValue.uppercased())
            .font(.system(size: 10, weight: .bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(badgeColor)
            .foregroundColor(.white)
            .cornerRadius(5)
    }

    var badgeColor: Color {
        switch severity {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
}
