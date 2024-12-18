import Foundation
import Zscaler

public final class LoggingPresenter: LoggingPresenting {
    typealias ViewType = LoggingViewable & LoadingViewable

    private var loggingService: LoggingService?
    private weak var view: ViewType?

    init(loggingService: LoggingService? = nil,
         view: ViewType? = nil) {
        self.loggingService = loggingService
        self.view = view
    }

    func exportLogs(to: String) {
        view?.showLoading()
        loggingService?.exportLogs(destination: to, queue: .main, { [weak self] logModel in
            self?.view?.hideLoading()
            if logModel.exportURL() == nil {
                self?.view?.exportLogsDidFail("Log file url is empty")
            } else {
                self?.view?.didExportLogs(logModel)
            }
        })
    }
    
    func clearLogs() {
        loggingService?.clearLogs()
    }
}
