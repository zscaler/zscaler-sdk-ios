import UIKit
import SwiftUI
import Zscaler
import WebKit

public enum HttpMethodType: String {
    case get   = "GET"
    case post  = "POST"
}

enum TunnelType: String {
    case preLogin = "PreLogin"
    case zeroTrust = "ZeroTrust"
    case unknown = "Unknown"
}

class ViewController: UIViewController {
    
    @IBOutlet weak var appKeyTextField: UITextField!
    @IBOutlet weak var accessTokenTextField: UITextField!

    @IBOutlet weak var browserView: WKWebView!
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

    private var httpMethodType: HttpMethodType = .get

    private let defaultTunnelMessage = "ZPA Not Connected"

    private var logsDirectoryFileNameURL: URL?

    private var loggingPresenter: LoggingPresenter?

    private var tunnelPresenter: TunnelPresenting?

    private var clientPresenter: ClientPresenting?

    private var statusTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeServices()

        defaultTunnelStatus()
        defaultBrowserContent()

        browserURLTextField.delegate = self
        browserView.navigationDelegate = self

        // These are the hard coded values for the sample app
        appKeyBase64String()
        zeroTrustAccessToken()
    }

    private func initializeServices() {
        let zscalerSDK = ZscalerSDK.sharedInstance()
        zscalerSDK.configuration = ZscalerSDKConfiguration(useProxyAuthentication: true,
                                                           enableDebugLogsInConsole: true)
        registerNotifications(zscalerSDK)
        let loggingService = LoggingService(zscalerSDK: zscalerSDK)
        loggingPresenter = LoggingPresenter(loggingService: loggingService,
                                            view: self)
        
        let tunnelService = TunnelingService(zscalerSDK: zscalerSDK)
        tunnelPresenter = TunnelPresenter(tunnelService: tunnelService,
                                          view: self)

        clientPresenter = ClientPresenter(tunnelService: tunnelService,
                                          httpServiceFactory: HttpService.init,
                                          view: self)
    }

    private func registerNotifications(_ zscalerSDK: ZscalerSDK?) {
        NotificationCenter.default.addObserver(forName: NSNotification.ZscalerSDKTunnelDisconnected, object: nil, queue: .main) { notification in
            self.showNotificationBanner(notification: notification)
        }

        NotificationCenter.default.addObserver(forName: NSNotification.ZscalerSDKTunnelReadyToUse, object: nil, queue: .main) { notification in
            self.showNotificationBanner(notification: notification)
        }

        NotificationCenter.default.addObserver(forName: NSNotification.ZscalerSDKTunnelResourceBlocked, object: nil, queue: .main) { notification in
            self.showNotificationBanner(notification: notification)
        }

        NotificationCenter.default.addObserver(forName: NSNotification.ZscalerSDKTunnelConnectionFailed, object: nil, queue: .main) { notification in
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
        

        guard httpMethodType == .get else {
            self.clientPresenter?.executeRequest(method: .post, url: url)
            return
        }

        self.clientPresenter?.executeRequest(method: httpMethodType, url: url)
    }

    @IBAction func exportLogs(_ sender: UIButton) {
        extractLogs()
        DispatchQueue.main.async {
            self.shareLogs(url: self.logsDirectoryFileNameURL)
        }
    }

    @IBAction func clearLogsAction(_ sender: UIButton) {
        self.clearLogs()
        showAlert(title: "Log Status", message: "Logs has been cleared")
    }

    @IBAction func showMoreOptions(_ sender: UIButton) {
        let configOptionsView = ConfigurationOptionsView(dismiss: { [weak self] config in
            self?.tunnelPresenter?.updateConfiguration(config)
            self?.dismiss(animated: true)
        })
        let configOptionHostingController = UIHostingController(rootView: configOptionsView)
        self.present(configOptionHostingController, animated: true)
    }

    private func extractLogs() {
        if #available(iOS 16.0, *) {
            self.loggingPresenter?.exportLogs(to: URL.documentsDirectory.absoluteString)
        } else {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            self.loggingPresenter?.exportLogs(to: documentDirectory.absoluteString)
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
                                                  name: NSNotification.ZscalerSDKTunnelReadyToUse,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.ZscalerSDKTunnelResourceBlocked,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.ZscalerSDKTunnelConnectionFailed,
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

extension ViewController: LoggingViewable {
    func showLoading() {
        if self.loadingView.isHidden {
            self.loadingView.isHidden = false
        }
        self.loadingView.startAnimating()
    }

    func hideLoading() {
        self.loadingView.stopAnimating()
    }

    func showError(_ errorDescription: String) {
        DispatchQueue.main.async {
            self.zpaConnectedLabel.isHidden = false
            self.zpaConnectedLabel.text = errorDescription
        }
    }

    func exportLogs(_ model: ZscalerLogModel) {
        shareLogs(url: model.exportURL())
    }

    func clearLogs() {
        self.loggingPresenter?.clearLogs()
    }
}

extension ViewController : TunnelingViewable {
    func failureOnStart(_ tunnelType: TunnelType, _ error: Error) {
        forceTunnelSwitchOff(tunnelType: tunnelType)
        showAlert(title: "Tunnel Status",
                  message: "Failed to start tunnel with error code: \(error.localizedDescription)")
    }
    
    func showAlert(tunnelType: TunnelType) {
        switch tunnelType {
            case .preLogin:
                showAlert(title: "Tunnel Status", message: "Pre login tunnel connected")
            case .zeroTrust:
                showAlert(title: "Tunnel Status", message: "Zero trust tunnel connected")
            case .unknown:
                break
        }
    }

    func togglePreLoginTunnel(isOn: Bool) {
        if isOn {
            self.zeroTrustTunnelSwitch.isEnabled = false
            self.startPreLoginTunnel()
        } else {
            self.zeroTrustTunnelSwitch.isEnabled = true
            self.stopTunnel()
        }
    }
    
    func toggleZeroTrustTunnel(isOn: Bool) {
        if isOn {
            self.preLoginTunnelSwitch.isEnabled = false
            self.startZeroTrustTunnel()
        } else {
            self.preLoginTunnelSwitch.isEnabled = true
            self.stopTunnel()
        }
    }

    func forceTunnelSwitchOff(tunnelType: TunnelType) {
        switch tunnelType {
            case .preLogin:
                self.preLoginTunnelSwitch.setOn(false, animated: true)
                self.zeroTrustTunnelSwitch.isEnabled = true
            case .zeroTrust:
                self.zeroTrustTunnelSwitch.setOn(false, animated: true)
                self.preLoginTunnelSwitch.isEnabled = true
            case .unknown:
                break
        }
        if tunnelPresenter?.showStatus() == "OK"
            ||
           tunnelPresenter?.showStatus() == "CONNECTING" {
            stopTunnel()
        }
    }

    func startProxyOnTunnelConnect(tunnelType: TunnelType, response: TunnelResponse) {
        self.zpaConnectedLabel.isHidden = true
        self.showAlert(tunnelType: tunnelType)
        self.startTunnelTimer(tunnelType: tunnelType)
    }

    func startTunnelTimer(tunnelType: TunnelType) {
        statusTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { timer in
            let status = self.tunnelPresenter?.showStatus()
            self.statusTextView.text = String(format: "%@ - %@", tunnelType.rawValue,
                                              status ?? "")
            if status == "SERVER_DOWN_ERROR" {
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

extension ViewController: BrowserViewable {
    func renderTunnelContent(_ data: Data,  _ response: HTTPURLResponse) {
        self.showBrowser()
        self.browserView.load(data,
                              mimeType: response.mimeType ?? "text/html",
                              characterEncodingName: "utf-8",
                              baseURL: response.url ?? URL(string: "about:blank")!)
    }
    
    func renderBlankContent(error: any Error) {
        self.hideBrowser()
        self.zpaConnectedLabel.text = error.localizedDescription
    }

    func showBrowser() {
        self.browserView.isHidden = false
        self.zpaConnectedLabel.isHidden = true
    }

    func hideBrowser() {
        self.browserView.isHidden = true
        self.zpaConnectedLabel.isHidden = false
    }

    func defaultTunnelStatus() {
        zpaConnectedLabel.text = defaultTunnelMessage
    }

    func defaultBrowserContent() {
        self.browserView.load(Data([]),
                              mimeType: "text/html",
                              characterEncodingName: "utf-8",
                              baseURL: URL(string: "about:blank")!)
    }
}

// Tunneling helper methods

extension ViewController {
    func startPreLoginTunnel() {
        if let appKey = appKeyTextField.text {
            let request = TunnelRequest(appKey: appKey,
                                        deviceId: TunnelConstants.deviceUUID(),
                                        accessToken: "")
            tunnelPresenter?.startPreLoginTunnel(request: request)
        }
    }

    func stopTunnel() {
        tunnelPresenter?.stopTunnel()
        DispatchQueue.main.async {
            self.hideBrowser()
            self.clearTunnelStatus()
            self.showAlert(title: "Tunnel Status", message: "Zscaler Tunnel has been disconnected")
        }
    }

    func startZeroTrustTunnel() {
        if let appKey = appKeyTextField.text,
           let accessToken = accessTokenTextField.text {
            let request = TunnelRequest(appKey: appKey,
                                        deviceId: TunnelConstants.deviceUUID(),
                                        accessToken: accessToken)
            tunnelPresenter?.startZeroTrustTunnel(request: request)
        }
    }


    func appKeyBase64String() {
        appKeyTextField.text = TunnelConstants.appKey()
    }

    func zeroTrustAccessToken() {
        accessTokenTextField.text = TunnelConstants.accessToken()
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
        if let urlStr = navigationAction.request.url?.absoluteString {
            self.browserURLTextField.text = urlStr
        }
        decisionHandler(.allow)
    }
}
