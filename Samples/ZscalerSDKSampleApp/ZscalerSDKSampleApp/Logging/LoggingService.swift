import Foundation
import Zscaler

final public class LoggingService {
    private var zscalerSDK: ZscalerSDK?

    init(zscalerSDK: ZscalerSDK? = nil) {
        self.zscalerSDK = zscalerSDK
    }

    public func exportLogs(destination: String, queue: DispatchQueue, _ completion: @escaping ((ZscalerLogModel) -> Void)) {
        if let url = zscalerSDK?.exportLogs(destination: destination) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0) {
                completion(.init(url: url))
            }
        } else {
            completion(.init(url: nil))
        }
    }

    public func clearLogs() {
        zscalerSDK?.clearLogs()
    }
}
