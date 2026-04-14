import SwiftUI

@main
struct NetSentinelApp: App {
    @StateObject private var viewModel = DeviceDiscoveryViewModel()

    var body: some Scene {
        WindowGroup {
            DashboardView(viewModel: viewModel)
        }
    }
}
