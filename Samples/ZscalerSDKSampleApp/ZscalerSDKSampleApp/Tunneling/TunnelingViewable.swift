import Foundation

protocol TunnelingViewable: LoadingViewable, AnyObject {
    func failureOnStart(_ tunnelType: TunnelType, _ error: Error)
    func showAlert(tunnelType: TunnelType)
    func startTunnelTimer(tunnelType: TunnelType)
    func clearTunnelStatus()
    func togglePreLoginTunnel(isOn: Bool)
    func toggleZeroTrustTunnel(isOn: Bool)

    func startProxyOnTunnelConnect(tunnelType: TunnelType, response: TunnelResponse)
}
