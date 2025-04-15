import Foundation
import Zscaler

public protocol TunnelPresenting: AnyObject {
    func startPreLoginTunnel(request: TunnelRequest)
    func startZeroTrustTunnel(request: TunnelRequest)
    func stopTunnel()
    func showStatus() -> ZscalerSDKTunnelStatus
    func updateConfiguration(_ config: ConfigurationOptions?)
}
