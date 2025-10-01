import XCTest
import WebKit
import OSLog

@testable import ZscalerSDKSampleApp

let logger = Logger()

class ZscalerSDKSampleAppUITests: XCTestCase, WKUIDelegate, WKNavigationDelegate {

    var app: XCUIApplication!
    var preLoginSwitch: XCUIElement!
    var zeroTrustSwitch: XCUIElement!
    var okButton: XCUIElement!
    var tunnelConnectedLabel: XCUIElement!
    var tunnelDisconnectedLabel: XCUIElement!
    var urlTextField: XCUIElement!
    var goButton: XCUIElement!
    var webView: XCUIElement!
    var app_key: XCUIElement!
    var access_token: XCUIElement!
    
    var secrets: AppSecrets! = nil

    override func setUpWithError() throws {
        secrets = try XCTUnwrap(AppSecrets.readFrom(environment: .qa2, bundle: .init(for: Self.self)), "Failed to read secrets from the JSON file.")

        continueAfterFailure = false
        app = XCUIApplication(bundleIdentifier: "com.zscaler.sdk.zscalersdk-ios.TestApp")
        app.launch()

        preLoginSwitch = app.switches["pre_login_toggle"]
        zeroTrustSwitch = app.switches["zero_trust_toggle"]
        urlTextField = app.textFields["browser_url_text_field"]
        goButton = app.buttons["go_button"]
        app_key = app.textFields["app_key_text_field"]
        access_token = app.textFields["access_token_text_field"]
    }

    override func tearDownWithError() throws {
    }

    func testPreLoginTunnel() throws {
        app_key.tap()
        app_key.clearText()
        app_key.typeText(secrets.appKeys.valid)
        startTunnel(preLoginSwitch, connectedLabel: "Pre login tunnel connected", app: app)
        stopTunnel(preLoginSwitch, disconnectedLabel: "Zscaler Tunnel has been disconnected", app: app)
    }

    func testZeroTrustTunnel() throws {
        app_key.tap()
        app_key.clearText()
        app_key.typeText(secrets.appKeys.valid)
        access_token.tap()
        access_token.clearText()
        access_token.typeText(secrets.accessTokens.valid)
        startTunnel(zeroTrustSwitch, connectedLabel: "Zero trust tunnel connected", app: app)
        stopTunnel(zeroTrustSwitch, disconnectedLabel: "Zscaler Tunnel has been disconnected", app: app)
    }

    func testTunnelUpgrade() throws {
        app_key.tap()
        app_key.clearText()
        app_key.typeText(secrets.appKeys.valid)
        access_token.tap()
        access_token.clearText()
        access_token.typeText(secrets.accessTokens.valid)
        startTunnel(preLoginSwitch, connectedLabel: "Pre login tunnel connected", app: app)
        startTunnel(zeroTrustSwitch, connectedLabel: "Zero trust tunnel connected", app: app)
        stopTunnel(zeroTrustSwitch, disconnectedLabel: "Zscaler Tunnel has been disconnected", app: app)
    }

    func testPreLoginTunnelUrlAccess() throws {
        app_key.tap()
        app_key.clearText()
        app_key.typeText(secrets.appKeys.valid)
        startTunnel(preLoginSwitch, connectedLabel: "Pre login tunnel connected", app: app)
        try UrlAccess(url: "https://prelogin.us.zsdk.automation.dev.zpath.net/anything?zsdk-prelogin",
                      expectedMethod: "GET",
                      expectedUrl: "https://prelogin.us.zsdk.automation.dev.zpath.net/anything?zsdk-prelogin",
                      expectedArgs: "\"args\": {\n    \"zsdk-prelogin\": \"\"",
                      app: app)
        stopTunnel(preLoginSwitch, disconnectedLabel: "Zscaler Tunnel has been disconnected", app: app)
        
    }

    func testZeroTrustTunnelUrlAccess() throws {
        app_key.tap()
        app_key.clearText()
        app_key.typeText(secrets.appKeys.valid)
        access_token.tap()
        access_token.clearText()
        access_token.typeText(secrets.accessTokens.valid)
        startTunnel(zeroTrustSwitch, connectedLabel: "Zero trust tunnel connected", app: app)
        try UrlAccess(url: "https://zerotrust.us.zsdk.automation.dev.zpath.net/anything?zsdk-zerotrust",
                      expectedMethod: "GET",
                      expectedUrl: "https://zerotrust.us.zsdk.automation.dev.zpath.net/anything?zsdk-zerotrust",
                      expectedArgs: "\"args\": {\n    \"zsdk-zerotrust\": \"\"",
                      app: app)
        stopTunnel(zeroTrustSwitch, disconnectedLabel: "Zscaler Tunnel has been disconnected", app: app)
    }

    func testIncorrectZDKId() throws {
        app_key.tap()
        app_key.clearText()
        app_key.typeText(secrets.appKeys.notJson)

        startTunnel(preLoginSwitch, connectedLabel: "Failed to start tunnel with error code: The operation couldn’t be completed. (com.zscaler.sdk.error error 9002.)", app: app)
    }

    func testIncorrectAuthToken() throws {
        app_key.tap()
        app_key.clearText()
        app_key.typeText(secrets.appKeys.valid)
        access_token.tap()
        access_token.clearText()
        access_token.typeText(secrets.accessTokens.badJson)

        startTunnel(zeroTrustSwitch, connectedLabel: "Failed to start tunnel with error code: The operation couldn’t be completed. (com.zscaler.sdk.error error 2013.)", app: app)
    }

    func testExportLogs() throws {
        let exportLogsButton = app.buttons["export_logs_button"]
        XCTAssertTrue(exportLogsButton.waitForExistence(timeout: 5), "Export Logs button not found")
        exportLogsButton.tap()
    }
    
    func testClearLogs() throws {
        let clearLogsButton = app.buttons["clear_logs_button"]
        XCTAssertTrue(clearLogsButton.waitForExistence(timeout: 5), "Clear Logs button not found")
        clearLogsButton.tap()
        
        let clearLogsAlert = app.alerts.firstMatch
        XCTAssertTrue(clearLogsAlert.waitForExistence(timeout: 10))
        
        let okButton = clearLogsAlert.buttons["OK"]
        XCTAssertTrue(okButton.exists)
        okButton.tap()
    }
}
