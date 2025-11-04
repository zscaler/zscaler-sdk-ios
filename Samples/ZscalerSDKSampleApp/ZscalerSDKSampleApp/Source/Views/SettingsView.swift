
import SwiftUI
import Zscaler

public struct SettingsView: View {
    @State
    var configuration: ConfigurationOptions // Changed from @State to @Binding
        
    init(configuration: ZscalerSDKConfiguration = ZscalerSDK.sharedInstance().configuration) {
        self.configuration = ConfigurationOptions(configuration: configuration) // Use _configuration to set the binding
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        ConfigurationOptionToggle("URLSessions",
                                                  "Should automatically configure URLSessions",
                                                  $configuration.automaticallyConfigureRequests)
                        ConfigurationOptionToggle("WebViews",
                                                  "Should automatically configure WebViews",
                                                  $configuration.automaticallyConfigureWebviews)
                        ConfigurationOptionToggle("Enable logs in console",
                                                  "Enable and change different log levels",
                                                  $configuration.enableDebugLogsInConsole)
                        ConfigurationOptionPicker("Log Level",
                                                  $configuration.logLevel)
                        ConfigurationOptionToggle("Proxy Authentication",
                                                  "Use proxy authentication",
                                                  $configuration.useProxyAuthentication)
                        ConfigurationOptionToggle("Block JB Traffic",
                                                  "Block traffic if device is Jail Broken",
                                                  $configuration.failIfDeviceCompromised)
                        ConfigurationOptionToggle("Block Connection",
                                                  "Block connection on failure",
                                                  $configuration.blockZPAConnectionsOnTunnelFailure)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            self.configuration = ConfigurationOptions(configuration: ZscalerSDK.sharedInstance().configuration)
        }
        .onDisappear() {
            configuration.save()
            ZscalerSDK.sharedInstance().configuration = configuration.zscalerConfiguration
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
        if configuration.enableDebugLogsInConsole {
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
            .font(.headline)
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                EmptyView()
            }
        }
    }
}
