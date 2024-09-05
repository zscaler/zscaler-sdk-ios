import UIKit

protocol LoggingViewable: LoadingViewable, AnyObject {
    func showError(_ errorDescription: String)
    func exportLogs(_ model: ZscalerLogModel)
    func clearLogs()
}
