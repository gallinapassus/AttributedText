import XCTest
@testable import AttributedText

struct OptionSetAttributes : OptionSet, AttributeProtocol {
    static func render(_ attributed: AttributedText<OptionSetAttributes>) -> String {
        var str = ""
        for fragment in attributed.fragmentIterator() {
            guard let attributes = fragment.1 else {
                str += fragment.0
                continue
            }
            str += "[\(attributes)]\(fragment.0)"
        }
        return str
    }
    typealias RawValue = Int
    let rawValue:RawValue
    init(rawValue:RawValue) { self.rawValue = rawValue }
    static let info = OptionSetAttributes(rawValue: 1<<0)
    static let error = OptionSetAttributes(rawValue: 1<<1)
}
final class AttributedTextTests: XCTestCase {
    typealias Document = AttributedDocument<DefaultAttributes>
    typealias Text = AttributedText<DefaultAttributes>
    typealias Table = AttributedTable<DefaultAttributes>
    let renderer:Any? = nil

    struct AdditiveArithmeticAttributes : ExpressibleByArrayLiteral, AdditiveArithmetic, AttributeProtocol {
        static func render(_ attributed: AttributedText<AttributedTextTests.AdditiveArithmeticAttributes>) -> String {
            var str = ""
            for fragment in attributed.fragmentIterator() {
                guard let attributes = fragment.1 else {
                    str += fragment.0
                    continue
                }
                str += "[\(attributes)]\(fragment.0)"
            }
            return str
        }
        typealias ArrayLiteralElement = Self
        static func + (lhs: AdditiveArithmeticAttributes, rhs: AdditiveArithmeticAttributes) -> AdditiveArithmeticAttributes {
            AdditiveArithmeticAttributes(rawValue: lhs.rawValue | rhs.rawValue)
        }
        static func - (lhs: AdditiveArithmeticAttributes, rhs: AdditiveArithmeticAttributes) -> AdditiveArithmeticAttributes {
            AdditiveArithmeticAttributes(rawValue: lhs.rawValue | rhs.rawValue)
        }
        static var zero: AdditiveArithmeticAttributes = AdditiveArithmeticAttributes(rawValue: 0)
        typealias RawValue = Int
        let rawValue:RawValue
        init(rawValue:RawValue) { self.rawValue = rawValue }
        init(arrayLiteral elements: ArrayLiteralElement...) {
            self.rawValue = elements.reduce(.zero, { $0 + $1.rawValue })
        }
        static let info = AdditiveArithmeticAttributes(rawValue: 1<<0)
        static let error = AdditiveArithmeticAttributes(rawValue: 1<<1)
        static func == (lhs:AdditiveArithmeticAttributes, rhs:AdditiveArithmeticAttributes) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
    }

    internal struct CustomAttributes: OptionSet, AttributeProtocol {
        static func render(_ attributed: AttributedText<AttributedTextTests.CustomAttributes>) -> String {
            var str = ""
            for fragment in attributed.fragmentIterator() {
                guard let attributes = fragment.1 else {
                    str += fragment.0
                    continue
                }
                str += "[\(attributes)]\(fragment.0)"
            }
            return str
        }
        static func + (lhs: AttributedTextTests.CustomAttributes, rhs: AttributedTextTests.CustomAttributes) -> AttributedTextTests.CustomAttributes {
            Self(rawValue: lhs.rawValue | rhs.rawValue)
        }
        static func - (lhs: AttributedTextTests.CustomAttributes, rhs: AttributedTextTests.CustomAttributes) -> AttributedTextTests.CustomAttributes {
            var tmp = lhs
            return Self(rawValue: tmp.remove(rhs)?.rawValue ?? lhs.rawValue)
        }

        typealias ArrayLiteralElement = Self

        public typealias RawValue = Int
        public static let normal   = Self(rawValue: 1 << 0)
        public static let warning  = Self(rawValue: 1 << 1)
        public static let info     = Self(rawValue: 1 << 2)
        public static let error    = Self(rawValue: 1 << 3)
        public let rawValue: RawValue
    }

