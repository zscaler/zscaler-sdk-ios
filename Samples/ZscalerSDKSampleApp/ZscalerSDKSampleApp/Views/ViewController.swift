import UIKit
import SwiftUI
import Zscaler
import WebKit

public enum HttpMethodType: String {
    case get   = "GET"
    case post  = "POST"
    case web   = "WEB"
}

class ViewController: UIViewController {
    
    @IBOutlet weak var appKeyTextField: UITextField!
    @IBOutlet weak var accessTokenTextField: UITextField!

    @IBOutlet weak var browserURLTextField: UITextField!

    @IBOutlet weak var preLoginTunnelSwitch: UISwitch!
    @IBOutlet weak var zeroTrustTunnelSwitch: UISwitch!

    @IBOutlet weak var statusTextView: UITextView!

    @IBOutlet weak var zpaConnectedLabel: UILabel!
    @IBOutlet weak var browserGOButton: UIButton!

    @IBOutlet weak var loadingView: UIActivityIndicatorView!

    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var notificationMessageLabel: UILabel!
    @IBOutlet weak var notificationViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var notificationMessageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var webViewContainerView: UIStackView!

    var browserView: WKWebView?

    private var httpMethodType: HttpMethodType = .get

    private let defaultTunnelMessage = "ZPA Not Connected"

    private var logsDirectoryFileNameURL: URL?


    private var tunnelService: TunnelService!
    private var loggingService: LoggingService!
    private var httpRequestService: HttpRequestService!

    private var statusTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeServices()

        defaultTunnelStatus()

        browserURLTextField.delegate = self

