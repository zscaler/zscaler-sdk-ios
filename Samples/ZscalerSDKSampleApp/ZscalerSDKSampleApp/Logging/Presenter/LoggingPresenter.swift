import Foundation
import Zscaler

public final class LoggingPresenter: LoggingPresenting {
    private var loggingService: LoggingService?
    private weak var view: LoggingViewable?

    init(loggingService: LoggingService? = nil,
         view: LoggingViewable? = nil) {
        self.loggingService = loggingService
        self.view = view
    }

    func exportLogs(to: String) {
        view?.showLoading()
        loggingService?.exportLogs(destination: to, queue: .main, { [weak self] logModel in
            self?.view?.hideLoading()
            if logModel.exportURL() == nil {
                self?.view?.showError("Log file url is empty")
            } else {
                self?.view?.exportLogs(logModel)
            }
        })
    }
    
    func clearLogs() {
        loggingService?.clearLogs()
    }
}
