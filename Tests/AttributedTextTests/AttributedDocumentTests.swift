
import XCTest
@testable import AttributedText

final class AttributedDocumentTests: XCTestCase {
    typealias Document = AttributedDocument<DefaultAttributes>
    typealias Text = AttributedText<DefaultAttributes>
    typealias Table = AttributedTable<DefaultAttributes>
    func test_nothing() {}
    static let allTests = [
        ("test_nothing", test_nothing),
    ]
}

