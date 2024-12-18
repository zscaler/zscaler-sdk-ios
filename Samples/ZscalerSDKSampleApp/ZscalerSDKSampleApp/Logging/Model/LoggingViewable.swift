import UIKit

protocol LoggingViewable: AnyObject {
    func didExportLogs(_ errorDescription: ZscalerLogModel)
    func exportLogsDidFail(_ errorDescription: String)
}
