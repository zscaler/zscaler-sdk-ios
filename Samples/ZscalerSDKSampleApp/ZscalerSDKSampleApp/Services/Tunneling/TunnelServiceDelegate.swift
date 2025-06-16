import Foundation
import Zscaler

protocol TunnelServiceDelegate: AnyObject {
    func tunnelIsInProgress()
    func tunnelDidStart(tunnelType: ZscalerSDKTunnelType)
    func tunnelDidFail(tunnelType: ZscalerSDKTunnelType, _ error: Error)
    func tunnelDidStop()
}
