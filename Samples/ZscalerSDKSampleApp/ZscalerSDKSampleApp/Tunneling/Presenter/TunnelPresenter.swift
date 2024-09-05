import Foundation

public class TunnelPresenter: TunnelPresenting {

    private var tunnelService: TunnelingService
    private weak var view: TunnelingViewable?

    init(tunnelService: TunnelingService,
         view: TunnelingViewable? = nil) {
        self.tunnelService = tunnelService
        self.view = view
    }

    public func startPreLoginTunnel(request: TunnelRequest) {
        view?.showLoading()
        Task { [unowned self] in
            do {
                let response = try await self.tunnelService.startPreLoginTunnel(request)
                DispatchQueue.main.async {
                    self.view?.hideLoading()
                    self.view?.startProxyOnTunnelConnect(tunnelType: .preLogin, response: response)
                }
            } catch {
                DispatchQueue.main.async {
                    self.view?.hideLoading()
                    self.view?.failureOnStart(.preLogin, error)
                }
            }
        }
    }

    public func stopTunnel() {
        tunnelService.stopTunnel()
    }

    public func startZeroTrustTunnel(request: TunnelRequest) {
        view?.showLoading()
        Task { [unowned self] in
            do {
                let response = try await self.tunnelService.startZeroTrustTunnel(request)
                DispatchQueue.main.async {
                    self.view?.hideLoading()
                    self.view?.startProxyOnTunnelConnect(tunnelType: .zeroTrust, response: response)
                }
            } catch {
                DispatchQueue.main.async {
                    self.view?.hideLoading()
                    self.view?.failureOnStart(.zeroTrust, error)
                }
            }
        }
    }

    public func showStatus() -> String {
        tunnelService.showTunnelStatus()
    }

    public func updateConfiguration(_ config: ConfigurationOptions?) {
        tunnelService.updateConfiguration(config)
    }
}
