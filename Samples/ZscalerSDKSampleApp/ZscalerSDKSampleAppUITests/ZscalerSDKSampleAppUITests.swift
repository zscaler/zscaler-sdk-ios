import XCTest
import WebKit
import OSLog

@testable import ZscalerSDKSampleApp

let logger = Logger()

class ZscalerSDKSampleAppUITests: XCTestCase, WKUIDelegate, WKNavigationDelegate {

    var app: XCUIApplication!
    var preLoginButton: XCUIElement!
    var zeroTrustButton: XCUIElement!
    var stopButton: XCUIElement!
    var okButton: XCUIElement!
    var tunnelConnectedLabel: XCUIElement!
    var tunnelDisconnectedLabel: XCUIElement!
    var urlTextField: XCUIElement!
    var goButton: XCUIElement!
    var webView: XCUIElement!
    
    var secrets: AppSecrets! = nil

    override func setUpWithError() throws {
        secrets = try XCTUnwrap(AppSecrets.readFrom(environment: .qa2, bundle: .init(for: Self.self)), "Failed to read secrets from the JSON file.")

        continueAfterFailure = false
        app = XCUIApplication(bundleIdentifier: "com.zscaler.sdk.zscalersdk-ios.TestApp")
        app.launch()

        preLoginButton = app.buttons["Start Pre-Login Tunnel"]
        zeroTrustButton = app.buttons["Start Zero-Trust Tunnel"]
        stopButton = app.buttons["Stop Tunnel"]
        urlTextField = app.textFields["browser_url_text_field"]
        goButton = app.buttons["go_button"]
    }

    override func tearDownWithError() throws {
    }

    func testPreLoginTunnel() throws {
        enterCredentials(appKey: secrets.appKeys.valid, app: app)
        startTunnel(preLoginButton, alertText: "Pre Login Tunnel has connected", app: app)
        stopTunnel(stopButton, disconnectedLabel: "Zscaler Tunnel has been disconnected", app: app)
    }

    func testZeroTrustTunnel() throws {
        enterCredentials(appKey: secrets.appKeys.valid, accessToken: secrets.accessTokens.valid, app: app)
        startTunnel(zeroTrustButton, alertText: "Zero Trust Tunnel has connected", app: app)
        stopTunnel(stopButton, disconnectedLabel: "Zscaler Tunnel has been disconnected", app: app)
    }

    func testTunnelUpgrade() throws {
        enterCredentials(appKey: secrets.appKeys.valid, accessToken: secrets.accessTokens.valid, app: app)
        startTunnel(preLoginButton, alertText: "Pre Login Tunnel has connected", app: app)
        startTunnel(zeroTrustButton, alertText: "Zero Trust Tunnel has connected", app: app)
        stopTunnel(stopButton, disconnectedLabel: "Zscaler Tunnel has been disconnected", app: app)
    }

    func testPreLoginTunnelUrlAccess() throws {
        enterCredentials(appKey: secrets.appKeys.valid, app: app)
        startTunnel(preLoginButton, alertText: "Pre Login Tunnel has connected", app: app)
        try performRequest(
            url: "https://prelogin.us.zsdk.automation.dev.zpath.net/anything?zsdk-prelogin",
            expectedMethod: "GET",
            expectedUrl: "https://prelogin.us.zsdk.automation.dev.zpath.net/anything?zsdk-prelogin",
            expectedArgs: "\"args\": {\n    \"zsdk-prelogin\": \"\"",
            app: app
        )
        stopTunnel(stopButton, disconnectedLabel: "Zscaler Tunnel has been disconnected", app: app)
        
    }

    func testZeroTrustTunnelUrlAccess() throws {
        enterCredentials(appKey: secrets.appKeys.valid, accessToken: secrets.accessTokens.valid, app: app)
        startTunnel(zeroTrustButton, alertText: "Zero Trust Tunnel has connected", app: app)
        try performRequest(
            url: "https://zerotrust.us.zsdk.automation.dev.zpath.net/anything?zsdk-zerotrust",
            expectedMethod: "GET",
            expectedUrl: "https://zerotrust.us.zsdk.automation.dev.zpath.net/anything?zsdk-zerotrust",
            expectedArgs: "\"args\": {\n    \"zsdk-zerotrust\": \"\"",
            app: app
        )
        stopTunnel(stopButton, disconnectedLabel: "Zscaler Tunnel has been disconnected", app: app)
    }

    func testIncorrectZDKId() throws {
        enterCredentials(appKey: secrets.appKeys.notJson, app: app)

        startTunnel(preLoginButton, alertText: "The operation couldn’t be completed. (com.zscaler.sdk.error error 9002.)", app: app)
    }

    func testIncorrectAuthToken() throws {
        enterCredentials(appKey: secrets.appKeys.valid, accessToken: secrets.accessTokens.badJson, app: app)

        startTunnel(zeroTrustButton, alertText: "The operation couldn’t be completed. (com.zscaler.sdk.error error 2013.)", app: app)
    }

    func testExportLogs() throws {
        let logsPageButton = app.buttons["Logs"]
        XCTAssertTrue(logsPageButton.waitForExistence(timeout: 5), "Logs page button is not found")
        logsPageButton.tap()

        let exportLogsButton = app.buttons["Export Logs"]
        XCTAssertTrue(exportLogsButton.waitForExistence(timeout: 5), "Export Logs button not found")
        exportLogsButton.tap()
    }
    
    func testClearLogs() throws {
        let logsPageButton = app.buttons["Logs"]
        XCTAssertTrue(logsPageButton.waitForExistence(timeout: 5), "Logs page button is not found")
        logsPageButton.tap()

        let clearLogsButton = app.buttons["Clear Logs"]
        XCTAssertTrue(clearLogsButton.waitForExistence(timeout: 5), "Clear Logs button not found")
        clearLogsButton.tap()
    }
}
