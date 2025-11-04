
import SwiftUI
import WebKit
import Zscaler

@MainActor
class RequestViewModel: ObservableObject {
    // MARK: - Enums for UI State
    enum RequestMode: String, CaseIterable, Identifiable {
        case get = "GET"
        case post = "POST"
        case web = "WEB"
        var id: Self { self }
    }

    enum SDKConfig: String, CaseIterable, Identifiable {
        case automatic = "Automatic"
        case semiAutomatic = "Semi-Automatic"
        case manual = "Manual"
        var id: Self { self }
    }

    enum ResponseState {
        case idle
        case loading
        case webView(WKWebView, UUID = UUID())
        case urlResponse(code: Int, headers: [String:String], body: String)
        case error(String)
    }

    // MARK: - Published Properties for UI
    @Published var url: String
    @Published var requestMode: RequestMode
    @Published var sdkConfig: SDKConfig
    @Published var responseState: ResponseState = .idle

    init(url: String = AppConstants.shared.validUrl() ?? "",
         requestMode: RequestMode = .get,
         sdkConfig: SDKConfig = .semiAutomatic) {
        self.url = url
        self.requestMode = requestMode
        self.sdkConfig = sdkConfig
    }

    func executeRequest() {
        guard let newURL = URL(string: url) else {
            responseState = .error("Invalid URL")
            return
        }

        responseState = .loading

        if requestMode == .web {
            performWebViewLoad(url: newURL)
        } else { // .get or .post
            performUrlRequest(url: newURL)
        }
    }
    

    // MARK: - SDK Usage Examples

    // Automatic Configuration
    // The SDK automatically configures URLSession requests when enabled in settings.
    private func performAutomaticConfigUrlRequest(url: URL) {
        Task {
            do {
                let sessionConfig = URLSessionConfiguration.ephemeral
                let session = URLSession(configuration: sessionConfig)
                var request = URLRequest(url: url)
                request.httpMethod = requestMode.rawValue
                let (data, response) = try await session.data(for: request)
                gotUrlResponse(data: data, urlResponse: response)
            } catch {
                gotUrlError(error: error)
            }
        }
    }

    // Semi Automatic Configuration
    // The SDK is explicitly asked to configure a URLSessionConfiguration object.
    private func performSemiAutomaticConfigUrlRequest(url: URL) {
        Task {
            do {
                let sessionConfig = URLSessionConfiguration.ephemeral
                _ = ZscalerSDK.sharedInstance().setup(sessionConfiguration: sessionConfig)
                let session = URLSession(configuration: sessionConfig)
                var request = URLRequest(url: url)
                request.httpMethod = requestMode.rawValue
                let (data, response) = try await session.data(for: request)
                gotUrlResponse(data: data, urlResponse: response)
            } catch {
                gotUrlError(error: error)
            }
        }
    }

    // Manual Configuration
    // The SDK provides proxy details to be manually applied to a URLSessionConfiguration.
    private func performManualConfigUrlRequest(url: URL) {
        Task {
            do {
                let sessionConfig = URLSessionConfiguration.ephemeral
                if let proxyInfo = ZscalerSDK.sharedInstance().proxyInfo {
                    sessionConfig.connectionProxyDictionary = [
                        "HTTPSEnable": Int(1),
                        "HTTPSProxy": proxyInfo.proxyHost,
                        "HTTPSPort": proxyInfo.proxyPort,
                    ]
                }
                let session = URLSession(configuration: sessionConfig)
                var request = URLRequest(url: url)
                request.httpMethod = requestMode.rawValue
                let (data, response) = try await session.data(for: request)
                gotUrlResponse(data: data, urlResponse: response)
            } catch {
                gotUrlError(error: error)
            }
        }
    }

