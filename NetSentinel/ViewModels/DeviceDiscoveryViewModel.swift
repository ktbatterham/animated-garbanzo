import Foundation
import Combine

class DeviceDiscoveryViewModel: ObservableObject {
    @Published var scanner = NetworkScanner()
    @Published var isScanningPorts = false
    @Published var scanProgress: Float = 0.0

    private var cancellables = Set<AnyCancellable>()

    init() {
        scanner.$discoveredDevices
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func startDiscovery() {
        scanner.startScanning()
    }

    func stopDiscovery() {
        scanner.stopScanning()
    }

    func auditDevice(_ device: NetworkDevice) {
        guard let index = scanner.discoveredDevices.firstIndex(where: { $0.id == device.id }) else { return }

        isScanningPorts = true
        scanProgress = 0

        let totalPorts = Float(PortScanner.shared.criticalPorts.count)

        PortScanner.shared.scanPorts(for: device.ipAddress, progress: { count in
            DispatchQueue.main.async {
                self.scanProgress = Float(count) / totalPorts
            }
        }) { openPorts in
            DispatchQueue.main.async {
                self.scanner.discoveredDevices[index].openPorts = openPorts
                let issues = SecurityAnalyzer.analyze(device: self.scanner.discoveredDevices[index])
                self.scanner.discoveredDevices[index].securityStatus = SecurityAnalyzer.getStatus(for: issues)
                self.isScanningPorts = false
                self.scanProgress = 1.0
            }
        }
    }
}
