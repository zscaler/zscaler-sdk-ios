import Foundation

protocol TunnelingViewable: LoadingViewable, AnyObject {
    func tunnelDidStart(tunnelType: TunnelType, response: TunnelResponse)
    func tunnelDidFail(_ tunnelType: TunnelType, _ error: Error)
}