    private func performUrlRequest(url: URL) {
        switch sdkConfig {
        case .automatic:
            performAutomaticConfigUrlRequest(url: url)
        case .semiAutomatic:
            performSemiAutomaticConfigUrlRequest(url: url)
        case .manual:
            performManualConfigUrlRequest(url: url)
        }
    }
    
    private func performWebViewLoad(url: URL) {
        if #available(iOS 17, *) {
            switch sdkConfig {
            case .automatic:
                performAutomaticWebviewLoad(url: url)
            case .semiAutomatic:
                performSemiAutomaticWebviewLoad(url: url)
            case .manual:
                performManualWebviewLoad(url: url)
            }
        } else {
            self.responseState = .error("Cannot load webview on this device. Please upgrade to iOS 17")
        }
    }
    
    @available(iOS 17, *) // should only be ios 17+
    private func performAutomaticWebviewLoad(url: URL) {
        let dataStore = WKWebsiteDataStore.nonPersistent()
        let config = WKWebViewConfiguration()
        config.websiteDataStore = dataStore
        let webView = WKWebView(frame: .zero, configuration: config)
        URLCache.shared.removeAllCachedResponses()
        webView.load(URLRequest(url: url))
        responseState = .webView(webView)
    }
    
    @available(iOS 17, *)
    private func performSemiAutomaticWebviewLoad(url: URL) {
        let dataStore = WKWebsiteDataStore.nonPersistent()
        
        _ = ZscalerSDK.sharedInstance().setup(websiteDataStore: dataStore)

        let config = WKWebViewConfiguration()
        config.websiteDataStore = dataStore
        let webView = WKWebView(frame: .zero, configuration: config)
        URLCache.shared.removeAllCachedResponses()
        webView.load(URLRequest(url: url))
        responseState = .webView(webView)
    }

    @available(iOS 17, *)
    private func performManualWebviewLoad(url: URL) {
        let dataStore = WKWebsiteDataStore.nonPersistent()
        
        if let proxyInfo = ZscalerSDK.sharedInstance().proxyInfo {
            self.configure(websiteDataStore: dataStore, with: proxyInfo)
        }

        let config = WKWebViewConfiguration()
        config.websiteDataStore = dataStore
        let webView = WKWebView(frame: .zero, configuration: config)
        URLCache.shared.removeAllCachedResponses()
        webView.load(URLRequest(url: url))
        responseState = .webView(webView)
    }


    // MARK: - Private Helpers

    private func gotUrlResponse(data: Data, urlResponse: URLResponse) {
        if let httpResponse = urlResponse as? HTTPURLResponse {
            let headers = (httpResponse.allHeaderFields as? [String: String]) ?? [:]
            let body = String(data: data, encoding: .utf8) ?? "Could not decode response data."
            responseState = .urlResponse(code: httpResponse.statusCode, headers: headers, body: body)
        } else {
            responseState = .error("Response was not an HTTPURLResponse.")
        }
    }

    
    private func gotUrlError(error: Error) {
        responseState = .error("Request failed: \(error)")
    }
    
    
    @available(iOS 17.0, *)
    private func configure(websiteDataStore: WKWebsiteDataStore, with proxyInfo: ZscalerSDKProxyInfo) {
        precondition(Thread.isMainThread, "configure(websiteDataStore:withProxyInfo) must run on main thread.")
        
        let host = NWEndpoint.Host(proxyInfo.proxyHost)
        let port = NWEndpoint.Port(integerLiteral: NWEndpoint.Port.IntegerLiteralType(proxyInfo.proxyPort))
        
        let endpoint =  NWEndpoint.hostPort(host: host, port: port)
        let httpConnectConfiguration = ProxyConfiguration(httpCONNECTProxy: endpoint)
        
        // As of today (20th June 24), this works only on physical device)
        if let username = proxyInfo.username, let password = proxyInfo.password {
            httpConnectConfiguration.applyCredential(username: username,
                                                     password: password)
        }
        websiteDataStore.proxyConfigurations = [httpConnectConfiguration]
    }

}