    func test_attributedtextinit() {
        do {
            typealias T = OptionSetAttributes
            let attrs:T? = [.info, .error]
            let str = "\(type(of: attrs))"
            let text = AttributedText<T>(str, .info, .error)
            let sub = AttributedText<T>(str[str.startIndex..<str.endIndex], .info, .error)
            XCTAssertEqual(text.unattributedString, str)
            XCTAssertEqual(text.count, str.count)
            XCTAssertEqual(text.fragments.count, 1)
            XCTAssertFalse(text.isEmpty)
            XCTAssertNotNil(text.fragments.first)
            XCTAssertEqual(text.fragments.first?.attributes, attrs)
            print("\"\(str)\" rendered with \(type(of: renderer)) attributes: \(attrs as Any) -> \"\(text.render())\"")
            let r = str.startIndex..<str.index(str.startIndex, offsetBy: str.count)
            XCTAssertEqual(sub.unattributedString, "\(str[r])")
            XCTAssertEqual(sub.count, str.count)
            XCTAssertEqual(sub.fragments.count, 1)
            XCTAssertFalse(sub.isEmpty)
            XCTAssertNotNil(sub.fragments.first)
            XCTAssertEqual(sub.fragments.first?.attributes, attrs)
        }

        do {
            typealias T = AdditiveArithmeticAttributes
            let attrs:T? = [.info, .error]
            let str = "\(type(of: attrs))"
            let text = AttributedText<T>(str, .info, .error)
            let sub = AttributedText<T>(str[str.startIndex..<str.endIndex], .info, .error)
            XCTAssertEqual(text.unattributedString, str)
            XCTAssertEqual(text.count, str.count)
            XCTAssertEqual(text.fragments.count, 1)
            XCTAssertFalse(text.isEmpty)
            XCTAssertNotNil(text.fragments.first)
            XCTAssertEqual(text.fragments.first?.attributes, attrs)
            print("\"\(str)\" rendered with \(type(of: renderer)) attributes: \(attrs as Any) -> \"\(text.render())\"")
            let r = str.startIndex..<str.index(str.startIndex, offsetBy: str.count)
            XCTAssertEqual(sub.unattributedString, "\(str[r])")
            XCTAssertEqual(sub.count, str.count)
            XCTAssertEqual(sub.fragments.count, 1)
            XCTAssertFalse(sub.isEmpty)
            XCTAssertNotNil(sub.fragments.first)
            XCTAssertEqual(sub.fragments.first?.attributes, attrs)
        }
        do {
            let str = ""
            let attrs:DefaultAttributes? = nil
            let text = Text()
            XCTAssertEqual(text.unattributedString, str)
            XCTAssertEqual(text.count, 0)
            XCTAssertEqual(text.fragments.count, 0)
            XCTAssertTrue(text.isEmpty)
            XCTAssertNil(text.fragments.first)
            XCTAssertNil(text.fragments.first?.attributes)
            XCTAssertNil(text.fragments.first?.range)
            print("\"\(str)\" rendered with \(type(of: renderer)) attributes: \(attrs?.traitsInEffect ?? "nil") -> \"\(text.render())\"")
        }
        do {
            let str = "#"
            let attrs:DefaultAttributes? = nil
            let text:Text = "#"
            XCTAssertEqual(text.unattributedString, str)
            XCTAssertEqual(text.count, str.count)
            XCTAssertEqual(text.fragments.count, 1)
            XCTAssertFalse(text.isEmpty)
            XCTAssertEqual(text.fragments.first?.range, str.startIndex..<str.endIndex)
            XCTAssertNil(text.fragments.first?.attributes)
            XCTAssertNotNil(text.fragments.first?.range)
            print("\"\(str)\" rendered with \(type(of: renderer)) attributes: \(attrs?.traitsInEffect ?? "nil") -> \"\(text.render())\"")
        }
        do {
            let str = "#"
            let attrs:DefaultAttributes? = nil
            let text = Text(str)
            XCTAssertEqual(text.unattributedString, str)
            XCTAssertEqual(text.count, str.count)
            XCTAssertEqual(text.fragments.count, 1)
            XCTAssertFalse(text.isEmpty)
            XCTAssertEqual(text.fragments.first?.range, str.startIndex..<str.endIndex)
            XCTAssertNil(text.fragments.first?.attributes)
            XCTAssertNotNil(text.fragments.first?.range)
            print("\"\(str)\" rendered with \(type(of: renderer)) attributes: \(attrs?.traitsInEffect ?? "nil") -> \"\(text.render())\"")
        }
        do {
            let str = "#"
            let attrs:DefaultAttributes? = [.dim, .bold, .italic, .fgColor(.red)]
            let text = Text(str, attrs)
            XCTAssertEqual(text.unattributedString, str)
            XCTAssertEqual(text.count, str.count)
            XCTAssertEqual(text.fragments.count, 1)
            XCTAssertFalse(text.isEmpty)
            XCTAssertEqual(text.fragments.first?.range, str.startIndex..<str.endIndex)
            XCTAssertNotNil(text.fragments.first?.attributes)
            XCTAssertNotNil(text.fragments.first?.range)
            XCTAssertEqual(text.fragments.first?.attributes, attrs)
            print("\"\(str)\" rendered with \(type(of: renderer)) attributes: \(attrs?.traitsInEffect ?? "nil") -> \"\(text.render())\"")
        }
        do {
            let str = "#€"
            let sub = str[str.startIndex..<str.index(after: str.startIndex)]
            let attrs:DefaultAttributes? = [.dim, .blink, .italic, .inverse, .fgColor(.green)]
            let text = Text(sub, attrs)
            XCTAssertEqual(text.unattributedString, "\(sub)")
            XCTAssertEqual(text.count, sub.count)
            XCTAssertEqual(text.fragments.count, 1)
            XCTAssertFalse(text.isEmpty)
            XCTAssertEqual(text.fragments.first?.range, sub.startIndex..<sub.endIndex)
            XCTAssertNotNil(text.fragments.first?.attributes)
            XCTAssertNotNil(text.fragments.first?.range)
            XCTAssertEqual(text.fragments.first?.attributes, attrs)
            print("\"\(sub)\" rendered with \(type(of: renderer)) attributes: \(attrs?.traitsInEffect ?? "nil") -> \"\(text.render())\"")
        }
        do {
            let str = "##"
            let attrs:DefaultAttributes? = [.bold, .italic, .fgColor(.yellow)]
            let text = Text(repeating: "#", count: 2, attributes: attrs)
            XCTAssertEqual(text.unattributedString, "\(str)")
            XCTAssertEqual(text.count, str.count)
            XCTAssertEqual(text.fragments.count, 1)
            XCTAssertFalse(text.isEmpty)
            XCTAssertNotNil(text.fragments.first?.attributes)
            XCTAssertNotNil(text.fragments.first?.range)
            XCTAssertEqual(text.fragments.first?.attributes, attrs)
            print("\"\(str)\" rendered with \(type(of: renderer)) attributes: \(attrs?.traitsInEffect ?? "nil") -> \"\(text.render())\"")
        }
        do {
            let str = "##"
            let attrs:DefaultAttributes? = nil
            let text = Text(repeating: "#", count: 2)
            XCTAssertEqual(text.unattributedString, "\(str)")
            XCTAssertEqual(text.count, str.count)
            XCTAssertEqual(text.fragments.count, 1)
            XCTAssertFalse(text.isEmpty)
            XCTAssertNil(text.fragments.first?.attributes)
            XCTAssertNotNil(text.fragments.first?.range)
            print("\"\(str)\" rendered with \(type(of: renderer)) attributes: \(attrs?.traitsInEffect ?? "nil") -> \"\(text.render())\"")
        }
        do {
            let str = "#"
            let attrs:DefaultAttributes? = nil
            let text = Text(str, attrs)
            XCTAssertEqual(text.unattributedString, str)
            XCTAssertEqual(text.count, str.count)
            XCTAssertEqual(text.fragments.count, 1)
            XCTAssertFalse(text.isEmpty)
            XCTAssertNil(text.fragments.first?.attributes)
            XCTAssertNotNil(text.fragments.first?.range)
            print("\"\(str)\" rendered with \(type(of: renderer)) attributes: \(attrs?.traitsInEffect ?? "nil") -> \"\(text.render())\"")
        }
        do {
            let str = "#"
            let attrs:DefaultAttributes? = nil
            let text = Text(str, .underlined, .bold)
            XCTAssertEqual(text.unattributedString, str)
            XCTAssertEqual(text.count, str.count)
            XCTAssertEqual(text.fragments.count, 1)
            XCTAssertFalse(text.isEmpty)
            XCTAssertNotNil(text.fragments.first?.attributes)
            XCTAssertEqual(text.fragments.first?.attributes, [.underlined, .bold])
            XCTAssertNotNil(text.fragments.first?.range)
            print("\"\(str)\" rendered with \(type(of: renderer)) attributes: \(attrs?.traitsInEffect ?? "nil") -> \"\(text.render())\"")
        }
        do {
            let str = "bolded cyan bgcolor"
            let attrs:DefaultAttributes? = nil
            let text = Text(str, .bold, .bgColor(.cyan))
            XCTAssertEqual(text.unattributedString, str)
            XCTAssertEqual(text.count, str.count)
            XCTAssertEqual(text.fragments.count, 1)
            XCTAssertFalse(text.isEmpty)
            XCTAssertNotNil(text.fragments.first?.attributes)
            XCTAssertEqual(text.fragments.first?.attributes, [.bold, .bgColor(.cyan)])
            XCTAssertNotNil(text.fragments.first?.range)
            print("\"\(str)\" rendered with \(type(of: renderer)) attributes: \(attrs?.traitsInEffect ?? "nil") -> \"\(text.render())\"")
        }
        do {
            let text:Text = ["a", "b", "c"]
            XCTAssertEqual(text.unattributedString, "abc")
            XCTAssertEqual(text.count, 3)
            XCTAssertEqual(text.fragments.count, 1)
            XCTAssertFalse(text.isEmpty)
            XCTAssertNil(text.fragments.first?.attributes)
            XCTAssertNotNil(text.fragments.first?.range)
        }
        do {
            let abc = "abc"
            let b = abc[abc.index(after: abc.startIndex)..<abc.endIndex]
            let text = Text(b, [.bold, .blink])
            XCTAssertEqual(text, Text("bc", .bold, .blink))
        }
    }
    func test_plusoperator() {
        do {
            let expected = "#hash"
            let lhs = Text("#", [.bold, .bgColor(.cyan)])
            let rhs = Text("hash", .fgColor(.red))
            let text = lhs + rhs
            XCTAssertEqual(text.unattributedString, expected)
            XCTAssertEqual(text.count, expected.count)
            //print(text.fragments)
            XCTAssertEqual(text.fragments.count, 2)
            XCTAssertNotNil(text.fragments.first?.attributes)
            XCTAssertNotNil(text.fragments.last?.attributes)
            XCTAssertEqual(text.fragments.first?.attributes, [.bold, .bgColor(.cyan)])
            XCTAssertEqual(text.fragments.last?.attributes, .fgColor(.red))
            print("\"\(lhs.render())\" + \"\(rhs.render())\" = \"\(text.render())\"")
            XCTAssertEqual(text.render(), "\u{1B}[48;5;6;1m#\u{1B}[0m\u{1B}[38;5;1mhash\u{1B}[0m")
        }
        do {
            let expected = "#hash"
            var text = Text("#", .bold)
            text += Text("hash", .fgColor(.red))
            XCTAssertEqual(text.unattributedString, expected)
            XCTAssertEqual(text.count, expected.count)
            XCTAssertEqual(text.fragments.count, 2)
            XCTAssertNotNil(text.fragments.first?.attributes)
            XCTAssertNotNil(text.fragments.last?.attributes)
            XCTAssertEqual(text.fragments.first?.attributes, .bold)
            XCTAssertEqual(text.fragments.last?.attributes, .fgColor(.red))
            XCTAssertEqual(text.render(), "\u{1B}[1m#\u{1B}[0m\u{1B}[38;5;1mhash\u{1B}[0m")
            print(text.render())
        }
        do {
            let expected = "#hash#"
            let text = Text("#", .bold) + Text("hash", .fgColor(.red), .bgColor(.white), .blink) + Text("#", .underlined)
            XCTAssertEqual(text.unattributedString, expected)
            XCTAssertEqual(text.count, expected.count)
            XCTAssertEqual(text.fragments.count, 3)
            for i in 0..<3 {
                XCTAssertNotNil(text.fragments[i].attributes)
            }
            XCTAssertEqual(text.fragments[0].attributes, .bold)
            XCTAssertEqual(text.fragments[1].attributes, [.fgColor(.red), .bgColor(.white), .blink])
            XCTAssertEqual(text.fragments[2].attributes, .underlined)
            XCTAssertEqual(text.render(), "\u{1B}[1m#\u{1B}[0m\u{1B}[38;5;1;48;5;7;5mhash\u{1B}[0m\u{1B}[4m#\u{1B}[0m")
            print(text.render())
        }
        do {
            let a = "attributed"
            let p = "plain"
            let expected = a + p
            let text:Text = Text(a, .bold) + p
            XCTAssertEqual(text.unattributedString, expected)
            XCTAssertEqual(text.count, expected.count)
            XCTAssertEqual(text.fragments.count, 2)
            XCTAssertNotNil(text.fragments[0].attributes)
            XCTAssertEqual(text.fragments[0].attributes, .bold)
            XCTAssertNil(text.fragments[1].attributes)
            XCTAssertEqual(text.render(), "\u{1B}[1mattributed\u{1B}[0mplain")
            print(text.render())
        }
        do {
            var ab = Text("a")
            ab += Text("b")
            XCTAssertEqual(ab, Text("ab"))
        }
        do {
            let ab:Text = "a" + Text("b")
            XCTAssertEqual(ab, Text("ab"))
        }
    }
    func test_appending() {
        do {
            let expected = "#hash"
            var lhs = Text("#", [.bold, .bgColor(.cyan)])
            let lhsCopy = lhs
            let rhs = Text("hash", .fgColor(.red))
            lhs.appending(rhs)
            let text = lhs
            XCTAssertEqual(text.unattributedString, expected)
            XCTAssertEqual(text.count, expected.count)
            XCTAssertEqual(text.fragments.count, 2)
            XCTAssertNotNil(text.fragments.first?.attributes)
            XCTAssertNotNil(text.fragments.last?.attributes)
            XCTAssertEqual(text.fragments.first?.attributes, [.bold, .bgColor(.cyan)])
            XCTAssertEqual(text.fragments.last?.attributes, .fgColor(.red))
            print("\"\(lhsCopy.render())\" + \"\(rhs.render())\" = \"\(text.render())\"")
            XCTAssertEqual(text.render(), "\u{1B}[48;5;6;1m#\u{1B}[0m\u{1B}[38;5;1mhash\u{1B}[0m")
        }
    }
    func test_attributes() {
        do {
            let text = Text()
            XCTAssertNil(text.attributes(text.startIndex))
            XCTAssertEqual(text.fragments.count, 0)
            XCTAssertEqual(text.render(), "")
        }
        do {
            let str = "#"
            let attrs:DefaultAttributes? = nil
            let text = Text(str)
            XCTAssertNil(text.attributes(text.startIndex))
            XCTAssertEqual(text.fragments.count, 1)
            print("\"\(str)\" rendered with \(type(of: renderer)) attributes: \(attrs?.traitsInEffect ?? "nil") -> \"\(text.render())\"")
        }
        do {
            var text = Text("#", .bold)
            text += Text("hash", .fgColor(.red))
            XCTAssertEqual(text.attributes(text.startIndex), .bold)
            XCTAssertEqual(text.attributes(text.index(after: text.startIndex)), .fgColor(.red))
            XCTAssertEqual(text.fragments.count, 2)
            print(text.render())
            print("\"\(text.unattributedString)\" rendered with \(type(of: renderer))) -> \"\(text.render())\"")
        }
        do {
            let text = Text("<", .bold) + Text("ht") + Text() + Text("ml") + Text(">", .bold)
            XCTAssertEqual(text.unattributedString, "<html>")
            XCTAssertEqual(text.fragments[0].attributes, .bold)
            XCTAssertNil(text.fragments[1].attributes)
            XCTAssertNil(text.fragments[2].attributes)
            XCTAssertEqual(text.fragments[3].attributes, .bold)
            XCTAssertEqual(text.fragments.count, 4)
            print("\"\(text.unattributedString)\" rendered with \(type(of: renderer))) -> \"\(text.render())\"")
            XCTAssertEqual(text.render(), "\u{1B}[1m<\u{1B}[0mhtml\u{1B}[1m>\u{1B}[0m")
        }
    }

