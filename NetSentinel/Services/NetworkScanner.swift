import Foundation
import Network
import Combine

class NetworkScanner: ObservableObject {
    @Published var discoveredDevices: [NetworkDevice] = []
    private var browsers: [NWBrowser] = []
    private let serviceTypes = ["_http._tcp", "_ssh._tcp", "_smb._tcp", "_ftp._tcp"]

    func startScanning() {
        stopScanning()
        discoveredDevices = []

        for type in serviceTypes {
            let parameters = NWParameters()
            parameters.includePeerToPeer = true

            let descriptor = NWBrowser.Descriptor.bonjour(type: type, domain: nil)
            let browser = NWBrowser(for: descriptor, using: parameters)

            browser.browseResultsChangedHandler = { [weak self] results, changes in
                self?.handleResults(results)
            }

            browser.start(queue: .main)
            browsers.append(browser)
        }
    }

    func stopScanning() {
        for browser in browsers {
            browser.cancel()
        }
        browsers.removeAll()
    }

    private func handleResults(_ results: Set<NWBrowser.Result>) {
        for result in results {
            if case let .service(name, type, domain, _) = result.endpoint {
                let serviceString = "\(type).\(domain)"

                DispatchQueue.main.async {
                    if let index = self.discoveredDevices.firstIndex(where: { $0.name == name }) {
                        if !self.discoveredDevices[index].discoveredServices.contains(serviceString) {
                            self.discoveredDevices[index].discoveredServices.append(serviceString)
                        }
                    } else {
                        // For MVP, we use the endpoint's host representation if available
                        let hostStr: String
                        if case let .hostPort(host, _) = result.endpoint {
                           hostStr = "\(host)"
                        } else {
                           hostStr = "\(name).local" // Common for Bonjour
                        }

                        let device = NetworkDevice(
                            name: name,
                            ipAddress: hostStr,
                            discoveredServices: [serviceString]
                        )
                        self.discoveredDevices.append(device)
                    }
                }
            }
        }
    }
}
