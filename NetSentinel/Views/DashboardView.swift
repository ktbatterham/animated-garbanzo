import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DeviceDiscoveryViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                StatusOverview(devices: viewModel.scanner.discoveredDevices)
                    .padding()

                if viewModel.isScanningPorts {
                    VStack {
                        ProgressView("Auditing Device...", value: viewModel.scanProgress, total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle())
                            .padding()
                    }
                    .background(Color.blue.opacity(0.1))
                }

                List {
                    Section(header: Text("Discovered Devices")) {
                        if viewModel.scanner.discoveredDevices.isEmpty {
                            Text("Searching for devices...")
                                .foregroundColor(.secondary)
                                .italic()
                        }

                        ForEach(viewModel.scanner.discoveredDevices) { device in
                            NavigationLink(destination: DeviceDetailView(device: device, viewModel: viewModel)) {
                                DeviceRow(device: device)
                            }
                        }
                    }
                }
            }
            .navigationTitle("NetSentinel")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.startDiscovery()
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .onAppear {
                viewModel.startDiscovery()
            }
        }
    }
}

struct StatusOverview: View {
    let devices: [NetworkDevice]

    var body: some View {
        let dangerCount = devices.filter { $0.securityStatus == .danger }.count
        let secureCount = devices.filter { $0.securityStatus == .secure }.count

        VStack {
            Text(dangerCount == 0 && secureCount > 0 ? "Network Secure" : (dangerCount > 0 ? "\(dangerCount) Security Risks Found" : "Scanning Network..."))
                .font(.headline)
                .foregroundColor(dangerCount == 0 ? .green : .red)

            HStack {
                MetricView(label: "Devices", value: "\(devices.count)", color: .primary)
                Spacer()
                MetricView(label: "Secure", value: "\(secureCount)", color: .green)
                Spacer()
                MetricView(label: "Risks", value: "\(dangerCount)", color: .red)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
        }
    }
}

struct MetricView: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct DeviceRow: View {
    let device: NetworkDevice

    var body: some View {
        HStack {
            Image(systemName: deviceIcon)
                .foregroundColor(statusColor)
                .frame(width: 30)

            VStack(alignment: .leading) {
                Text(device.name)
                    .font(.body)
                    .fontWeight(.medium)
                Text(device.ipAddress)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if device.securityStatus == .unknown {
                Text("NEW")
                    .font(.system(size: 8, weight: .bold))
                    .padding(4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
            }
        }
    }

    var deviceIcon: String {
        switch device.securityStatus {
        case .secure: return "shield.checkered"
        case .warning: return "exclamationmark.shield"
        case .danger: return "shield.exclamation"
        case .unknown: return "dot.radiowaves.left.and.right"
        }
    }

    var statusColor: Color {
        switch device.securityStatus {
        case .secure: return .green
        case .warning: return .yellow
        case .danger: return .red
        case .unknown: return .blue
        }
    }
}
