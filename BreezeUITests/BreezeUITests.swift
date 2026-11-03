import XCTest

final class BreezeUITests: XCTestCase {
    @MainActor
    func testLiveControlLayoutUsesVisibleChoicesAndRename() {
        let app = XCUIApplication()
        app.launchArguments = ["--connection-preview", "--controls-preview"]
        app.launch()
        XCTAssertTrue(app.switches["Power"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Wind speed, 2"].exists)
        XCTAssertTrue(app.buttons["Mode, Sleep"].exists)
        app.buttons["Rename fan"].tap()
        XCTAssertTrue(app.alerts["Rename fan"].waitForExistence(timeout: 5))
        app.alerts.buttons["Cancel"].tap()
        app.swipeUp()
        XCTAssertTrue(app.buttons["Light, Level3"].waitForExistence(timeout: 5))
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Visible live fan controls"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    @MainActor
    func testPairingGuideShowsRemoteStepsAndWiFiFallback() {
        let app = XCUIApplication()
        app.launchArguments = ["--connection-preview", "--pairing-preview"]
        app.launch()
        XCTAssertTrue(app.textFields["2.4 GHz Wi-Fi name"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.secureTextFields["Wi-Fi password"].exists)
        XCTAssertFalse(app.buttons["Use current Wi-Fi"].exists)
        app.swipeUp()
        app.buttons["Show remote pairing guide"].tap()
        XCTAssertTrue(app.navigationBars["Remote pairing guide"].waitForExistence(timeout: 5))
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["3. Press Timer until the remote displays 8."].waitForExistence(timeout: 5))
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Orient remote pairing guide"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    @MainActor
    func testFanControlsAndDemoDisclosure() {
        let app = XCUIApplication()
        app.launchArguments = ["--demo", "--connection-preview"]
        app.launch()
        XCTAssertTrue(app.staticTexts["Demo home"].waitForExistence(timeout: 5))
        app.buttons["fan.bedroom.details"].tap()
        XCTAssertTrue(app.buttons["speed.3"].waitForExistence(timeout: 5))
        app.buttons["speed.3"].tap()
        // LabeledContent exposes its title and value as one accessibility label.
        XCTAssertTrue(app.staticTexts["Fan, On · Speed 3"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["speed.3"].isSelected)
        app.buttons["detail.power"].tap()
        XCTAssertTrue(app.staticTexts["Fan, Off"].waitForExistence(timeout: 5))
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Fan controls"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    @MainActor
    func testConnectionSetupIsSeparateFromDemo() {
        let app = XCUIApplication()
        app.launchArguments = ["--connection-preview"]
        app.launch()
        XCTAssertTrue(app.staticTexts["Connect Breeze"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Demo home"].exists)
        app.buttons["Explore demo controls"].tap()
        XCTAssertTrue(app.staticTexts["Demo home"].waitForExistence(timeout: 5))
    }
}
