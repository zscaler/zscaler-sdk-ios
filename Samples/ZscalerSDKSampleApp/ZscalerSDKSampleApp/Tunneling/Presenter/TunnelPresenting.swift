import Foundation

public protocol TunnelPresenting: AnyObject {
    func startPreLoginTunnel(request: TunnelRequest)
    func startZeroTrustTunnel(request: TunnelRequest)
    func stopTunnel()
    func showStatus() -> String
    func updateConfiguration(_ config: ConfigurationOptions?)
}
