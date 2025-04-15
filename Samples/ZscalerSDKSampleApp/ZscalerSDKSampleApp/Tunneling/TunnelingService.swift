import Combine
import Foundation
import Network
import UIKit
import Zscaler

public class TunnelingService {
    private var zscalerSDK: ZscalerSDK

    private var backgroundTask : UIBackgroundTaskIdentifier

    private var cancellables = Set<AnyCancellable>()

    init(zscalerSDK: ZscalerSDK) {
        self.zscalerSDK = zscalerSDK
        self.backgroundTask = UIBackgroundTaskIdentifier.invalid

        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { _ in self.willEnterForeground() }
            .store(in: &cancellables)
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { _ in self.didEnterBackground() }
            .store(in: &cancellables)
    }

    func willEnterForeground() {
        DispatchQueue.global().async { [unowned self] in
            self.invalidateBackgroundTask()
        }
        zscalerSDK.resume()
    }

    func didEnterBackground() {
        if UIDevice.current.isMultitaskingSupported {
            let app = UIApplication.shared
            self.backgroundTask = app.beginBackgroundTask(expirationHandler: { [unowned self] in
                // ExpirationHandler - A handler to be called shortly before the app’s remaining background time reaches 0.
                // https://developer.apple.com/documentation/uikit/uiapplication/1623031-beginbackgroundtask#parameters
                // Call suspend function just before app's background time reaches 0.
                self.zscalerSDK.suspend()
                self.invalidateBackgroundTask()
            })
        }
    }
    
    func invalidateBackgroundTask() {
        let app = UIApplication.shared
        app.endBackgroundTask(self.backgroundTask)
        self.backgroundTask = UIBackgroundTaskIdentifier.invalid
    }

    public func startPreLoginTunnel(_ request: TunnelRequest) async throws -> TunnelResponse {
        try await self.zscalerSDK.startPreLoginTunnel(appKey: request.appKey, deviceUdid: request.deviceId)
        guard let proxyInfo = zscalerSDK.proxyInfo else {
            throw NSError(domain: "invalid state", code: 0, userInfo: nil)
        }
        return TunnelResponse(host: proxyInfo.proxyHost, portNumber: proxyInfo.proxyPort)
    }

    public func startZeroTrustTunnel(_ request: TunnelRequest) async throws -> TunnelResponse {
        try await self.zscalerSDK.startZeroTrustTunnel(appKey: request.appKey, deviceUdid: request.deviceId, accessToken: request.accessToken)
        guard let proxyInfo = zscalerSDK.proxyInfo else {
            throw NSError(domain: "invalid state", code: 0, userInfo: nil)
        }
        return TunnelResponse(host: proxyInfo.proxyHost, portNumber: proxyInfo.proxyPort)
    }

    public func stopTunnel() async {
        await zscalerSDK.stopTunnel()
    }

    public func setup(sessionConfiguration: URLSessionConfiguration) -> Bool {
        return zscalerSDK.setup(sessionConfiguration: sessionConfiguration)
    }

    public func showTunnelStatus() -> ZscalerSDKTunnelStatus {
        zscalerSDK.status()
    }

    public func updateConfiguration(_ config: ConfigurationOptions?) {
        guard let config else { return }
        let configuration = ZscalerSDKConfiguration(
            automaticallyConfigureRequests: config.automaticallyConfigureRequests,
            automaticallyConfigureWebviews: config.automaticallyConfigureWebviews,
            useProxyAuthentication: config.useProxyAuthentication,
            failIfDeviceCompromised: config.failIfDeviceCompromised,
            blockZPAConnectionsOnTunnelFailure: config.blockZPAConnectionsOnTunnelFailure,
            enableDebugLogsInConsole: config.enableDebugLogsInConsole,
            logLevel: config.logLevel
        )
        zscalerSDK.configuration = configuration
    }
}
