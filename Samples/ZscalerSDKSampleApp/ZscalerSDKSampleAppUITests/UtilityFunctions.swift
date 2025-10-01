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
    func clearText() {
        guard self.exists && self.isHittable else { return }
        self.tap()
        if let text = self.value as? String {
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: text.count)
            self.typeText(deleteString)
        } else {
            let fallbackDelete = String(repeating: XCUIKeyboardKey.delete.rawValue, count: 100)
            self.typeText(fallbackDelete)
        }
    }
}

func startTunnel(_ switchElement: XCUIElement, connectedLabel: String, app: XCUIApplication) {
    XCTAssertTrue(switchElement.exists)
    switchElement.tap()

    let tunnelConnectedLabel = app.staticTexts[connectedLabel]
    waitForExpectation(tunnelConnectedLabel, exists: true, timeout: 10)

    let okButton = app.alerts.firstMatch.buttons["OK"]
    XCTAssertTrue(okButton.exists)
    okButton.tap()
}

func stopTunnel(_ switchElement: XCUIElement, disconnectedLabel: String, app: XCUIApplication) {
    XCTAssertTrue(switchElement.exists)
    switchElement.tap()

    let tunnelDisconnectedLabel = app.staticTexts[disconnectedLabel]
    waitForExpectation(tunnelDisconnectedLabel, exists: true, timeout: 10)

    let okButton = app.alerts.firstMatch.buttons["OK"]
    okButton.tap()
}

func UrlAccess(url: String, expectedMethod: String, expectedUrl: String, expectedArgs: String, app: XCUIApplication) throws {
    let urlTextField = app.textFields["browser_url_text_field"]
    XCTAssertTrue(urlTextField.waitForExistence(timeout: 5), "URL text field not found")
    urlTextField.tap()
    urlTextField.clearText()
    urlTextField.typeText(url)

    let goButton = app.buttons["go_button"]
    XCTAssertTrue(goButton.exists, "Go button not found")
    goButton.tap()

    let webView = app.webViews.firstMatch
    XCTAssertTrue(webView.waitForExistence(timeout: 10), "WebView did not appear in time")

    let staticTextElements = webView.staticTexts.allElementsBoundByIndex
    let allText = staticTextElements.map { $0.label }.joined(separator: "\n")
    print("Full WebView contents:\n\(allText)")

    XCTAssertTrue(allText.contains("\"method\": \"\(expectedMethod)\""), "Expected 'method: \(expectedMethod)' not found in WebView content")
    XCTAssertTrue(allText.contains("\"url\": \"\(expectedUrl)\""), "Expected URL not found in WebView content")
    XCTAssertTrue(allText.contains(expectedArgs), "Expected args not found in WebView content")
}
