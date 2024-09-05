import Foundation
import Zscaler

public class ConfigurationOptionsViewModel: ObservableObject {
    @Published var configurations: ConfigurationOptions

    init(configurations: ZscalerSDKConfiguration = .defaultConfiguration) {
        self.configurations = ConfigurationOptions(
            automaticallyConfigureRequests: configurations.automaticallyConfigureRequests,
            automaticallyConfigureWebviews: configurations.automaticallyConfigureWebviews,
            useProxyAuthentication: configurations.useProxyAuthentication,
            failIfDeviceCompromised: configurations.failIfDeviceCompromised,
            blockZPAConnectionsOnTunnelFailure: configurations.blockZPAConnectionsOnTunnelFailure,
            enableDebugLogsInConsole: configurations.enableDebugLogsInConsole,
            logLevel: configurations.logLevel
        )
    }
}
