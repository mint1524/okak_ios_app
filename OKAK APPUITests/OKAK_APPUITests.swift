
import XCTest

final class OKAK_APPUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLoginScreenIsVisibleOnLaunch() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-OKAK_UI_TESTS")
        app.launch()
        XCTAssertTrue(app.staticTexts["OKAK"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Войти"].exists || app.buttons["Login"].exists)
    }

    @MainActor
    func testRegisterButtonNavigates() throws {
        let app = XCUIApplication()
        app.launch()
        let registerButton = app.buttons["Создать аккаунт"]
        if registerButton.waitForExistence(timeout: 5) {
            registerButton.tap()
            XCTAssertTrue(app.staticTexts["Создать аккаунт"].waitForExistence(timeout: 3))
        }
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
