
import SwiftUI
import Combine
import Zscaler

// Handles control of the zscaler tunnel
@MainActor class TunnelViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Published Properties for UI
    @Published var appKey: String
    @Published var accessToken: String
    @Published var isInProgress = false
    @Published var notifications: [NotificationEntry] = []
    
    // Alert properties
    @Published var alertIsPresented = false
    @Published var alertTitle: String = ""
    @Published var alertText: String = ""
    
    // Status properties
    @Published var tunnelConnectionState: String = ""
    @Published var tunnelType: String = ""

    private var backgroundTask = UIBackgroundTaskIdentifier.invalid

    init() {
        appKey = AppConstants.shared.secrets?.appKeys.valid ?? ""
        accessToken = AppConstants.shared.secrets?.accessTokens.valid ?? ""

        subscribeToNotifications()
    }
    
    private func subscribeToNotifications() {
        let notificationNames: [NSNotification.Name] = [
            .ZscalerSDKTunnelDisconnected, .ZscalerSDKTunnelConnected, .ZscalerSDKTunnelResourceBlocked,
            .ZscalerSDKTunnelReconnecting, .ZscalerSDKTunnelAuthenticationRequired
        ]
        for name in notificationNames {
            NotificationCenter.default.publisher(for: name)
                .receive(on: DispatchQueue.main)
                .sink { notification in
                    guard let info = notification.object as? [AnyHashable: Any] else { return }
                    let notificationName = info[ZscalerSDKNotificationNameUserInfoKey] as? String
                    let notificationMessage = info[ZscalerSDKNotificationMessageUserInfoKey] as? String
                    self.handleNotification(name: notificationName ?? "???", message: notificationMessage)
                }
                .store(in: &cancellables)
        }
        
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .receive(on: DispatchQueue.main)
            .sink { _ in self.didEnterBackground() }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .receive(on: DispatchQueue.main)
            .sink { _ in self.willEnterForeground() }
            .store(in: &cancellables)

    }
    

    // MARK: - Public Methods (Actions)
    
    func startPreLogin() async {
        do {
            try await ZscalerSDK.sharedInstance().startPreLoginTunnel(appKey: appKey, deviceUdid: AppConstants.shared.deviceUUID())
            tunnelConnected(tunnelType: "Pre Login")
        } catch {
            logger.error("Error starting pre login tunnel: \(error)")
            tunnelError(error: error)
        }
    }
    
    func startZeroTrust() async {
        do {
            try await ZscalerSDK.sharedInstance()
                .startZeroTrustTunnel(appKey: appKey, deviceUdid: AppConstants.shared.deviceUUID(), accessToken: accessToken)
            tunnelConnected(tunnelType: "Zero Trust")
        } catch {
            logger.error("Error starting zero trust tunnel: \(error)")
            tunnelError(error: error)
        }
    }
    
    func stopTunnel() async {
        await ZscalerSDK.sharedInstance().stopTunnel()
        tunnelStopped()
    }
    
    
    private func willEnterForeground() {
        self.invalidateBackgroundTask()
        ZscalerSDK.sharedInstance().resume()
    }

    func didEnterBackground() {
        if UIDevice.current.isMultitaskingSupported {
            let app = UIApplication.shared
            self.backgroundTask = app.beginBackgroundTask(expirationHandler: { [unowned self] in
                // ExpirationHandler - A handler to be called shortly before the app’s remaining background time reaches 0.
                // https://developer.apple.com/documentation/uikit/uiapplication/1623031-beginbackgroundtask#parameters
                // Call suspend function just before app's background time reaches 0.
                ZscalerSDK.sharedInstance().suspend()
                self.invalidateBackgroundTask()
            })
        }
    }

    private func invalidateBackgroundTask() {
        let app = UIApplication.shared
        app.endBackgroundTask(self.backgroundTask)
        self.backgroundTask = UIBackgroundTaskIdentifier.invalid
    }

    // MARK: - Private Helpers for the view

    private func updateStatus() {
        let status = ZscalerSDK.sharedInstance().status()
        self.tunnelConnectionState = status.tunnelConnectionState
        self.tunnelType = status.tunnelType.description
    }
    
    private func handleNotification(name: String, message: String?) {
        notifications.insert(NotificationEntry(timestamp: Date(), name: name, message: message), at: 0)
        updateStatus()
    }
    
    private func tunnelConnected(tunnelType: String) {
        (alertTitle, alertText, alertIsPresented) = ("Tunnel Status", "\(tunnelType) Tunnel has connected", true)
        updateStatus()
    }
    
    private func tunnelStopped() {
        (alertTitle, alertText, alertIsPresented) = ("Tunnel Status", "Zscaler Tunnel has been disconnected", true)
        updateStatus()
    }
    
    private func tunnelError(error: Error) {
        (alertTitle, alertText, alertIsPresented) = ("Connection Error", error.localizedDescription, true)
        updateStatus()
    }
}
