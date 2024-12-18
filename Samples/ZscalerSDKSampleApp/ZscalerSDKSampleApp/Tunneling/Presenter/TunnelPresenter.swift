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
                    self.view?.tunnelDidStart(tunnelType: .preLogin, response: response)
                }
            } catch {
                DispatchQueue.main.async {
                    self.view?.hideLoading()
                    self.view?.tunnelDidFail(.preLogin, error)
                }
            }
        }
    }

    public func stopTunnel() {
        view?.showLoading()
        Task {
            await tunnelService.stopTunnel()
            DispatchQueue.main.async {
                self.view?.hideLoading()
            }
        }
    }

    public func startZeroTrustTunnel(request: TunnelRequest) {
        view?.showLoading()
        Task { [unowned self] in
            do {
                let response = try await self.tunnelService.startZeroTrustTunnel(request)
                print("Done")
                DispatchQueue.main.async {
                    self.view?.hideLoading()
                    self.view?.tunnelDidStart(tunnelType: .zeroTrust, response: response)
                }
            } catch {
                DispatchQueue.main.async {
                    self.view?.hideLoading()
                    self.view?.tunnelDidFail(.zeroTrust, error)
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