    func test_defaultattributes() {
        do {
            let def = DefaultAttributes()
            XCTAssertEqual(def.rawValue, 0)
            XCTAssertEqual(def.fgColor, .default)
            XCTAssertEqual(def.bgColor, .default)
            XCTAssertEqual(def.traitsInEffect, "fgColor(default), bgColor(default)")
        }
        do {
            let def = DefaultAttributes(rawValue: Int.max)
            XCTAssertEqual(def.rawValue, Int.max)
            XCTAssertEqual(def.fgColor, .default)
            XCTAssertEqual(def.bgColor, .default)

            XCTAssertTrue(def.contains(.bold))
            XCTAssertTrue(def.contains(.dim))
            XCTAssertTrue(def.contains(.italic))
            XCTAssertTrue(def.contains(.underlined))
            XCTAssertTrue(def.contains(.blink))
            XCTAssertTrue(def.contains(.inverse))
            XCTAssertTrue(def.contains(.hidden))
            XCTAssertTrue(def.contains(.strikethrough))

            XCTAssertEqual(def.traitsInEffect, "bold, dim, italic, underlined, blink, inverse, hidden, strikethrough, fgColor(default), bgColor(default)")
        }
        do {
            let d1:DefaultAttributes = DefaultAttributes.bold
            let d2:DefaultAttributes = [DefaultAttributes.bold, DefaultAttributes.strikethrough]
            let d3:DefaultAttributes = [DefaultAttributes.bold, DefaultAttributes.fgColor(.black)]
            let d4:DefaultAttributes = [DefaultAttributes.bold, DefaultAttributes.fgColor(.black), DefaultAttributes.bgColor(.white)]
            XCTAssertNotEqual(d1, d2)
            XCTAssertNotEqual(d1, d3)
            XCTAssertNotEqual(d1, d4)
            // Last color given should be in effect, so next two should be equal
            let d5:DefaultAttributes = [DefaultAttributes.fgColor(.black), DefaultAttributes.bgColor(.white), DefaultAttributes.fgColor(.red), DefaultAttributes.bgColor(.magenta)]
            let d6:DefaultAttributes = [DefaultAttributes.fgColor(.red), DefaultAttributes.bgColor(.magenta)]
            XCTAssertEqual(d5, d6)
            XCTAssertNotEqual(d1, d5)
            XCTAssertNotEqual(d1, d6)
            // ...and these should not be equal
            let d7:DefaultAttributes = [DefaultAttributes.hidden, DefaultAttributes.fgColor(.black), DefaultAttributes.bgColor(.white), DefaultAttributes.fgColor(.red), DefaultAttributes.bgColor(.magenta)]
            let d8:DefaultAttributes = [DefaultAttributes.italic, DefaultAttributes.fgColor(.red), DefaultAttributes.bgColor(.magenta)]
            XCTAssertNotEqual(d7, d8)
            XCTAssertNotEqual(d1, d7)
            XCTAssertNotEqual(d1, d8)
        }
        do {
            print(Text("abc", .bold, .fgColor(.colorAtIndex(230)), .bgColor(.colorAtIndex(202))).render())
        }
    }
    func test_iterators() {
        let text:Text = Text("[") + Text("red", .fgColor(.red)) + Text("yellow", .fgColor(.yellow)) + Text("]")
        print(text.render())

        do {
            let expected:[(Character, DefaultAttributes?)] = [
                ("[", nil),
                ("r", .fgColor(.red)),
                ("e", .fgColor(.red)),
                ("d", .fgColor(.red)),
                ("y", .fgColor(.yellow)),
                ("e", .fgColor(.yellow)),
                ("l", .fgColor(.yellow)),
                ("l", .fgColor(.yellow)),
                ("o", .fgColor(.yellow)),
                ("w", .fgColor(.yellow)),
                ("]", nil),
            ]
            var iterator = text.attributedIterator()
            var eiter = expected.makeIterator()
            while let (chr,attr) = iterator.next(), let (echar,eattr) = eiter.next() {
                XCTAssertEqual(chr, echar)
                XCTAssertEqual(attr, eattr)
            }
            XCTAssertEqual(text.attributedIterator().reduce(0, { $0 + $1.0.utf8.count }), text.count)
            XCTAssertEqual(text.attributedIterator().reduce(0, { _ = $1; return $0 + 1 }), expected.count)
        }
        do {
            let expected:[(Substring, DefaultAttributes?)] = [
                ("[", nil),
                ("red", .fgColor(.red)),
                ("yellow", .fgColor(.yellow)),
                ("]", nil),
            ]
            var iterator = text.fragmentIterator()
            var eiter = expected.makeIterator()
            while let (sub,attr) = iterator.next(), let (estr,eattr) = eiter.next() {
                XCTAssertEqual(sub, estr)
                XCTAssertEqual(attr, eattr)
            }
            XCTAssertEqual(text.fragmentIterator().reduce(0, { _ = $1; return $0 + 1 }), text.fragments.count)
            XCTAssertEqual(text.fragmentIterator().reduce(0, { _ = $1; return $0 + 1 }), expected.count)
        }
    }

