import Foundation
import Zscaler

public final class LoggingService {
    weak var delegate: LoggingServiceDelegate?

    private var zscalerSDK: ZscalerSDK

    init(zscalerSDK: ZscalerSDK) {
        self.zscalerSDK = zscalerSDK
    }

    func exportLogs(to path: String) {
        delegate?.isExportingLogs()
        Task {
            let zipPath = zscalerSDK.exportLogs(destination: path)
            DispatchQueue.main.async {
                if let zipPath {
                    self.delegate?.didExportLogs(to: zipPath)
                } else {
                    self.delegate?.exportLogsDidFail("Log file url is empty")
                }
            }
        }
    }
    
    func clearLogs() {
        zscalerSDK.clearLogs()
    }
}
