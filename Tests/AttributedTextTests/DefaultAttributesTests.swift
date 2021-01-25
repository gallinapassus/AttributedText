import XCTest
@testable import AttributedText

final class DefaultAttributesTests: XCTestCase {
    typealias Document = AttributedDocument<DefaultAttributes>
    typealias Text = AttributedText<DefaultAttributes>
    typealias Table = AttributedTable<DefaultAttributes>

    func test_defaultattributes() {

        // Test color attributes
        // In case of fgColor or bgColor is given multiple times,
        // last color must be active

        var attr:DefaultAttributes = [.fgColor(.red), .fgColor(.green)]
        XCTAssertEqual(attr.fgColor, .green)
        XCTAssertEqual(attr.bgColor, .default)
        XCTAssertEqual(attr.rawValue, 0)
        XCTAssertTrue(attr.contains(.fgColor(.green)))
        XCTAssertFalse(attr.contains(.fgColor(.red)))
        XCTAssertFalse(attr.contains(.bold))

        attr = [.fgColor(.blue), .bgColor(.red), .bgColor(.green), .bgColor(.blue)]
        XCTAssertEqual(attr, [DefaultAttributes.fgColor(.blue), DefaultAttributes.bgColor(.blue)])
        XCTAssertEqual(attr.fgColor, .blue)
        XCTAssertEqual(attr.bgColor, .blue)
        XCTAssertEqual(attr.rawValue, 0)
        XCTAssertTrue(attr.contains(.fgColor(.blue)))
        XCTAssertTrue(attr.contains(.bgColor(.blue)))
        XCTAssertFalse(attr.contains(.bold))

        let i1 = attr.update(with: .bold) // Add bold
        XCTAssertNil(i1)
        XCTAssertEqual(attr.fgColor, .blue)
        XCTAssertEqual(attr.bgColor, .blue)
        XCTAssertEqual(attr.rawValue, DefaultAttributes.bold.rawValue)
        XCTAssertTrue(attr.contains(.fgColor(.blue)))
        XCTAssertTrue(attr.contains(.bgColor(.blue)))
        XCTAssertTrue(attr.contains(.bold))

        let i2 = attr.remove(.fgColor(.blue)) // Remove blue fgColor
        XCTAssertEqual(i2, [.fgColor(.blue)])
        XCTAssertEqual(attr, [DefaultAttributes.fgColor(.default), DefaultAttributes.bgColor(.blue), .bold])
        XCTAssertFalse(attr.contains(.fgColor(.blue)))
        XCTAssertTrue(attr.contains(.bgColor(.blue)))
        XCTAssertTrue(attr.contains(.bold))
        let i3 = attr.remove(.bgColor(.blue)) // Remove blue bgColor
        XCTAssertEqual(i3, [.bgColor(.blue)])
        XCTAssertEqual(attr, [.bold])
        XCTAssertEqual(attr.rawValue, DefaultAttributes.bold.rawValue)
        XCTAssertEqual(attr.fgColor, IndexedColor.default)
        XCTAssertEqual(attr.bgColor, IndexedColor.default)
        XCTAssertFalse(attr.contains(.fgColor(.blue)))
        XCTAssertFalse(attr.contains(.bgColor(.blue)))
        XCTAssertTrue(attr.contains(.bold))
    }
    func test_ansicolors() {
        let str = "abc"
        for index in 0..<256 {
            let text = Text(str, .fgColor(.colorAtIndex(index)), .bgColor(.colorAtIndex(255 - index)))
            let expected = String.StringInterpolation.ControlCode.CSI + "38;5;\(index);48;5;\(255 - index)m\(str)" + String.StringInterpolation.ControlCode.RESET
            //print(index, expected, "==", text.render())
            XCTAssertEqual(expected, text.render())
        }
        // Below: Not really testing anything, just showing-off the indexed colors.
        let c = "◼︎"
        do {
            var text = Text("Standard colors:       ")
            for i in 0..<8 {
                text += Text(c, .fgColor(.colorAtIndex(i)))
            }
            print(text.render())
        }
        do {
            var text = Text("High intensity colors: ")
            for i in 8..<16 {
                text += Text(c, .fgColor(.colorAtIndex(i)))
            }
            print(text.render())
        }
        do {
            var text = Text("6 x 6 x 6 cube colors: ")
            for i in 16..<232 {
                if (i - 16).isMultiple(of: 36), i > 16 {
                    text += "\n                       "
                }
                text += Text(c, .fgColor(.colorAtIndex(i)))
            }
            print(text.render())
        }
        do {
            var text = Text("Grayscale colors:      ")
            for i in 232..<256 {
                text += Text(c, .fgColor(.colorAtIndex(i)))
            }
            print(text.render())
        }
    }
    func test_axioms() {
        let arr:[DefaultAttributes] = [.blink, .bold, .dim, .hidden, .inverse, .italic, .strikethrough, .underlined,
                                       .fgColor(.red), .fgColor(.green), .fgColor(.blue),
                                       .bgColor(.red), .bgColor(.green), .bgColor(.blue)]
        //        S() == []
        XCTAssertEqual(DefaultAttributes(), [], "S == []")
        let e = DefaultAttributes.strikethrough
        for var x in arr {
            for y in arr where y != e {
                // When implementing a custom type that conforms to the SetAlgebra
                // protocol, you must implement the required initializers and methods.
                // For the inherited methods to work properly, conforming types must
                // meet the following axioms. Assume that S is a custom type that
                // conforms to the SetAlgebra protocol, x and y are instances of S,
                // and e is of type S.Element—the type that the set holds.
                //        x.intersection(x) == x
                _ = x.insert(.bold)
                XCTAssertEqual(x.intersection(x), x)
                _ = x.insert(.fgColor(.black))
                XCTAssertEqual(x.intersection(x), x)
                _ = x.insert(.bgColor(.cyan))
                XCTAssertEqual(x.intersection(x), x)
                //        x.intersection([]) == []
                XCTAssertEqual(x.intersection([]), [])
                //        x.union(x) == x
                XCTAssertEqual(x.union(x), x)
                //        x.union([]) == x
                XCTAssertEqual(x.union([]), x)
                //        x.contains(e) implies x.union(y).contains(e)
                XCTAssertEqual(x.contains(e), x.union(y).contains(e), "\(x.traitsInEffect) contains \(e.traitsInEffect)  \(x.traitsInEffect) union \(y.traitsInEffect) -> \(x.union(y).traitsInEffect) contains \(e.traitsInEffect)")
                //        x.union(y).contains(e) implies x.contains(e) || y.contains(e)
                XCTAssertEqual(x.union(y).contains(e), x.contains(e) || y.contains(e))
                //        x.contains(e) && y.contains(e) if and only if x.intersection(y).contains(e)
                XCTAssertEqual(x.contains(e) && y.contains(e), x.intersection(y).contains(e))
                //        x.isSubset(of: y) implies x.union(y) == y
                XCTAssertEqual(x.isSubset(of: y), x.union(y) == y)
                //        x.isSuperset(of: y) implies x.union(y) == x
                XCTAssertEqual(x.isSuperset(of: y), x.union(y) == x)
                //        x.isSubset(of: y) if and only if y.isSuperset(of: x)
                XCTAssertEqual(x.isSubset(of: y), y.isSuperset(of: x))
                //        x.isStrictSuperset(of: y) if and only if x.isSuperset(of: y) && x != y
                XCTAssertEqual(x.isStrictSuperset(of: y), x.isSuperset(of: y) && x != y)
                //        x.isStrictSubset(of: y) if and only if x.isSubset(of: y) && x != y
                XCTAssertEqual(x.isStrictSubset(of: y), x.isSubset(of: y) && x != y)
            }
        }
    }
    static var allTests = [
        ("test_defaultattributes", test_defaultattributes),
        ("test_ansicolors", test_ansicolors),
        ("test_axioms", test_axioms),
    ]
}
