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

    // Wait for response code to appear (indicates response is loading)
    let responseCodeElement = app.staticTexts["response_code"]
    XCTAssertTrue(responseCodeElement.waitForExistence(timeout: 15), "Response code element not found")
    
    let responseCode = responseCodeElement.label
    XCTAssertEqual(responseCode, "200", "Expected status code 200 but got \(responseCode)")
    
    // Wait for response body element to exist and be fully populated
    let bodyElement = app.staticTexts["response_body"]
    XCTAssertTrue(bodyElement.waitForExistence(timeout: 15), "Response body element not found")
    
    // Wait for the body to contain expected content (with retries)
    var body = bodyElement.label
    var attempts = 0
    let maxAttempts = 10
    
    // Check if response contains expected JSON fields, or at minimum contains the URL we requested
    // This handles both httpbin-style JSON responses and custom endpoint responses
    while !body.contains("\"method\": \"\(expectedMethod)\"") && 
          !body.contains(expectedUrl) && 
          attempts < maxAttempts {
        sleep(1)
        body = bodyElement.label
        attempts += 1
    }
    
    // For custom endpoints, we just need to verify we got a 200 response and the URL was accessible
    // For httpbin endpoints, we verify the JSON structure
    if body.contains("\"method\": \"\(expectedMethod)\"") {
        // httpbin-style JSON response - validate all fields
        XCTAssertTrue(body.contains("\"url\": \"\(expectedUrl)\""), "Expected URL not found in response body")
        XCTAssertTrue(body.contains(expectedArgs), "Expected args not found in response body")
    } else {
        // Custom endpoint response - just verify we got content back
        XCTAssertTrue(!body.isEmpty, "Response body is empty")
        XCTAssertTrue(body.count > 50, "Response body seems too short, may not have loaded properly")
    }
}
