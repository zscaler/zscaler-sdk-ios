import SwiftUI
import Zscaler

public struct ConfigurationOptionsView: View {
    @StateObject
    private var viewModel = ConfigurationOptionsViewModel()
    private var dismiss: ((_ config: ConfigurationOptions?) -> Void)?

    init(dismiss: ((_ config: ConfigurationOptions?) -> Void)? = nil) {
        self.dismiss = dismiss
    }

    public var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        ConfigurationOptionToggle("URLSessions",
                                        "Should automatically configure URLSessions",
                                                $viewModel.configurations.automaticallyConfigureRequests)
                        ConfigurationOptionToggle("WebViews",
                                        "Should automatically configure WebViews",
                                                $viewModel.configurations.automaticallyConfigureWebviews)
                        ConfigurationOptionToggle("Enable logs in console",
                                        "Enable and change different log levels",
                                                $viewModel.configurations.enableDebugLogsInConsole)
                        ConfigurationOptionPicker("Log Level",
                                                $viewModel.configurations.logLevel)
                        ConfigurationOptionToggle("Proxy Authentication",
                                        "Use proxy authentication",
                                                $viewModel.configurations.useProxyAuthentication)
                        ConfigurationOptionToggle("Block JB Traffic",
                                        "Block traffic if device is Jail Broken",
                                                $viewModel.configurations.failIfDeviceCompromised)
                        ConfigurationOptionToggle("Block Connection",
                                        "Block connection on failure",
                                                $viewModel.configurations.blockZPAConnectionsOnTunnelFailure)
                    }
                }
            }
            .navigationBarItems(
                leading: Text("Configuration Options").font(.headline).padding(),
                trailing: Button(
                    action: {
                        dismiss?(viewModel.configurations)
                    }, label: {
                        Text("Done")
                    }
                )
            )
        }
    }
   

    @ViewBuilder
    private func ConfigurationOptionToggle(_ title: String,
                                           _ description: String,
                                           _ value: Binding<Bool>) -> some View {
        Toggle(isOn: value, label: {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
            }
        })
        .accessibilityIdentifier(title + "_Toggle")
    }

    @ViewBuilder
    private func ConfigurationOptionPicker(_ title: String,
                                           _ selectedItem: Binding<LogLevel>) -> some View {
        if viewModel.configurations.enableDebugLogsInConsole {
            HStack {
                Picker(title, selection: selectedItem) {
                    ForEach(LogLevel.allCases, id: \.self) { value in
                        switch value {
                        case .debug:
                            Text("Debug")
                        case .error:
                            Text("Error")
                        case .info:
                            Text("Info")
                        @unknown default:
                            Text("Debug")
                        }
                    }
                }
            }
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                EmptyView()
            }
        }
    }
}
