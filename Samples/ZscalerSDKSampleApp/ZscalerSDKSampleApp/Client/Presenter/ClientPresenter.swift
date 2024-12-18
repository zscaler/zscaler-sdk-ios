import Foundation
import Network

public final class ClientPresenter : ClientPresenting {
    typealias ViewType = BrowserViewable & LoadingViewable

    private var tunnelService: TunnelingService
    private var httpServiceFactory: (URLSession) -> HttpService
    private weak var view: ViewType?

    init(tunnelService: TunnelingService,
         httpServiceFactory: @escaping (URLSession) -> HttpService,
         view: ViewType? = nil) {
        self.tunnelService = tunnelService
        self.httpServiceFactory = httpServiceFactory
        self.view = view
    }

    public func executeRequest(method: HttpMethodType, url: URL) {
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        _ = tunnelService.setup(sessionConfiguration: sessionConfiguration)
        let session = URLSession(configuration: sessionConfiguration)
        let service = HttpService(session: session)
        self.view?.showLoading()

        Task {
            do {
                let response = try await service.executeRequest(method: method, url: url)
                DispatchQueue.main.async {
                    self.view?.hideLoading()
                    self.view?.renderTunnelContent(response.data, response.response)
                }
            } catch {
                DispatchQueue.main.async {
                    self.view?.hideLoading()
                    self.view?.renderBlankContent(error: error)
                }
            }
        }
    }
}
