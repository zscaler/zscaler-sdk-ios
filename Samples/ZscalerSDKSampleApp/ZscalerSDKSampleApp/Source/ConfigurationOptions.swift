
import Foundation
import Zscaler

public struct ConfigurationOptions: Equatable, Codable {
    public var automaticallyConfigureRequests: Bool

    public var automaticallyConfigureWebviews: Bool

    public var useProxyAuthentication : Bool

    public var failIfDeviceCompromised: Bool

    public var blockZPAConnectionsOnTunnelFailure: Bool

    public var enableDebugLogsInConsole: Bool

    public var logLevel: LogLevel
    
    
    init(configuration: ZscalerSDKConfiguration) {
        automaticallyConfigureRequests = configuration.automaticallyConfigureRequests
        automaticallyConfigureWebviews = configuration.automaticallyConfigureWebviews
        useProxyAuthentication = configuration.useProxyAuthentication
        failIfDeviceCompromised = configuration.failIfDeviceCompromised
        blockZPAConnectionsOnTunnelFailure = configuration.blockZPAConnectionsOnTunnelFailure
        enableDebugLogsInConsole = configuration.enableDebugLogsInConsole
        logLevel = configuration.logLevel
    }

    var zscalerConfiguration: ZscalerSDKConfiguration {
        return ZscalerSDKConfiguration(
            automaticallyConfigureRequests: automaticallyConfigureRequests,
            automaticallyConfigureWebviews: automaticallyConfigureWebviews,
            useProxyAuthentication: useProxyAuthentication,
            failIfDeviceCompromised: failIfDeviceCompromised,
            blockZPAConnectionsOnTunnelFailure: blockZPAConnectionsOnTunnelFailure,
            enableDebugLogsInConsole: enableDebugLogsInConsole,
            logLevel: logLevel
        )
    }
}

extension ConfigurationOptions {
    private static let userDefaultsKey = "zscaler_sdk_configuration_options"

    func save() {
        do {
            let data = try JSONEncoder().encode(self)
            UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
        } catch {
            logger.error("Failed to save configuration: \(error)")
        }
    }

    static func load() -> ConfigurationOptions? {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            logger.error("Failed to load configuration: UserDefaults key not found: \(Self.userDefaultsKey)")
            return nil
        }
        do {
            return try JSONDecoder().decode(ConfigurationOptions.self, from: data)
        } catch {
            logger.error("Failed to load configuration: \(error)")
            return nil
        }
    }
}
