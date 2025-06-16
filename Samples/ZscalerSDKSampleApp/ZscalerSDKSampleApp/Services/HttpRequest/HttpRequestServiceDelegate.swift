import Foundation

public protocol HttpRequestServiceDelegate: AnyObject {
    func contentIsLoading()
    func contentIsLoaded(_ data: Data, _ response: HTTPURLResponse)
    func contentLoadError(error: any Error)
}
