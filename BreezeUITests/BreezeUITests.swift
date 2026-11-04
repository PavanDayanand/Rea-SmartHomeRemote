import XCTest

final class BreezeUITests: XCTestCase {
    @MainActor
    func testHomeAndSettingsNavigation() {
        let app = XCUIApplication()
        app.launchArguments = ["--connection-preview"]
        app.launch()
        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Account connected"].exists == false)
        app.tabBars.buttons["Home"].tap()
        XCTAssertTrue(app.staticTexts["Connect Breeze"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testWidgetDeepLinkKeepsControlsOpen() {
        let app = XCUIApplication()
        app.launchArguments = ["--connection-preview", "--controls-preview"]
        app.launch()
        XCTAssertTrue(app.segmentedControls["remote.power"].waitForExistence(timeout: 5))
        app.open(URL(string: "breeze://connected/preview")!)
        XCTAssertTrue(app.segmentedControls["remote.power"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Done"].exists)
        app.navigationBars.buttons["Breeze"].tap()
        XCTAssertTrue(app.staticTexts["Connect Breeze"].waitForExistence(timeout: 5))
        app.terminate()
        app.open(URL(string: "breeze://connected/preview")!)
        XCTAssertTrue(app.segmentedControls["remote.power"].waitForExistence(timeout: 8))
        XCTAssertFalse(app.buttons["Done"].exists)
    }

    @MainActor
    func testLiveControlLayoutUsesVisibleChoicesAndRename() {
        let app = XCUIApplication()
        app.launchArguments = ["--connection-preview", "--controls-preview"]
        app.launch()
        XCTAssertTrue(app.segmentedControls["remote.power"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Wind speed, 2"].exists)
        app.buttons["remote.control.mode"].tap()
        XCTAssertTrue(app.buttons["Mode, Sleep"].isHittable)
        app.buttons["remote.control.timer"].tap()
        XCTAssertTrue(app.buttons["Timer, 8 h"].isHittable)
        XCTAssertTrue(app.buttons["Light, Level 3"].isHittable)
        app.buttons["Fan options"].tap()
        app.buttons["Rename fan"].tap()
        XCTAssertTrue(app.alerts["Rename fan"].waitForExistence(timeout: 5))
        app.alerts.buttons["Cancel"].tap()
        app.swipeUp()
        XCTAssertTrue(app.buttons["Light, Level 3"].waitForExistence(timeout: 5))
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
    func testLiveSiriSettingsAndNoDemoEntry() {
        let app = XCUIApplication()
        app.launchArguments = ["--connection-preview"]
        app.launch()
        XCTAssertFalse(app.buttons["Explore demo controls"].exists)
        app.tabBars.buttons["Settings"].tap()
        app.buttons["Siri & Shortcuts"].tap()
        XCTAssertTrue(app.navigationBars["Siri & Shortcuts"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Hey Siri, increase fan speed in Breeze"].exists)
    }
}