    func test_wordwrap_none() {
        do {
            let fox = "Quick     brown fox "
            let dog = "jumped over the lazy dog."
            let text = Text(fox, .underlined) + Text(dog, .inverse)

            let w = 10
            let doc = Document(text: text, width: Width(w), alignment: .topLeft, wrapping: .none)
            print(#function, doc.render(), separator: "\n")
            XCTAssertEqual(doc.render(), "\u{1B}[4mQuick     \u{1B}[0m\n\u{1B}[4mbrown fox \u{1B}[0m\n\u{1B}[7mjumped ove\u{1B}[0m\n\u{1B}[7mr the lazy\u{1B}[0m\n\u{1B}[7m dog.\u{1B}[0m     ")
        }
    }
    func test_wordwrap_char() {
        do {
            let fox = "Quick     brown fox "
            let dog = "jumped over the lazy dog."
            let text = Text(fox, .underlined) + Text(dog, .inverse)

            let w = 10
            let doc = Document(text: text, width: Width(w), alignment: .topLeft, wrapping: .char)
            print(#function, doc.render(), separator: "\n")
            XCTAssertEqual(doc.render(), "\u{1B}[4mQuick brow\u{1B}[0m\n\u{1B}[4mn fox \u{1B}[0m\u{1B}[7mjump\u{1B}[0m\n\u{1B}[7med over th\u{1B}[0m\n\u{1B}[7me lazy dog\u{1B}[0m\n\u{1B}[7m.\u{1B}[0m         ")
        }
    }
    func test_wordwrap_word() {
        do {
            let fox = "Quick     brown fox "
            let dog = "jumped over the lazy dog."
            let text = Text(fox, .underlined) + Text(dog, .inverse)

            let w = 10
            let doc = Document(text: text, width: Width(w), alignment: .topLeft, wrapping: .word)
            print(#function, doc.render(), separator: "\n")
            XCTAssertEqual(doc.render(), "\u{1B}[4mQuick\u{1B}[0m     \n\u{1B}[4mbrown fox\u{1B}[0m \n\u{1B}[7mjumped\u{1B}[0m    \n\u{1B}[7mover the\u{1B}[0m  \n\u{1B}[7mlazy dog.\u{1B}[0m ")

        }
    }
    func test_custom_word_wrapper() {
        enum CustomWordWrapper {
            // Custom wrapper will wrap at character boundary and replace
            // all spaces to underscores.
            case bind
        }
        let fox = "Quick     brown fox "
        let dog = "jumped over the lazy dog."
        let text = Text(fox, .underlined) + Text(dog, .inverse)

        let w = 10
        let fitted = text.fitText(toWidth: w, wordWrap: CustomWordWrapper.bind) { (txt, width, policy) -> [AttributedText<DefaultAttributes>] in
            XCTAssertEqual(txt, text)
            XCTAssertEqual(width, w)
            XCTAssertEqual(policy, .bind)
            switch policy {
            case .bind:
                do {
                    // Calculate auto width
                    var rrr:[Text] = []
                    var r:Text = Text()
                    var c = 0
                    for row in components(text, withMaxLength: width) {
                        for i in row.unattributedString.indices {
                            if c < width {
                                if row.unattributedString[i].isNewline {
                                    //print(#line, "\"\(r)\"")
                                    rrr.append(r)
                                    r = AttributedText()
                                    c = 0
                                }
                                else if row.unattributedString[i].isWhitespace { // Convert whitespaces to underscores
                                    //print(#line, "\"\(r)\"", row.attributes(i) ?? "nil")
                                    r.append(contentsOf: "_", attributes: row.attributes(i))
                                    c += 1
                                }
                                else {
                                    //print(#line, "\"\(r)\"", row.attributes(i) ?? "nil")
                                    r.append(row.unattributedString[i], attributes: row.attributes(i))
                                    c += 1
                                }
                            }
                            else {
                                //print(#line, "\"\(r)\"", row.attributes(i) ?? "nil")
                                rrr.append(r)
                                r = AttributedText("\(row.unattributedString[i].isNewline ? "" : String(row.unattributedString[i] == " " ? "_" : row.unattributedString[i]))", row.attributes(i))
                                c = r.count
                            }
                        }
                    }
                    if r.isEmpty == false {
                        //print(#line, "\"\(r)\"")
                        rrr.append(r)
                    }
                    return rrr
                }
            }
        }
        fitted.forEach({ print($0.render()) })
        XCTAssertEqual(fitted.map({$0.render()}),
                       ["\u{1B}[4mQuick_____\u{1B}[0m",
                        "\u{1B}[4mbrown_fox_\u{1B}[0m",
                        "\u{1B}[7mjumped_ove\u{1B}[0m",
                        "\u{1B}[7mr_the_lazy\u{1B}[0m",
                        "\u{1B}[7m_dog.\u{1B}[0m"])
    }
    func test_padhorizontally() {
        do {
            let str = "#"
            let text = Text(str, .underlined, .inverse)
            let width = 5
            let expected:[(String,Int)] = [
                ("#    ", 2),
                ("    #", 2),
                ("  #  ", 3),
                ("#    ", 2),
                ("    #", 2),
                ("  #  ", 3),
                ("#    ", 2),
                ("    #", 2),
                ("  #  ", 3),
                ("#    ", 2),
            ]
            for (i,alignment) in Alignment.allCases.enumerated() {
                let padded = text.padHorizontally(for: width, alignment)
                XCTAssertEqual(padded.unattributedString, expected[i].0)
                XCTAssertEqual(padded.fragments.count, expected[i].1)
                print(#line, "\"\(padded.unattributedString)\"")
            }
        }
        do {
            let str = "1234567890"
            let text = Text(str, .underlined, .inverse)
            let width = 5
            for alignment in Alignment.allCases {
                let padded = text.padHorizontally(for: width, alignment)
                XCTAssertEqual(padded.unattributedString, String(str.prefix(width)))
            }
        }
    }
    func test_text_render() {
        do {
            let str = "#"
            let expected:[(String,DefaultAttributes)] = [
                ("\u{1B}[1m#\u{1B}[0m", .bold          ),
                ("\u{1B}[2m#\u{1B}[0m", .dim           ),
                ("\u{1B}[3m#\u{1B}[0m", .italic        ),
                ("\u{1B}[4m#\u{1B}[0m", .underlined    ),
                ("\u{1B}[5m#\u{1B}[0m", .blink         ),
                ("\u{1B}[7m#\u{1B}[0m", .inverse       ),
                ("\u{1B}[8m#\u{1B}[0m", .hidden        ),
                ("\u{1B}[9m#\u{1B}[0m", .strikethrough ),
                ("#", .fgColor(.default) ),
                ("\u{1B}[38;5;0m#\u{1B}[0m", .fgColor(.black) ),
                ("\u{1B}[38;5;1m#\u{1B}[0m", .fgColor(.red) ),
                ("\u{1B}[38;5;2m#\u{1B}[0m", .fgColor(.green) ),
                ("\u{1B}[38;5;3m#\u{1B}[0m", .fgColor(.yellow) ),
                ("\u{1B}[38;5;4m#\u{1B}[0m", .fgColor(.blue) ),
                ("\u{1B}[38;5;5m#\u{1B}[0m", .fgColor(.magenta) ),
                ("\u{1B}[38;5;6m#\u{1B}[0m", .fgColor(.cyan) ),
                ("\u{1B}[38;5;7m#\u{1B}[0m", .fgColor(.white) ),
                ("#", .bgColor(.default) ),
                ("\u{1B}[48;5;0m#\u{1B}[0m", .bgColor(.black) ),
                ("\u{1B}[48;5;1m#\u{1B}[0m", .bgColor(.red) ),
                ("\u{1B}[48;5;2m#\u{1B}[0m", .bgColor(.green) ),
                ("\u{1B}[48;5;3m#\u{1B}[0m", .bgColor(.yellow) ),
                ("\u{1B}[48;5;4m#\u{1B}[0m", .bgColor(.blue) ),
                ("\u{1B}[48;5;5m#\u{1B}[0m", .bgColor(.magenta) ),
                ("\u{1B}[48;5;6m#\u{1B}[0m", .bgColor(.cyan) ),
                ("\u{1B}[48;5;7m#\u{1B}[0m", .bgColor(.white) ),
            ]
            for (e,a) in expected {
                let text = Text(str, a)
                let rendered = text.render()
                //print(#line, e, /*[rendered],*/ a.traitsInEffect)
                XCTAssertEqual(rendered, e)
            }
        }
        do {
            // Empty text should result to empty string (DefaultAttributes)
            XCTAssertEqual(Text().render(), "")
            // Text attributes don't match the renderer -> should result to "unrendered plain text"
            XCTAssertEqual(AttributedText<CustomAttributes>("#", .info).render(), "[CustomAttributes(rawValue: 4)]#")
            // Text attributes matches the renderer -> should result to properly rendered text
            XCTAssertEqual(AttributedText<CustomAttributes>("#", .info).render(), "[\(CustomAttributes.info)]#")
        }
        do {
            // Range render
            let a = "sub"
            let b = "range"
            let text:Text = Text(a) + Text(b)
            let r = text.index(text.startIndex, offsetBy: a.count)..<text.endIndex
            XCTAssertEqual(text.render(range: r), b)
        }
    }
    func test_collection_insertinbetween() {

        for (a,e) in [(["a"],"a"), (["a", "b"],"a.b"), (["a", "b", "c"], "a.b.c"), (["a", "b", "c", "d", "", ""],"a.b.c.d..")] {
            var arr = a
            arr.insert(inBetween: ".")
            XCTAssertEqual(arr.joined(), e)
        }
    }

    func test_document() {
        do {
            let document = AttributedDocument<DefaultAttributes>()
            document
                .append(AttributedText<DefaultAttributes>("abc", .fgColor(.yellow)))
                .append(AttributedText<DefaultAttributes>("def", .fgColor(.cyan)))
            XCTAssertEqual(document.render(), "\u{1B}[38;5;3mabc\u{1B}[0m\n\u{1B}[38;5;6mdef\u{1B}[0m")
        }
        do {
            let document = AttributedDocument<DefaultAttributes>()
            let table = Table(table: [[AttributedText("Quick brown fox jumped over the lazy dog."), AttributedText("b", .fgColor(.red))]],
                              columns: [Table.Column(width: 15, alignment: .topCenter),
                                        Table.Column(width: 3)],
                              automaticRowNumbers: true,
                              frameElements: .squared(attributes: .dim),
                              frameRenderingOptions: .all)
            document.append(table)
            //print(document.render())
            XCTAssertEqual(document.render(), "\u{1B}[2m┌\u{1B}[0m\u{1B}[2m─\u{1B}[0m\u{1B}[2m┬\u{1B}[0m\u{1B}[2m───────────────\u{1B}[0m\u{1B}[2m┬\u{1B}[0m\u{1B}[2m───\u{1B}[0m\u{1B}[2m┐\u{1B}[0m\n\u{1B}[2m│\u{1B}[0m1\u{1B}[2m│\u{1B}[0mQuick brown fox\u{1B}[2m│\u{1B}[0m\u{1B}[38;5;1mb\u{1B}[0m  \u{1B}[2m│\u{1B}[0m\n\u{1B}[2m│\u{1B}[0m \u{1B}[2m│\u{1B}[0mjumped over the\u{1B}[2m│\u{1B}[0m   \u{1B}[2m│\u{1B}[0m\n\u{1B}[2m│\u{1B}[0m \u{1B}[2m│\u{1B}[0m   lazy dog.   \u{1B}[2m│\u{1B}[0m   \u{1B}[2m│\u{1B}[0m\n\u{1B}[2m└\u{1B}[0m\u{1B}[2m─\u{1B}[0m\u{1B}[2m┴\u{1B}[0m\u{1B}[2m───────────────\u{1B}[0m\u{1B}[2m┴\u{1B}[0m\u{1B}[2m───\u{1B}[0m\u{1B}[2m┘\u{1B}[0m")
        }
    }
    func test_expressiblebystringliteral() {
        do {
            let text:AttributedText<DefaultAttributes> = "abc"
            XCTAssertEqual(text, AttributedText<DefaultAttributes>("abc"))
        }
        do {
            let text:AttributedText<CustomAttributes> = "abc"
            XCTAssertEqual(text, AttributedText<CustomAttributes>("abc"))
        }
    }

    func test_rangereplaceablecollection() {
        do { // init(repeating repeatedValue: Character, count:Int, attributes:Attributes? = nil)
            let c = 3
            let char:Character = "#"
            let str = String(repeating: char, count: c)
            let l = Text(str, .dim)
            let r1 = Text(repeating: char, count: c, attributes: .dim)
            let r2 = Text(repeating: char, count: c)
            XCTAssertEqual(l, r1)
            XCTAssertNotEqual(l, r2)
            XCTAssertEqual(str, r1.unattributedString)
            XCTAssertEqual(str, r2.unattributedString)
            XCTAssertEqual(r1.fragments.count, 1)
            XCTAssertEqual(r1.fragments.first?.attributes, .dim)
            XCTAssertNil(r2.fragments.first?.attributes)
            XCTAssertEqual(Text(repeating: char, count: 0), Text())
            XCTAssertEqual(Text(repeating: char, count: 0, attributes: .dim), Text())
        }
        do { // init<S>(_ elements: S, _ attributes:Attributes? = nil) where S: Sequence, Self.Element == S.Element
            let arr:[Character] = ["a", "b", "c"]
            let t1 = Text(arr)
            let t2 = Text(arr, .bold)
            XCTAssertEqual(t1, Text("abc"))
            XCTAssertEqual(t2, Text("abc", .bold))
        }
        do { // mutating func append(_ newElement: Self.Element, attributes:Attributes? = nil)
            var l = Text("a")
            let r1 = Text("ab")
            let r2 = Text("ab") + Text("c", .dim)
            l.append(Character("b"))
            XCTAssertEqual(l, r1)
            l.append(Character("c"), attributes: .dim)
            XCTAssertEqual(l, r2)
        }
        do { // mutating func append<S>(contentsOf newElements: S, attributes:Attributes? = nil) where S: Sequence, Self.Element == S.Element
            var l = Text("#")
            let arr:[Character] = ["a", "b", "c"]
            let r1 = Text("#abc")
            let r2 = Text("#abc") + Text("abc", .dim)
            l.append(contentsOf: arr)
            XCTAssertEqual(l, r1)
            l.append(contentsOf: arr, attributes: .dim)
            XCTAssertEqual(l, r2)
        }
        do { // mutating func insert(_ newElement: Self.Element, at i: Self.Index, attributes:Attributes? = nil)
            var l = Text()
            l.insert("#", at: l.startIndex, attributes: nil)
            l.insert(Character("a"), at: l.startIndex)
            let r1 = Text("a#")
            XCTAssertEqual(l, r1)
            l.insert("!", at: l.endIndex)
            let r2 = Text("a#!")
            XCTAssertEqual(l, r2)
            l.insert(" ", at: l.index(l.startIndex, offsetBy: 2), attributes: .dim)
            let r3 = Text("a#") + Text(" ", .dim) + Text("!")
            XCTAssertEqual(l, r3)
            var r4 = r3
            let c = r4.remove(at: r4.index(after: r4.startIndex))
            XCTAssertEqual(c, "#")
        }
        do { // mutating func insert(_ newElement: Self.Element, at i: Self.Index, attributes:Attributes? = nil)
            var head = "abc"
            let insert:Character = "#"
            var text = Text(head)
            text.insert(insert, at: head.index(after: head.startIndex), attributes: .blink)
            head.insert(insert, at: head.index(after: head.startIndex))
            XCTAssertEqual(text, Text("a") + Text("\(insert)", .blink) + Text("bc"))
        }
        do { // mutating func insert<S>(contentsOf newElements: S, at i: Self.Index, attributes:Attributes? = nil) where S: Collection, Self.Element == S.Element
            let arr:[Character] = ["a", "b", "c"]
            var l = Text("#")
            l.insert(contentsOf: arr, at: l.startIndex)
            let r1 = Text("abc#")
            XCTAssertEqual(l, r1)
            l.insert(contentsOf: arr, at: l.endIndex)
            let r2 = Text("abc#abc")
            XCTAssertEqual(l, r2)
            l.insert(contentsOf: arr, at: l.index(l.startIndex, offsetBy: 2), attributes: .dim)
            let r3 = Text("ab") + Text("abc", .dim) + Text("c#abc")
            XCTAssertEqual(l, r3)
        }
        do { // mutating func remove(at i: Self.Index) -> Self.Element
            var l = Text("ab") + Text("c", .dim)
            let r1 = Text("a") + Text("c", .dim)
            let c1 = l.remove(at: l.index(after: l.startIndex))
            XCTAssertEqual(l, r1)
            XCTAssertEqual(Character("b"), c1)
            let r2 = Text("c", .dim)
            let c2 = l.remove(at: l.startIndex)
            XCTAssertEqual(l, r2)
            XCTAssertEqual(Character("a"), c2)
            let r3 = Text()
            let c3 = l.remove(at: l.index(before: l.endIndex))
            XCTAssertEqual(l, r3)
            XCTAssertEqual(c3, "c")
        }
        do { // mutating func removeAll(keepingCapacity keepCapacity: Bool)
            var l1 = Text("abc", .dim)
            var l2 = Text("abc", .dim)
            l1.removeAll(keepingCapacity: false)
            l2.removeAll(keepingCapacity: true)
            XCTAssertEqual(l1, Text())
            XCTAssertEqual(l2, Text())
        }
        do { // mutating func removeAll(where shouldBeRemoved: (Self.Element) throws -> Bool) rethrows
            var l1 = Text("#a") + Text("abca", .dim) + Text("+a", .fgColor(.yellow))
            var l2 = Text("abcb")
            l1.removeAll(where: { $0 == "a" })
            l2.removeAll(where: { $0 == "b" })
            XCTAssertEqual(l1, Text("#") + Text("bc", .dim) + Text("+", .fgColor(.yellow)))
            XCTAssertEqual(l2, Text("ac"))
        }
        do { // mutating func removeFirst() -> Self.Element
            var l1 = Text("abc", .dim)
            var l2 = Text("abc")
            let c1 = l1.removeFirst()
            let c2 = l2.removeFirst()
            XCTAssertEqual(l1, Text("bc", .dim))
            XCTAssertEqual(l2, Text("bc"))
            XCTAssertEqual(c1, "a")
            XCTAssertEqual(c2, "a")
        }
        do { // mutating func removeFirst(_ k: Int)
            var l1 = Text("abc", .dim)
            var l2 = Text("abc")
            l1.removeFirst(1)
            l2.removeFirst(2)
            XCTAssertEqual(l1, Text("bc", .dim))
            XCTAssertEqual(l2, Text("c"))
        }
        do { // mutating func reserveCapacity(_ n: Int)
            var l1 = Text("abc", .dim)
            l1.reserveCapacity(1000)
            XCTAssertEqual(l1, Text("abc", .dim)) // no-op
            XCTAssertEqual(l1.fragments.count, 1)
        }
        do { // mutating func replaceSubrange<C:Collection>(_ subrange:Range<StringLiteralType.Index>, with newElements: C) where C.Element == Character
            var l = Text("[")
            print(l.render())
            l.replaceSubrange(l.endIndex..., with: Text("red", .fgColor(.red)) + Text("]"))
            print(l.render())
            XCTAssertEqual(l, Text("[") + Text("red", .fgColor(.red)) + Text("]"))

            l.replaceSubrange(l.index(after: l.startIndex)..<l.index(before: l.endIndex),
                              with: Text("element", .fgColor(.black), .bgColor(.yellow)))
            print(l.render())
            XCTAssertEqual(l, Text("[") + Text("element", .fgColor(.black), .bgColor(.yellow)) + Text("]"))

            l.replaceSubrange(...l.startIndex, with: Text("<"))
            l.replaceSubrange(l.index(before: l.endIndex)..<l.endIndex, with: Text(">"))
            print(l.render())
            XCTAssertEqual(l, Text("<") + Text("element", .fgColor(.black), .bgColor(.yellow)) + Text(">"))

            guard let idx = l.firstIndex(of: "m") else {
                XCTFail()
                return
            }
            l.replaceSubrange(idx..<idx, with: Text("-"))
            print(l.render())
            XCTAssertEqual(l,
                           Text("<") +
                            Text("ele", .fgColor(.black), .bgColor(.yellow)) +
                            Text("-") +
                            Text("ment", .fgColor(.black), .bgColor(.yellow)) +
                            Text(">"))

            l.replaceSubrange(idx..<l.index(after:idx), with: Array<Character>())
            print(l.render())
            XCTAssertEqual(l,
                           Text("<") +
                            Text("ele", .fgColor(.black), .bgColor(.yellow)) +
                            Text("ment", .fgColor(.black), .bgColor(.yellow)) +
                            Text(">"))
            l.replaceSubrange(l.startIndex..., with: CollectionOfOne<Character>("!"))
            print(l.render())
            XCTAssertEqual(l, Text("!"))
            l.replaceSubrange(l.startIndex..., with: Set<Character>())
            print(l.render())
            XCTAssertEqual(l, Text())
        }
        do {
            var text = Text("abc")
            text.replaceSubrange(text.startIndex..<text.index(before: text.endIndex),
                                 with: Text("x"))
        }
    }
    func test_textoutputstreamable() {
        let str = "abc"
        let text = Text(str) + Text(str, .dim)
        var stream:String = ""
        text.write(to: &stream)
        XCTAssertEqual(stream, str + str)
    }

    func test_cellalignmentoverride() {
        let usage = Text("Usage: ...")
        let table:[[Text]] = [
            [Text("Short", .bold), Text("Long Option Name", .bold), Text("Description", .bold)],
            ["-D", "--debug", "Enable debug mode."],
            [],
            ["-L", "--log", "Log to file."],
        ]
        let doc = Document()
        doc.append(usage)
        doc.append(Table(table: table,
                         columns: [Table.Column(width: 5), .init(width: 12), .init(width: .auto)],
                         automaticRowNumbers: false,
                         frameElements: .singleSpace,
                         frameRenderingOptions: .insideVerticalFrame) { (row, column) -> Table.Cell in
            return row == 0 ? Table.Cell(alignment: .bottomLeft, wordWrapping: .word) : Table.Cell(alignment: .topLeft, wordWrapping: .word)
        })
        doc.append(attributed: Text("NOTE: This is BETA."),
                   width: 8,
                   alignment: .middleCenter,
                   wrapping: .word)
        print(doc.render(
            sectionHeader: { _ = $1; return Text("Start \($0)\n", .fgColor(.magenta), .dim).render() },
            sectionFooter: { _ = $1; return Text("End \($0)\n", .fgColor(.green), .dim).render() }
            )
        )
    }
    func test_emptysource() {
        // TODO: Fix empty source.
        // let table:[[Text]] = [[], []]
        // will NOT produce a table with two empty rows.
        // Workaround is to include at least one empty string in the data
        // and then empty rows are created correctly.
        // let table:[[Text]] = [[""], []]
        let table:[[Text]] = [[], []]
        let str = Document().append(Table(table: table,
                                          columns: [],
                                          automaticRowNumbers: true,
                                          frameElements: .squared(attributes: .dim),
                                          frameRenderingOptions: .all) { (r, c) -> Table.Cell in
            Table.Cell(alignment: .topLeft)
        }).render()
        XCTAssertEqual(str, "")
    }
    // TODO: Re-enable
    /*
    func test_textdirection() {
        do {
            struct RightToLeftRenderer:RendererProtocol {
                func render<Attributes:AttributeProtocol>(_ attributed: AttributedText<Attributes>) -> String {
                    var str = ""
                    for fragment in attributed.fragmentIterator().reversed() {
                        if let attributes = fragment.1 as? DefaultAttributes {
                            str.append("\(String(fragment.0.reversed()), attributes: attributes)")
                        }
                        else {
                            str.append(String(fragment.0.reversed()))
                        }
                    }
                    return str
                }
            }

            let text_lr = Text("Supports\nleft-to-right and ", .fgColor(.yellow))
            let text_rl = Text("right-to-left text directions.", .fgColor(.green))
            let text = text_lr + text_rl
            let doc = Document()
            doc.append(Table(table: [[text, text]], columns: [Table.Column(width: 15, wrapping: .word), Table.Column(width: 15, wrapping: .none)], automaticRowNumbers: false, frameElements: .ascii, frameRenderingOptions: .all))
            print("\(DefaultAttributeRenderer.self)", doc.render(with: DefaultAttributeRenderer()), separator: "\n")
            print("\(RightToLeftRenderer.self)", doc.render(with: RightToLeftRenderer()), separator: "\n")
            XCTAssertEqual(doc.render(with: RightToLeftRenderer()), "+---------------+---------------+\n|       \u{1B}[38;5;3mstroppuS\u{1B}[0m|       \u{1B}[38;5;3mstroppuS\u{1B}[0m|\n|  \u{1B}[38;5;3mthgir-ot-tfel\u{1B}[0m|\u{1B}[38;5;3ma thgir-ot-tfel\u{1B}[0m|\n|            \u{1B}[38;5;3mdna\u{1B}[0m|\u{1B}[38;5;2mfel-ot-thgir\u{1B}[0m\u{1B}[38;5;3m dn\u{1B}[0m|\n|  \u{1B}[38;5;2mtfel-ot-thgir\u{1B}[0m|\u{1B}[38;5;2moitcerid txet t\u{1B}[0m|\n|           \u{1B}[38;5;2mtxet\u{1B}[0m|            \u{1B}[38;5;2m.sn\u{1B}[0m|\n|    \u{1B}[38;5;2m.snoitcerid\u{1B}[0m|               |\n+---------------+---------------+")
        }
    }*/
    // MARK: -
    // MARK: Collection
    func test_collection() {
        let head = "a"
        let tail = "b"
        let text = Text(head) + Text(tail, .dim)
        do { // Count
            XCTAssertEqual(Text().count, 0)
            XCTAssertEqual(Text("").count, 0)
            XCTAssertEqual(text.count, 2)
        }
        do { // index(after:)
            let str = "1234567890"
            let t = Text(str)
            for (il,ir) in zip(str.indices,t.indices) {
                XCTAssertEqual(str.index(after: il), t.index(after: ir))
            }
        }
        do { // subscript(bounds:)
            let str = "1234567890"
            let t = Text(str)
            for i in 1..<str.count {
                let l = str.startIndex..<str.index(str.startIndex, offsetBy: i)
                let r = t.startIndex..<t.index(t.startIndex, offsetBy: i)
                XCTAssertEqual(String(str[l]), t[r].unattributedString)
            }
        }
        do { // subscript(position:)
            let str = "1234567890"
            let t = Text(str)
            for i in 0..<str.count {
                XCTAssertEqual(str.index(str.startIndex, offsetBy: i),
                               t.index(str.startIndex, offsetBy: i))
            }
        }
        do { // startIndex
            let str = "1234567890"
            let t = Text(str)
            XCTAssertEqual(str.startIndex, t.startIndex)
        }
        do { // endIndex
            let str = "1234567890"
            let t = Text(str)
            XCTAssertEqual(str.endIndex, t.endIndex)
        }
    }
    // MARK: -
    // MARK: BidirectionalCollection
    func test_bidirectionalcollection() {
        do { // index(before:)
            let str = "1234567890"
            let t = Text(str)
            for (il,ir) in zip(str.indices.dropFirst(),t.indices.dropFirst()) {
                XCTAssertEqual(str.index(before: il), t.index(before: ir))
            }
        }
    }
    func test_attributedtable() {
        do {
            let doc = Document(text: Text("Quick brown fox jumped over the lazy dog."), width: 10, alignment: .topLeft, wrapping: .none)
            XCTAssertEqual(doc.render(), [
                "Quick brow",
                "n fox jump",
                "ed over th",
                "e lazy dog",
                ".         "
            ].joined(separator: "\n"))
            doc.append(attributed: Text("Quick brown fox jumped over the lazy dog."), width: 10, alignment: .topLeft, wrapping: .char)
            doc.append(attributed: Text("Quick brown fox jumped over the lazy dog."), width: 10, alignment: .topLeft, wrapping: .word)
            doc.append(Text("Quick brown fox jumped over the lazy dog."))
            doc.append(unattributed: "Plain string aligned to bottom right.", width: 8, alignment: .bottomRight, wrapping: .char)
            print(doc.render())
            for rendable in doc {
                print(#line, rendable.render())
            }
        }
    }
    func test_prefix_suffix() {
        do {
            let head = "abc"
            let tail = "def"
            let unattr = head + tail
            let text = Text(head) + Text(tail, .dim)
            let expected:[(Int,[DefaultAttributes?],Int,[DefaultAttributes?])] = [
                (0, [],         0, []),
                (1, [nil],      1, [.dim]),
                (1, [nil],      1, [.dim]),
                (1, [nil],      1, [.dim]),
                (2, [nil,.dim], 2, [nil,.dim]),
                (2, [nil,.dim], 2, [nil,.dim]),
                (2, [nil,.dim], 2, [nil,.dim]),
            ]
            for (i,(pfc,pattr, sfc,sattr)) in expected.enumerated() {
                let ep = unattr.prefix(i)
                let es = unattr.suffix(i)
                let prefix = text.prefix(i)
                let suffix = text.suffix(i)
                XCTAssertEqual(String(ep), prefix.unattributedString)
                XCTAssertEqual(prefix.fragments.count, pfc)
                XCTAssertEqual(prefix.fragments.map { $0.attributes }, pattr)
                XCTAssertEqual(String(es), suffix.unattributedString)
                XCTAssertEqual(suffix.fragments.count, sfc)
                XCTAssertEqual(suffix.fragments.map { $0.attributes }, sattr)
            }
            XCTAssertEqual(text.prefix(while: { $0 != "f" }), Text("abc") + Text("de", .dim))
            XCTAssertEqual(text.suffix(from: text.index(text.startIndex, offsetBy: 2)), Text("c") + Text("def", .dim))
        }
    }
    // MARK: Equatable
    func test_equatable() {
        let head = "abc"
        let tail = "def"
        let unattr = head + tail
        let text = Text(head) + Text(tail, .dim)
        XCTAssertEqual(text, text)
        XCTAssertNotEqual(text, Text(head + tail))
        XCTAssertNotEqual(text, Text(head, .dim) + Text(tail))
        let c = Text("x", .underlined, .fgColor(.white), .bgColor(.black))
        XCTAssertNotEqual(text + c, Text(unattr + "x", .underlined, .fgColor(.white), .bgColor(.black)))
        XCTAssertEqual(text + c, Text(head) + Text(tail, .dim) + Text("x", .underlined, .fgColor(.white), .bgColor(.black)))
    }
    func test_drops() {
        do {
            let first = Text("abc") + Text("def", .dim)
            XCTAssertEqual(first.dropFirst(), Text("bc") + Text("def", .dim))
            let last = Text("abc") + Text("def", .dim)
            XCTAssertEqual(last.dropLast(), Text("abc") + Text("de", .dim))
        }
        do {
            let text = Text("abc") + Text("def", .dim)
            let expected:[(String,Int,[DefaultAttributes?],String,Int,[DefaultAttributes?])] = [
                ("abcdef", 2, [nil,.dim], "abcdef", 2, [nil,.dim]),
                ("bcdef", 2, [nil,.dim], "abcde", 2, [nil,.dim]),
                ("cdef", 2, [nil,.dim], "abcd", 2, [nil,.dim]),
                ("def", 1, [.dim], "abc", 1, [nil]),
                ("ef", 1, [.dim], "ab", 1, [nil]),
                ("f", 1, [.dim], "a", 1, [nil,]),
                ("", 0, [], "", 0, []),
            ]
            for (i,(pe,pfc,pattr, se, sfc,sattr)) in expected.enumerated() {
                let prefix = text.dropFirst(i)
                let suffix = text.dropLast(i)
                XCTAssertEqual(prefix.unattributedString, pe)
                XCTAssertEqual(prefix.fragments.count, pfc)
                XCTAssertEqual(prefix.fragments.map { $0.attributes }, pattr)
                XCTAssertEqual(suffix.unattributedString, se)
                XCTAssertEqual(suffix.fragments.count, sfc)
                XCTAssertEqual(suffix.fragments.map { $0.attributes }, sattr)
            }
        }
    }
    func test_code_coverage() {
        do {
            let foo = fit(Text("\n\n\n"), toWidth: 2, wordWrap: .char)
            XCTAssertEqual(foo, ["","", ""])
        }
    }
    static var allTests = [
        ("test_attributedtextinit", test_attributedtextinit),
        ("test_plusoperator", test_plusoperator),
        ("test_appending", test_appending),
        ("test_attributes", test_attributes),
        ("test_defaultattributes", test_defaultattributes),
        ("test_iterators", test_iterators),
        ("test_wordwrap_none", test_wordwrap_none),
        ("test_wordwrap_char", test_wordwrap_char),
        ("test_wordwrap_word", test_wordwrap_word),
        ("test_custom_word_wrapper", test_custom_word_wrapper),
        ("test_padhorizontally", test_padhorizontally),
        ("test_text_render", test_text_render),
        ("test_collection_insertinbetween", test_collection_insertinbetween),
        ("test_document", test_document),
        ("test_expressiblebystringliteral", test_expressiblebystringliteral),
        ("test_rangereplaceablecollection", test_rangereplaceablecollection),
        ("test_textoutputstreamable", test_textoutputstreamable),
        ("test_cellalignmentoverride", test_cellalignmentoverride),
        ("test_emptysource", test_emptysource),
        //("test_textdirection", test_textdirection),
        ("test_collection", test_collection),
        ("test_bidirectionalcollection", test_bidirectionalcollection),
        ("test_attributedtable", test_attributedtable),
        ("test_prefix_suffix", test_prefix_suffix),
        ("test_equatable", test_equatable),
        ("test_drops", test_drops),
        ("test_code_coverage", test_code_coverage),
    ]
}
