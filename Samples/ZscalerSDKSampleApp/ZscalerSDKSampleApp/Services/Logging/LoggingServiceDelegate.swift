import UIKit

protocol LoggingServiceDelegate: AnyObject {
    func isExportingLogs()
    func didExportLogs(to: URL)
    func exportLogsDidFail(_ errorDescription: String)
}
