
public class AttributedDocument<Attributes:AttributeProtocol> : Rendable {
    public typealias Element = Array<Rendable>.Element
    // MARK: -
    private struct SectionProperties {
        let layout: [[[AttributedText<Attributes>]]]
        let title:Title<Attributes>?
        let calculatedWidths: [Width]?
        let providedStaticCellProperties: [Column<Attributes>]?
        let automaticRowNumbers: Bool
        let frameElements: FrameElements<Attributes>?
        let frameRenderingOptions: FrameRenderingOptions
        let cellPropertyClosure:((Int, Int, Int)->Cell)?
    }
    private var rendables:[Rendable] = []
    private var sections:[SectionProperties] = []
    // MARK: -
    // MARK: Public
    required public init() {}
    // MARK: -
    public init(_ rendable: Rendable) {
        self.rendables.append(rendable)
    }
    public init(text: AttributedText<Attributes>, width: Width = .auto, alignment: Alignment = .topLeft, wrapping: WordWrap = .none) {
        append(attributed: text, width: width, alignment: alignment, wrapping: wrapping)
    }
    public convenience init(unattributed text: String, width: Width = .auto, alignment: Alignment = .topLeft, wrapping: WordWrap = .none) {
        self.init(text: AttributedText<Attributes>(text), width: width, alignment: alignment, wrapping: wrapping)
    }
    @discardableResult
    public func append(_ rendable: Rendable) -> Self {
        self.rendables.append(rendable)
        return self
    }
    @discardableResult
    public func append(attributed text: AttributedText<Attributes>, width: Width = .auto, alignment: Alignment = .topLeft, wrapping: WordWrap = .none) -> Self {
        // Wrap it inside a table
        let column = AttributedTable<Attributes>.Column<Attributes>(nil, width: width, alignment: alignment, wrapping: wrapping)
        let table = AttributedTable<Attributes>(table: [[text]],
                                                title: nil,
                                                columns: [column],
                                                automaticRowNumbers: false,
                                                frameElements: .default,
                                                frameRenderingOptions: .none,
                                                cellProperty: nil)
        append(table)
        return self
    }
    @discardableResult
    public func append(unattributed text: String, width: Width = .auto, alignment: Alignment = .topLeft, wrapping: WordWrap = .none) -> Self {
        append(attributed: AttributedText<Attributes>(text), width: width, alignment: alignment, wrapping: wrapping)
        return self
    }
    // MARK: -
    // MARK: Public
    public func render() -> String {
        self.render(sectionHeader: nil, sectionFooter: nil)
    }
    public func render(sectionHeader:((Int,Int) -> String)? = nil,
                       sectionFooter:((Int,Int) -> String)? = nil) -> String {
        var str:[String] = []
        for index in rendables.indices {

            let rendered = rendables[index].render()
            if let closure = sectionHeader {
                str.append(closure(index, sections.count))
            }
            str.append(rendered)
            if let closure = sectionFooter {
                str.append(closure(index, sections.count))
            }
        }
        return str.joined(separator: "\n")
    }

