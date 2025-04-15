import Foundation

protocol TunnelingViewable: LoadingViewable, AnyObject {
    func tunnelDidStart(tunnelType: TunnelType, response: TunnelResponse)
    func tunnelDidFail(_ failureTunnelType: TunnelType, _ error: Error)
}
