import Foundation

public protocol ClientPresenting {
    func executeRequest(method: HttpMethodType, url: URL)
}