    public func render(section index:Int,
                       sectionHeader:((Int,Int) -> String)? = nil,
                       sectionFooter:((Int,Int) -> String)? = nil) -> String? {
        guard (rendables.startIndex..<rendables.endIndex).contains(index) else {
            return nil
        }
        var str = ""
        let rendered = rendables[index].render()
        if let closure = sectionHeader {
            str.append(closure(index, rendables.count))
        }
        str.append(rendered)
        if let closure = sectionFooter {
            str.append(closure(index, rendables.count))
        }
        return str
    }
    // MARK: -
    // MARK: Private
    private func equalizeElementCount(table source:[[AttributedText<Attributes>]]) -> [[AttributedText<Attributes>]] {
        var copy = source
        let maxElementCount = copy.reduce(0, { Swift.max($0, $1.count) })
        for i in copy.indices {
            if copy[i].count < maxElementCount {
                for _ in 1...(maxElementCount - copy[i].count) {
                    copy[i].append(.init())
                }
            }
        }
        return copy
    }
    // MARK: -
    // MARK: Public types
    public struct Cell : Equatable {
        var alignment:Alignment     = .topLeft
        var wordWrapping:WordWrap   = .none
    }
    public struct Column<Attributes:AttributeProtocol> {
        public let header:Header<Attributes>?
        public let width:Width
        public let cell:Cell
        public init(_ header:Header<Attributes>? = nil, width:Width = .auto, alignment:Alignment = .topLeft, wrapping:WordWrap = .word) {
            self.header = header
            self.cell = Cell(alignment: alignment, wordWrapping: wrapping)
            self.width = width
        }
    }
    public struct Header<Attributes:AttributeProtocol> : ExpressibleByStringLiteral {
        public typealias StringLiteralType = String
        public let text:AttributedText<Attributes>
        public let cell:Cell
        public init(stringLiteral: StringLiteralType) {
            self.init(AttributedText<Attributes>(stringLiteral))
        }
        public init(_ text:AttributedText<Attributes>, alignment:Alignment = .topLeft, wrapping:WordWrap = .word) {
            self.text = text
            self.cell = Cell(alignment: alignment, wordWrapping: wrapping)
        }
    }
    public typealias Title = Header
}
// MARK: -
// MARK: Collection, RandomAccessCollection
extension AttributedDocument : Collection, RandomAccessCollection {
    public typealias Index = Array<Rendable>.Index
    public func index(after i: Index) -> Index {
        rendables.index(after: i)
    }

    public subscript(position: Index) -> Rendable {
        return self.rendables[position]
    }
    public var count: Int {
        rendables.count
    }
    public var startIndex: Index {
        rendables.startIndex
    }
    public var endIndex: Index {
        rendables.endIndex
    }
}
// MARK: -
// MARK: BidirectionalCollection
extension AttributedDocument : BidirectionalCollection {
    public func index(before i: Array<Rendable>.Index) -> Array<Rendable>.Index {
        rendables.index(before: i)
    }
}
// MARK: -
// MARK: RangeReplaceableCollection
extension AttributedDocument : RangeReplaceableCollection {
    public func replaceSubrange<C>(_ subrange: Range<Array<Rendable>.Index>, with newElements: C) where C : Collection, Element == C.Element {
        rendables.replaceSubrange(subrange, with: newElements)
    }
}
// MARK: -
public enum WordWrap : CaseIterable { case none, char, word }
public enum Alignment : CaseIterable {
    case topLeft, topRight, topCenter
    case bottomLeft, bottomRight, bottomCenter
    case middleLeft, middleRight, middleCenter
    case auto
}
public struct Width : ExpressibleByIntegerLiteral, Equatable, Comparable, CustomStringConvertible, Hashable {
    public typealias IntegerLiteralType = Int
    var value:Int = -1 // Auto
    public init(_ integerValue:Int) {
        precondition(value >= -1, "must be > 0 or .hidden or .auto. Got \(value).")
        self.value = integerValue//.init(integerLiteral: value)
    }
    public init(integerLiteral value: Int) {
        self = .init(value)
    }
    public static func < (lhs: Width, rhs: Width) -> Bool {
        lhs.value < rhs.value
    }
    public var description: String {
        switch value {
        case -1: return "auto"
        case 0: return "hidden"
        default: return "\(value)"
        }
    }
    public static var auto:Width {
        return Width(-1)
    }
    public static var hidden:Width {
        return Width(0)
    }
}
// MARK: -
// MARK: TextOutputStreamable
extension AttributedDocument : TextOutputStreamable {
    public func write<Target>(to target: inout Target) where Target : TextOutputStream {
        target.write(self.render())
    }
}
// MARK: -
// MARK: Private extensions
internal extension Array where Element: RangeReplaceableCollection, Element.Element:Collection {
    func transposed() -> [[Self.Iterator.Element.Iterator.Element]] {
        guard let firstRow = self.first else { return [] }
        return firstRow.indices.map { index in
            self.map{ $0[index] }
        }
    }
}
