import XCTest
@testable import AttributedText

final class FrameElementsTests: XCTestCase {
    func test_default_elements() {
        let def = FrameElements<DefaultAttributes>.default
        XCTAssertEqual(def.topLeftCorner                    , "+")
        XCTAssertEqual(def.topHorizontalSeparator           , "-")
        XCTAssertEqual(def.topHorizontalVerticalSeparator   , "+")
        XCTAssertEqual(def.topRightCorner                   , "+")
        XCTAssertEqual(def.leftVerticalSeparator            , "|")
        XCTAssertEqual(def.rightVerticalSeparator           , "|")
        XCTAssertEqual(def.insideLeftVerticalSeparator      , "+")
        XCTAssertEqual(def.insideHorizontalSeparator        , "-")
        XCTAssertEqual(def.insideRightVerticalSeparator     , "+")
        XCTAssertEqual(def.insideHorizontalVerticalSeparator, "+")
        XCTAssertEqual(def.insideVerticalSeparator          , "|")
        XCTAssertEqual(def.bottomLeftCorner                 , "+")
        XCTAssertEqual(def.bottomHorizontalSeparator        , "-")
        XCTAssertEqual(def.bottomHorizontalVerticalSeparator, "+")
        XCTAssertEqual(def.bottomRightCorner                , "+")
    }
    static var allTests = [
        ("test_default_elements", test_default_elements)
    ]
}