        // These are the hard coded values for the sample app
        appKeyBase64String()
        zeroTrustAccessToken()
    }

    private func initializeServices() {
        let zscalerSDK = ZscalerSDK.sharedInstance()
        zscalerSDK.configuration = ZscalerSDKConfiguration(useProxyAuthentication: true,
                                                           enableDebugLogsInConsole: true)
        registerNotifications(zscalerSDK)

        loggingService = LoggingService(zscalerSDK: zscalerSDK)
        loggingService.delegate = self
        
        tunnelService = TunnelService(zscalerSDK: zscalerSDK)
        tunnelService.delegate = self

        httpRequestService = HttpRequestService(tunnelService: tunnelService)
        httpRequestService.delegate = self
    }

    private func registerNotifications(_ zscalerSDK: ZscalerSDK?) {
        NotificationCenter.default.addObserver(forName: NSNotification.ZscalerSDKTunnelDisconnected, object: nil, queue: .main) { notification in
            self.showNotificationBanner(notification: notification)
        }

        NotificationCenter.default.addObserver(forName: NSNotification.ZscalerSDKTunnelConnected, object: nil, queue: .main) { notification in
            self.showNotificationBanner(notification: notification)
        }

        NotificationCenter.default.addObserver(forName: NSNotification.ZscalerSDKTunnelResourceBlocked, object: nil, queue: .main) { notification in
            self.showNotificationBanner(notification: notification)
        }

        NotificationCenter.default.addObserver(forName: NSNotification.ZscalerSDKTunnelReconnecting, object: nil, queue: .main) { notification in
            self.showNotificationBanner(notification: notification)
        }

        NotificationCenter.default.addObserver(forName: NSNotification.ZscalerSDKTunnelAuthenticationRequired, object: nil, queue: .main) { notification in
            self.showNotificationBanner(notification: notification)
        }
    }

    private func showNotificationBanner(notification: Notification) {
        guard let info = notification.object as? [AnyHashable: Any] else {
            return
        }
        let notificationName = info[NotificationObjectConstants.notificationNameKey] as? String
        let notificationMessage = info[NotificationObjectConstants.notificationMessageKey] as? String
        let messageTextSize = notificationMessage?.count ?? 0
        showNotificationTray(name: notificationName,
                             text: messageTextSize > 0 ? notificationMessage : nil)
        hideNotificationTray()
    }

    private func showNotificationTray(name: String?, text: String?) {
        UIView.animate(withDuration: 0.3) {
            self.notificationView.alpha = 1.0
            self.notificationViewTopConstraint.constant = 64
            self.notificationLabel.text = name
            if text != nil {
                self.notificationMessageLabel.text = text
                self.notificationMessageHeightConstraint.constant = 40.0
            } else {
                self.notificationMessageLabel.text = nil
                self.notificationMessageHeightConstraint.constant = 0.0
            }
            self.view.layoutIfNeeded()
        }
    }

    private func hideNotificationTray() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            UIView.animate(withDuration: 0.3) {
                self.notificationView.alpha = 0.0
                self.notificationViewTopConstraint.constant = -100
                self.notificationMessageLabel.text = nil
                self.notificationLabel.text = nil
                self.view.layoutIfNeeded()
            }
        }
    }

    @IBAction func httpMethodAction(_ sender: UIButton) {
        switch httpMethodType {
        case .get:
            httpMethodType = .post
        case .post:
            httpMethodType = .web
        case .web:
            httpMethodType = .get
        }
        sender.setTitle(httpMethodType.rawValue, for: .normal)
    }

    @IBAction func togglePreLoginSwitch(_ sender: UISwitch) {
        self.togglePreLoginTunnel(isOn: sender.isOn)
    }

    @IBAction func toggleZeroTrustSwitch(_ sender: UISwitch) {
        self.toggleZeroTrustTunnel(isOn: sender.isOn)
    }

    @IBAction func goAction(_ sender: UIButton) {
        guard let urlText = browserURLTextField.text,
              let url = URL(string: urlText)
        else {
            return
        }
        
        if self.browserURLTextField.isFirstResponder {
            self.browserURLTextField.resignFirstResponder()
        }
        
        switch httpMethodType {
        case .get, .post:
            self.httpRequestService?.executeRequest(method: httpMethodType, url: url)
        case .web:
            self.showBrowser()
            let request = URLRequest(url: url)
            self.browserView?.load(request)
        }
    }

    @IBAction func exportLogs(_ sender: UIButton) {
        extractLogs()
        DispatchQueue.main.async {
            self.shareLogs(url: self.logsDirectoryFileNameURL)
        }
    }

    @IBAction func clearLogsAction(_ sender: UIButton) {
        self.loggingService.clearLogs()
        showAlert(title: "Log Status", message: "Logs has been cleared")
    }

    
    @IBAction func EventLogs(_ sender: UIButton) {
        let jsonViewController = JSONViewController()
        let navigationController = UINavigationController(rootViewController: jsonViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func showMoreOptions(_ sender: UIButton) {
        let configOptionsView = ConfigurationOptionsView(dismiss: { [weak self] config in
            self?.tunnelService.updateConfiguration(config)
            self?.dismiss(animated: true)
        })
        let configOptionHostingController = UIHostingController(rootView: configOptionsView)
        self.present(configOptionHostingController, animated: true)
    }

    private func extractLogs() {
        if #available(iOS 16.0, *) {
            self.loggingService.exportLogs(to: URL.documentsDirectory.absoluteString)
        } else {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            self.loggingService.exportLogs(to: documentDirectory.absoluteString)
        }
    }

    private func shareLogs(url: URL?) {
        guard let url else { return }
        let objects: [Any] = [url]

        let activityViewController = UIActivityViewController(activityItems: objects,
                                                              applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = { _, _, _, _ in
            do {
                // Remove local log bundle at the end.
                try FileManager.default.removeItem(at: url)
            }catch let error {
                print(error.localizedDescription)
            }
        }

        if UIDevice.current.userInterfaceIdiom == .pad {
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 300, height: 350)
        }

        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }

    deinit {
        stopAndClearTimer()
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.ZscalerSDKTunnelDisconnected,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.ZscalerSDKTunnelConnected,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.ZscalerSDKTunnelResourceBlocked,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.ZscalerSDKTunnelReconnecting,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.ZscalerSDKTunnelAuthenticationRequired,
                                                  object: nil)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension ViewController: LoggingServiceDelegate {
    func isExportingLogs() {
        showLoading()
    }
    
    func didExportLogs(to url: URL) {
        hideLoading()
        shareLogs(url: url)
    }

    func exportLogsDidFail(_ errorDescription: String) {
        hideLoading()
        self.zpaConnectedLabel.isHidden = false
        self.zpaConnectedLabel.text = errorDescription
    }
}

extension ViewController {
    func showLoading() {
        if self.loadingView.isHidden {
            self.loadingView.isHidden = false
        }
        self.loadingView.startAnimating()
    }

    func hideLoading() {
        self.loadingView.stopAnimating()
    }
}

extension ViewController : TunnelServiceDelegate {
    func tunnelDidStart(tunnelType: ZscalerSDKTunnelType) {
        self.hideLoading()
        self.zpaConnectedLabel.isHidden = true
        self.showAlert(tunnelType: tunnelType)
        self.startTunnelTimer(tunnelType: tunnelType)
    }

    func tunnelDidFail(tunnelType: ZscalerSDKTunnelType, _ error: Error) {
        self.hideLoading()

        let error = error as NSError
        
        let isTunnelUpgradeFailure =
        (tunnelType == .zeroTrust &&
         error.code == ZscalerSDKError.ErrorCode.tunnelUpgradeFailed.rawValue)
        
        let status = ZscalerSDK.sharedInstance().status()
        
        let isPreloginTunnelStillActive =
        (status.tunnelConnectionState == "ON" && status.tunnelType == .preLogin)
        
        if (isTunnelUpgradeFailure || isPreloginTunnelStillActive){
            self.preLoginTunnelSwitch.setOn(true, animated: true)
            self.zeroTrustTunnelSwitch.setOn(false, animated: true)
        } else {
            forceTunnelSwitchOff(tunnelType: tunnelType)
        }
            
        showAlert(title: "Tunnel Status",
                  message: "Failed to start tunnel with error code: \(error.localizedDescription)")
    }
    
    func tunnelIsInProgress() {
        self.showLoading()
    }

    func tunnelDidStop() {
        self.hideLoading()
    }

    func showAlert(tunnelType: ZscalerSDKTunnelType) {
        switch tunnelType {
        case .preLogin:
            showAlert(title: "Tunnel Status", message: "Pre login tunnel connected")
        case .zeroTrust:
            showAlert(title: "Tunnel Status", message: "Zero trust tunnel connected")
        default:
            break
        }
    }

    func togglePreLoginTunnel(isOn: Bool) {
        if isOn {
            self.zeroTrustTunnelSwitch.setOn(false, animated: true)
            self.startPreLoginTunnel()
        } else {
            self.stopTunnel()
        }
    }
    
    func toggleZeroTrustTunnel(isOn: Bool) {
        if isOn {
            self.preLoginTunnelSwitch.setOn(false, animated: true)
            self.startZeroTrustTunnel()
        } else {
            self.stopTunnel()
        }
    }

    func forceTunnelSwitchOff(tunnelType: ZscalerSDKTunnelType) {
        switch tunnelType {
        case .preLogin:
            self.preLoginTunnelSwitch.setOn(false, animated: true)
            self.zeroTrustTunnelSwitch.isEnabled = true
        case .zeroTrust:
            self.zeroTrustTunnelSwitch.setOn(false, animated: true)
            self.preLoginTunnelSwitch.isEnabled = true
        default:
            break
        }
        let tunnelConnectionState = tunnelService.showStatus().tunnelConnectionState
        if tunnelConnectionState == "OK" || tunnelConnectionState == "CONNECTING" {
            stopTunnel()
        }
    }

    func startTunnelTimer(tunnelType: ZscalerSDKTunnelType) {
        // Remove any previous timer
        self.clearTunnelStatus()
        statusTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { timer in
            let status = self.tunnelService.showStatus()
            var tunnelTypeStr = "INFO"
            tunnelTypeStr = tunnelType.description
            self.statusTextView.text = String(format: "%@ - %@", tunnelTypeStr,
                                              status.tunnelConnectionState)
            if status.tunnelConnectionState == "SERVER_DOWN_ERROR" {
                self.forceTunnelSwitchOff(tunnelType: tunnelType)
                self.clearTunnelStatus()
                self.stopAndClearTimer()
            }
        })
        self.startTimer()
    }

    func clearTunnelStatus() {
        statusTimer?.invalidate()
        statusTextView.text = ""
        defaultTunnelStatus()
        defaultBrowserContent()
    }

    func startTimer() {
        guard let statusTimer else { return }
        if statusTimer.isValid {
            statusTimer.fire()
        }
    }

    func stopAndClearTimer() {
        guard let statusTimer else { return }
        if statusTimer.isValid {
            statusTimer.invalidate()
            self.statusTimer = nil
        }
    }
}

