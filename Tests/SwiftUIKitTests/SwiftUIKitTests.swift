import XCTest
import SwiftUI
@testable import SwiftUIKit

final class SwiftUIKitTests: XCTestCase {
    func testChatHistoryViewInstantiation() {
        struct TestMessage: Identifiable, Hashable {
            let id = UUID()
            let text: String
        }
        let messages = [TestMessage(text: "Hello"), TestMessage(text: "World!")]
        let view = ChatHistoryView(messages: messages) { message in
            AnyView(Text(message.text))
        }
        XCTAssertNotNil(view)
    }
    // TODO: Add more comprehensive tests for all public components
} 