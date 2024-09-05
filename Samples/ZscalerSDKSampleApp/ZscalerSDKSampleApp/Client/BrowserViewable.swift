import Foundation

public protocol BrowserViewable: AnyObject {
    func renderTunnelContent(_ data: Data, _ response: HTTPURLResponse)
    func renderBlankContent(error: any Error)
}
