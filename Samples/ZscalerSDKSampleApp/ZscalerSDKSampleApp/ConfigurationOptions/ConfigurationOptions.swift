import Foundation
import Zscaler

public struct ConfigurationOptions {
    public var automaticallyConfigureRequests: Bool

    public var automaticallyConfigureWebviews: Bool

    public var useProxyAuthentication : Bool

    public var failIfDeviceCompromised: Bool

    public var blockZPAConnectionsOnTunnelFailure: Bool

    public var enableDebugLogsInConsole: Bool

    public var logLevel: LogLevel
}
