import XCTest

final class SwiftUIKitDemoUITests: XCTestCase {
    func testAppLaunchesToMainScreen() {
        let app = XCUIApplication()
        app.launch()
        // Example: Check for a known element on the main screen
        XCTAssertTrue(app.otherElements["mainView"].exists || app.buttons.count > 0)
    }
}