extension ViewController: HttpRequestServiceDelegate {
    func contentIsLoaded(_ data: Data,  _ response: HTTPURLResponse) {
        self.hideLoading()
        self.showBrowser()
        self.browserView?.load(data,
                               mimeType: response.mimeType ?? "text/html",
                               characterEncodingName: "utf-8",
                               baseURL: response.url ?? URL(string: "about:blank")!)
    }
    
    func contentLoadError(error: any Error) {
        self.hideLoading()
        self.hideBrowser()
        self.zpaConnectedLabel.text = error.localizedDescription
    }
    
    func contentIsLoading() {
        self.showLoading()
    }

    private func createWebview() {
        if let browserView = self.browserView {
            self.webViewContainerView.removeArrangedSubview(browserView)
            self.browserView = nil
        }
        let dataStore = WKWebsiteDataStore.nonPersistent()
        let config = WKWebViewConfiguration()
        config.websiteDataStore = dataStore
        let webview = WKWebView(frame: self.webViewContainerView.bounds, configuration: config)
        URLCache.shared.removeAllCachedResponses()
        self.browserView = webview
        webview.navigationDelegate = self
        self.webViewContainerView.addArrangedSubview(webview)
    }

    private func showBrowser() {
        createWebview()
        self.browserView?.isHidden = false
        self.zpaConnectedLabel.isHidden = true
    }

