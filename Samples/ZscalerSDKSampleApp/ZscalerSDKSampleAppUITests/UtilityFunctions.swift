//
//  UtilityFunctions.swift
//  ZscalerSDKSampleApp
//
//  Created by Sandeep Reddy Pisati on 4/29/25.
//

import XCTest

// Helper Functions

func waitForExpectation(_ element: XCUIElement, exists: Bool = true, timeout: TimeInterval = 10) {
    let predicate = NSPredicate(format: "exists == %@", NSNumber(value: exists))
    let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
    let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
    XCTAssertEqual(result, .completed, "Failed waiting for element to \(exists ? "appear" : "disappear")")
}

extension XCUIElement {
    func clearText(app: XCUIApplication) {
        guard self.exists && self.isHittable else { return }
        self.tap()
        
        self.typeText(XCUIKeyboardKey.delete.rawValue)
    }
}


func enterCredentials(appKey: String, accessToken: String? = nil, app: XCUIApplication) {
    app.buttons["Tunnel"].tap()

    let appKeyField = app.textFields["Enter App Key"]
    appKeyField.tap()
    appKeyField.typeText(XCUIKeyboardKey.delete.rawValue)
    appKeyField.typeText(appKey)
    
    if let accessToken = accessToken {
        let accessTokenField = app.textFields["Enter Access Token"]
        accessTokenField.tap()
        accessTokenField.typeText(XCUIKeyboardKey.delete.rawValue)
        accessTokenField.typeText(accessToken)
    }

    app.buttons["Done"].tap()
}


func startTunnel(_ switchElement: XCUIElement, alertText: String, app: XCUIApplication) {
    app.buttons["Tunnel"].tap()
    
    XCTAssertTrue(switchElement.exists)
    switchElement.tap()

    let tunnelConnectedLabel = app.staticTexts[alertText]
    waitForExpectation(tunnelConnectedLabel, exists: true, timeout: 10)

    let okButton = app.alerts.firstMatch.buttons["OK"]
    XCTAssertTrue(okButton.exists)
    okButton.tap()
}

func stopTunnel(_ switchElement: XCUIElement, disconnectedLabel: String, app: XCUIApplication) {
    app.buttons["Tunnel"].tap()

    XCTAssertTrue(switchElement.exists)
    switchElement.tap()

    let tunnelDisconnectedLabel = app.staticTexts[disconnectedLabel]
    waitForExpectation(tunnelDisconnectedLabel, exists: true, timeout: 10)

    let okButton = app.alerts.firstMatch.buttons["OK"]
    okButton.tap()
}

func performRequest(url: String, expectedMethod: String, expectedUrl: String, expectedArgs: String, app: XCUIApplication) throws {    app.buttons["Request"].tap()

    let urlTextField = app.textFields["Enter URL"]
    XCTAssertTrue(urlTextField.waitForExistence(timeout: 5), "URL text field not found")
    urlTextField.tap()
    sleep(1)
    urlTextField.tap()
    sleep(1)
    let selectAll = app.menuItems["Select All"]
    if selectAll.exists {
        selectAll.tap()
        urlTextField.typeText(XCUIKeyboardKey.delete.rawValue)
    }
    urlTextField.typeText(url)
    
    app.buttons["Done"].tap()

    let goButton = app.buttons["go_button"]
    XCTAssertTrue(goButton.exists, "Go button not found")
    goButton.tap()

    let responseCode = app.staticTexts["response_code"].label
    XCTAssertEqual(responseCode, "200")
    
    let body = app.staticTexts["response_body"].label


    XCTAssertTrue(body.contains("\"method\": \"\(expectedMethod)\""), "Expected 'method: \(expectedMethod)' not found in WebView content")
    XCTAssertTrue(body.contains("\"url\": \"\(expectedUrl)\""), "Expected URL not found in WebView content")
    XCTAssertTrue(body.contains(expectedArgs), "Expected args not found in WebView content")
}