    private func hideBrowser() {
        self.browserView?.isHidden = true
        self.zpaConnectedLabel.isHidden = false
    }

    private func defaultTunnelStatus() {
        zpaConnectedLabel.text = defaultTunnelMessage
    }

    private func defaultBrowserContent() {
        createWebview()
        self.browserView?.load(Data([]),
                               mimeType: "text/html",
                               characterEncodingName: "utf-8",
                               baseURL: URL(string: "about:blank")!)
    }
}

// Tunneling helper methods

extension ViewController {
    func startPreLoginTunnel() {
        if let appKey = appKeyTextField.text {
            tunnelService.startPreLoginTunnel(appKey: appKey, deviceId: AppConstants.shared.deviceUUID())
        }
    }

    func stopTunnel() {
        tunnelService.stopTunnel()
        DispatchQueue.main.async {
            self.hideBrowser()
            self.clearTunnelStatus()
            self.showAlert(title: "Tunnel Status", message: "Zscaler Tunnel has been disconnected")
        }
    }

    func startZeroTrustTunnel() {
        if let appKey = appKeyTextField.text,
           let accessToken = accessTokenTextField.text {
            tunnelService.startZeroTrustTunnel(
                appKey: appKey,
                deviceId: AppConstants.shared.deviceUUID(),
                accessToken: accessToken
            )
        }
    }


    func appKeyBase64String() {
        appKeyTextField.text = AppConstants.shared.appKey()
    }

    func zeroTrustAccessToken() {
        accessTokenTextField.text = AppConstants.shared.accessToken()
    }
}

extension ViewController {
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .destructive)
        alert.addAction(okAction)

        self.present(alert, animated: true)
    }
}

// WebView Delegate

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}
