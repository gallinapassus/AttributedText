public struct AttributedText<Attributes:AttributeProtocol> : Rendable {

    public typealias StringLiteralType = String
    // MARK: -
    // MARK: Public vars
    private (set) public var unattributedString:StringLiteralType = ""
    public var isEmpty: Bool {
        unattributedString.isEmpty
    }
    // MARK: -
    // MARK: Internal vars
    private (set) internal var fragments:[(range: Range<StringLiteralType.Index>, attributes: Attributes?)] = []
    // MARK: -
    // MARK: init
    public init() {}
    public init(_ string:String, _ attributes:Attributes?) {
        self.unattributedString = string
        self.fragments = [(string.startIndex..<string.endIndex, attributes)]
    }
    public init(_ string:Substring, _ attributes:Attributes?) {
        self.unattributedString = String(string)
        self.fragments = [(unattributedString.startIndex..<unattributedString.endIndex, attributes)]
    }
    private init(string:String, fragments: [(range: Range<StringLiteralType.Index>, attributes: Attributes?)]) {
        self.unattributedString = string
        self.fragments = fragments
    }
    // MARK: Accessing style
    public func attributes(_ index:StringLiteralType.Index) -> Attributes? {
        fragments.first(where: { $0.range.contains(index) })?.attributes
    }
    public func attributedIterator() -> IndexingIterator<Array<(Character, Attributes?)>> {
        unattributedString.indices.map { (unattributedString[$0], attributes($0)) }.makeIterator()
    }
    public func fragmentIterator() -> IndexingIterator<Array<(Substring, Attributes?)>> {
        fragments.map { (unattributedString[$0.range], $0.attributes) }.makeIterator()
    }
    // MARK: Concatenating/Adding
    internal mutating func appending(_ other:Self) {
        // Quick wins
        guard other.isEmpty == false else {
            return
        }
        guard self.isEmpty == false else {
            self = other
            return
        }
        //
        for (index,(range,style)) in other.fragments.enumerated() {
            // NOTE: Equatable requirement for Attributes
            if index == 0,
               style == self.fragments.last?.attributes {
                let start = self.unattributedString.endIndex
                self.unattributedString.append(String(other.unattributedString[range]))
                let end = self.unattributedString.endIndex

                if let lastIndex = self.fragments.indices.last, let attr = self.fragments[lastIndex].attributes,
                   attr == style {
                    let origStart = self.fragments[lastIndex].range.lowerBound
                    self.fragments[lastIndex].range = origStart..<end
                }
                else {
                    self.fragments.append((start..<end, style))
                }
            }
            else {
                let s = self.unattributedString.endIndex
                self.unattributedString.append(String(other.unattributedString[range]))
                let e = self.unattributedString.endIndex
                self.fragments.append((s..<e, style))
            }
        }
    }
    private mutating func appending(_ substring:Substring, _ attributes:Attributes? = nil) {
        guard substring.isEmpty == false else {
            return
        }
        guard self.isEmpty == false else {
            self = .init(String(substring), attributes)
            return
        }
        let s = unattributedString.endIndex
        self.unattributedString.append(String(substring))
        let e = unattributedString.endIndex
        self.fragments.append((s..<e, attributes))
    }
    private mutating func appending(_ character:Self.Element, _ attributes:Attributes? = nil) {
        let s = unattributedString.endIndex
        unattributedString.append(character)
        let e = unattributedString.endIndex

        let lastValidIndex = fragments.index(before: fragments.endIndex)
        if lastValidIndex >= 0 {
            let lastAttributes = fragments[lastValidIndex].attributes
            // NOTE: Equatable requirement for Attributes
            if attributes == lastAttributes { // Extend the range (continue with same attributes)
                fragments[lastValidIndex].range = fragments[lastValidIndex].range.lowerBound..<e
            }
            else { // Create new fragment
                fragments.append((range: s..<e, attributes: attributes))
            }
        }
        else {
            fragments.append((range: s..<e, attributes: attributes))
        }
    }
    public static func +(lhs:Self, rhs:Self) -> Self {
        var l = lhs
        l.appending(rhs)
        return l
    }
    public static func +=(lhs:inout Self, rhs:Self) {
        lhs.appending(rhs)
    }
    public static func + <S:ExpressibleByStringInterpolation&Sequence>(lhs:Self, rhs:S) -> Self where S.Element == Self.Element {
        var l = lhs
        l.appending(Self(rhs))
        return l
    }
    public static func + <S:ExpressibleByStringInterpolation&Sequence>(lhs:S, rhs:Self) -> Self where S.Element == Self.Element {
        var l = Self(lhs)
        l.appending(rhs)
        return l
    }
    // MARK: Support for custom wrappers
    public func fitText<WordWrapping>(toWidth:Int, wordWrap:WordWrapping, custom wrapper:(Self,Int,WordWrapping) -> [Self]) -> [Self] {
        wrapper(self, toWidth, wordWrap)
    }
    // MARK: Padding
    public func padHorizontally(for width:Int, _ alignment:Alignment) -> Self {
        guard width > unattributedString.count else {
            return self.prefix(width)
        }
        let padAmount = Swift.max(0, width - unattributedString.count)
        switch alignment {
        case .auto, .topLeft, .middleLeft, .bottomLeft:
            return self + AttributedText(String(repeating: " ", count: padAmount))
        case .topCenter, .middleCenter, .bottomCenter:
            let headAmount = padAmount / 2
            let tailAmount = padAmount - headAmount
            return AttributedText(String(repeating: " ", count: headAmount), nil) + self + AttributedText(String(repeating: " ", count: tailAmount), nil)
        case .topRight, .middleRight, .bottomRight:
            return AttributedText(String(repeating: " ", count: padAmount), nil) + self
        }
    }
    // MARK: Rendering
    public func render() -> String {
        Attributes.render(self)
    }

    public func render(range: Range<StringLiteralType.Index>) -> String {
        Attributes.render(self[range])
    }
}
extension AttributedText where Attributes:OptionSet {
    public init(_ string:String, _ attributes:[Attributes]) {
        self.unattributedString = string
        // OptionSet requirement
        let attrs = attributes.reduce(Attributes(), { $1.union($0) })
        self.fragments = [(string.startIndex..<string.endIndex, attrs)]
    }
    public init(_ string:Substring, _ attributes:[Attributes]) {
        self.unattributedString = String(string)
        // OptionSet requirement
        let attrs = attributes.reduce(Attributes(), { $1.union($0) })
        self.fragments = [(unattributedString.startIndex..<unattributedString.endIndex, attrs)]
    }


    public init(_ value:String, _ attributes:Attributes...) {
        self.unattributedString = String(value)
        // OptionSet requirement
        let combined = attributes.isEmpty ? nil : attributes.reduce(Attributes.init(), { $1.union($0) })

        self.fragments.append(((self.unattributedString.startIndex..<self.unattributedString.endIndex), combined))
    }
    public init(_ value:Substring, _ attributes:Attributes...) {
        self.unattributedString = String(value)
        // OptionSet requirement
        let combined = attributes.isEmpty ? nil : attributes.reduce(Attributes.init(), { $1.union($0) })

        self.fragments.append(((self.unattributedString.startIndex..<self.unattributedString.endIndex), combined))
    }
}
extension AttributedText where Attributes:AdditiveArithmetic {
    public init(_ value: Self.StringLiteralType, _ attributes:Attributes...) {
        self.unattributedString = value
        let combined = attributes.isEmpty ? nil : attributes.reduce(.zero, { $0 + $1 })
        self.fragments.append(((value.startIndex..<value.endIndex), combined))
    }
    public init(_ substring:Substring, _ attributes:Attributes...) {
        let combined = attributes.isEmpty ? nil : attributes.reduce(.zero, {  $0 + $1 })
        let realStr = String(substring)
        self.unattributedString = realStr
        self.fragments.append(((realStr.startIndex..<realStr.endIndex), combined))
    }
}
// MARK: -
// MARK: ExpressibleByStringLiteral
extension AttributedText: ExpressibleByStringLiteral {
    public init(stringLiteral value:String) {
        self.unattributedString = value
        self.fragments.append(((value.startIndex..<value.endIndex), nil))
    }
}
// MARK: -
// MARK: ExpressibleByArrayLiteral
extension AttributedText : ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Self.Element
    public init(arrayLiteral elements: Self.Element...) {
        self.init(String(elements))
    }
}
// MARK: -
// MARK: Equatable
extension AttributedText : Equatable {
    public static func == (lhs: AttributedText, rhs: AttributedText) -> Bool {
        guard lhs.count == rhs.count else { // bail-out early
            return false
        }
        for (l,r) in zip(lhs.attributedIterator(), rhs.attributedIterator()) {
            // NOTE: Equatable requirement for Attributes
            if l.0 != r.0 || l.1 != r.1 {
                return false
            }
        }
        return true
    }
}
// MARK: -
// MARK: Collection
extension AttributedText : Collection {
    public var count: Int {
        unattributedString.count
    }
    public func index(after i: StringLiteralType.Index) -> String.Index {
        return unattributedString.index(after: i)
    }
    // MARK: -
    // MARK: Subscript
    public subscript(bounds: Range<StringLiteralType.Index>) -> AttributedText {
        // TODO: Performance, re-implement to return "SubAttributedText"
        guard bounds.lowerBound > startIndex || bounds.upperBound < endIndex else {
            return self
        }
        var subText = ""
        var subFragments:[(Range<StringLiteralType.Index>,Attributes?)] = []
        for f in fragments {

            if bounds.upperBound < f.range.lowerBound {
                // Bail-out from the loop as soon as we're out-of-bounds
                break
            }
            else if bounds.overlaps(f.range) {
                let s = subText.endIndex
                subText.append(contentsOf: unattributedString[f.range.clamped(to: bounds)])
                let e = subText.endIndex
                subFragments.append((s..<e,f.attributes))
            }
        }
        return Self(string: subText, fragments: subFragments)
    }
    public subscript(position: StringLiteralType.Index) -> Character {
        guard (unattributedString.startIndex..<unattributedString.endIndex).contains(position) else {
            fatalError("Index out of range.")
        }
        return unattributedString[position]
    }
    // MARK: -
    public var startIndex:StringLiteralType.Index {
        return unattributedString.startIndex
    }
    public var endIndex:StringLiteralType.Index {
        return unattributedString.endIndex
    }
}
// MARK: -
// MARK: BidirectionalCollection
extension AttributedText : BidirectionalCollection {
    public func index(before i: StringLiteralType.Index) -> StringLiteralType.Index {
        unattributedString.index(before: i)
    }
}
// MARK: -
// MARK: RangeReplaceableCollection
extension AttributedText : RangeReplaceableCollection {
    public init(repeating repeatedValue: Character, count:Int, attributes:Attributes? = nil) {
        self.unattributedString = String(repeating: repeatedValue, count: count)
        self.fragments = [(unattributedString.startIndex..<unattributedString.endIndex, attributes)]
    }
    public init<S>(_ elements: S, _ attributes:Attributes? = nil) where S: Sequence, Self.Element == S.Element {
        self.unattributedString = String(elements)
        self.fragments = [(self.unattributedString.startIndex..<self.unattributedString.endIndex, attributes)]
    }
    public mutating func append(_ newElement: Self.Element, attributes:Attributes? = nil) {
        self.appending(newElement, attributes)
    }
    public mutating func append<S>(contentsOf newElements: S, attributes:Attributes? = nil) where S: Sequence, Self.Element == S.Element {
        newElements.forEach {
            self.append($0, attributes: attributes)
        }
    }
    public mutating func insert(_ newElement: Self.Element, at i: Self.Index, attributes:Attributes? = nil) {
        var text = Self()
        guard i != unattributedString.endIndex else {
            self.append(newElement, attributes: attributes)
            return
        }

        for fragment in fragments {
            if fragment.range.contains(i) {
                let head = fragment.range.clamped(to: fragment.range.lowerBound..<i)
                let tail = fragment.range.clamped(to: i..<fragment.range.upperBound)
                if head.isEmpty == false {
                    text.appending(unattributedString[head], fragment.attributes)
                }
                text.append(newElement, attributes: attributes)
                if tail.isEmpty == false {
                    text.appending(unattributedString[tail], fragment.attributes)
                }
            }
            else {
                text.appending(unattributedString[fragment.range], fragment.attributes)
            }
        }
        self = text
    }
    public mutating func insert<S>(contentsOf newElements: S, at i: Self.Index, attributes:Attributes? = nil) where S: Collection, Self.Element == S.Element {
        newElements.reversed().forEach { self.insert($0, at: i, attributes: attributes) }
    }
    public mutating func remove(at i: Self.Index) -> Self.Element {
        var text = Self()
        var removed:Self.Element?
        guard unattributedString.startIndex <= i, unattributedString.endIndex >= i else {
            fatalError("Index out of bounds.")
        }
        for fragment in fragments {
            if fragment.range.contains(i) {
                removed = unattributedString[i]
                let head = fragment.range.clamped(to: fragment.range.lowerBound..<i)
                if head.isEmpty == false {
                    text.appending(unattributedString[head], fragment.attributes)
                }
                if unattributedString.index(after: i) <= fragment.range.upperBound {
                    let tail = unattributedString.index(after: i)..<fragment.range.upperBound
                    if tail.isEmpty == false {
                        text.appending(unattributedString[tail], fragment.attributes)
                    }
                }
            }
            else {
                text.appending(unattributedString[fragment.range], fragment.attributes)
            }
        }
        self = text
        guard let wasRemoved = removed else {
            fatalError("Index out of bounds.")
        }
        return wasRemoved
    }
    public mutating func removeAll(keepingCapacity keepCapacity: Bool) {
        // We're not really keeping the capacity
        unattributedString = ""
        fragments = []
    }
    public mutating func removeAll(where shouldBeRemoved: (Self.Element) throws -> Bool) rethrows {
        /*/*print(#line, #function)*/*/
        try unattributedString.indices.filter { try shouldBeRemoved(unattributedString[$0]) }
            .reversed()
            .forEach { _ = remove(at: $0)}
    }
    public mutating func removeFirst() -> Self.Element {
        return remove(at: startIndex)
    }
    public mutating func removeFirst(_ k: Int) {
        let r = startIndex..<unattributedString.index(startIndex, offsetBy: Swift.min(k, count))
        removeSubrange(r)
    }
    public mutating func replaceSubrange<C:Collection>(_ subrange:Range<StringLiteralType.Index>, with newElements: C) where C.Element == Self.Element {
        let head = self[startIndex..<subrange.lowerBound]
        let tail = self[subrange.upperBound..<endIndex]
        switch newElements {
        case is AttributedText:
            self = head + (newElements as! AttributedText<Attributes>) + tail
        default:
            let asStr:String = newElements.reduce("", { $0 + "\($1)" })
            self = head + Self(asStr) + tail
        }
    }
}
// MARK: -
// MARK: TextOutputStreamable
extension AttributedText : TextOutputStreamable {
    public func write<Target>(to target: inout Target) where Target : TextOutputStream {
        target.write(unattributedString)
    }
}
// MARK: -
private func removeTrailingWhitespace<Attributes>(_ from:AttributedText<Attributes>) -> AttributedText<Attributes> {
    var copy = from
    for i in copy.indices.reversed() {
        if copy[i].isNonNewlineWhitespace {
            _ = copy.remove(at: i)
        }
        else {
            return copy
        }
    }
    return copy
}
internal func words<Attributes:AttributeProtocol>(_ text:AttributedText<Attributes>) -> [AttributedText<Attributes>] {
    var prevChar:Character? = text.unattributedString.first
    var start:String.Index? = text.unattributedString.startIndex
    var end:String.Index? = nil
    var newWords:[AttributedText<Attributes>] = []
    var prevStyle:Attributes? = text.fragments.first?.1
    // Phase 1 - Determine word boundaries
    for idx in text.unattributedString.indices {
        let currentStyle = text.attributes(idx)
        if let ps = prevStyle, let cs = currentStyle, ps != cs {
            prevStyle = currentStyle
        }
        switch (prevChar?.isWhitespace, text.unattributedString[idx].isWhitespace) {
        case (false,false): // CHAR-CHAR
            end = idx == text.unattributedString.indices.last ? text.unattributedString.endIndex : nil
        case (false,true): // CHAR-SPACE => END
            end = idx//index(after: idx)
        case (true,false): // SPACE-CHAR => START
            start = idx
            end = idx == text.unattributedString.indices.last ? text.unattributedString.endIndex : nil
        case (true,true): // SPACE-SPACE
            start = nil
            end = nil
        default: break
        }
        if let s = start, let e = end {
            newWords.append(text[s..<e])
        }
        prevChar = text.unattributedString[idx]
    }
    return newWords
}
@inline(__always)
internal func components<Attributes:AttributeProtocol>(_ text:AttributedText<Attributes>, withMaxLength:Int) -> [AttributedText<Attributes>] {
    let rows:[AttributedText<Attributes>] = stride(from: 0, to: text.unattributedString.count, by: withMaxLength).map {
        let start = text.unattributedString.index(text.unattributedString.startIndex, offsetBy: $0)
        let end = text.unattributedString.index(start, offsetBy: withMaxLength, limitedBy: text.unattributedString.endIndex) ?? text.unattributedString.endIndex
        return text[start..<end]
    }
    return rows
}
internal func fit<Attributes:AttributeProtocol>(_ text:AttributedText<Attributes>, toWidth:Int, wordWrap:WordWrap = .word) -> [AttributedText<Attributes>] {
    let rows:[AttributedText<Attributes>]
    guard text.isEmpty == false else {
        // Bail-out early. No text, return fitted (all spaces) text.
        return [AttributedText<Attributes>(String(repeating: " ", count: toWidth))]
    }
    switch wordWrap {
    case .none:
        do {
            let width = toWidth
            var cellRows:[AttributedText<Attributes>] = []
            var currentRowOfCellRows:AttributedText<Attributes> = AttributedText()
            var c = 0
            for row in components(text, withMaxLength: width) { // Text -> [Text]
                for i in row.unattributedString.indices { // String -> [Character]
                    if c < width {
                        if row.unattributedString[i].isNewline {
                            cellRows.append(currentRowOfCellRows)
                            currentRowOfCellRows = AttributedText()
                            c = 0
                        }
                        else {
                            currentRowOfCellRows.append(row.unattributedString[i], attributes: row.attributes(i))
                            c += 1
                        }
                    }
                    else {
                        cellRows.append(currentRowOfCellRows)
                        currentRowOfCellRows = AttributedText("\(row.unattributedString[i].isNewline ? "" : String(row.unattributedString[i]))", row.attributes(i))
                        c = currentRowOfCellRows.count
                    }
                }
            }
            if currentRowOfCellRows.isEmpty == false {
                cellRows.append(currentRowOfCellRows)
            }
            return cellRows
        }
    case .char:
        do {
            let width = toWidth
            var cellRows:[AttributedText<Attributes>] = []
            var currentRowOfCellRows:AttributedText<Attributes> = AttributedText()
            var c = 0
            var prevChar:Character?
            for row in components(text, withMaxLength: width) {
                for i in row.unattributedString.indices {
                    if c < width {
                        if row.unattributedString[i].isNewline {
                            cellRows.append(removeTrailingWhitespace(currentRowOfCellRows))
                            currentRowOfCellRows = AttributedText()
                            c = 0
                        }
                        else if row.unattributedString[i].isNonNewlineWhitespace && c == 0 {
                            continue
                        }
                        else if let p = prevChar,
                            p.isNonNewlineWhitespace,
                            row.unattributedString[i].isNonNewlineWhitespace {
                            continue
                        }
                        else {
                            currentRowOfCellRows.append(row.unattributedString[i], attributes: row.attributes(i))
                            c += 1
                        }
                    }
                    else {
                        cellRows.append(removeTrailingWhitespace(currentRowOfCellRows))
                        currentRowOfCellRows = AttributedText("\(row.unattributedString[i].isWhitespace ? "" : String(row.unattributedString[i]))", row.attributes(i))
                        c = currentRowOfCellRows.count
                    }
                    prevChar = row.unattributedString[i]
                }
            }
            if currentRowOfCellRows.isEmpty == false {
                cellRows.append(removeTrailingWhitespace(currentRowOfCellRows))
            }
            rows = cellRows
        }
    case .word:
        do {
            // TODO: This needs work still...
            let width = toWidth
            let src = words(text)
            var currentRowOfCellRows = AttributedText<Attributes>()
            var cellRows:[AttributedText<Attributes>] = []
            for idx in stride(from: src.startIndex, to: src.endIndex, by: 1) {
                //                for idx in stride(from: src.index(before: src.endIndex), to: src.startIndex, by: -1) {
                let w = src[idx]
                var swallowedNewline = false
                if w == "\n" { // Newline?
                    if currentRowOfCellRows.isEmpty == false, currentRowOfCellRows.count <= width {
                        cellRows.append(currentRowOfCellRows)
                    }
                    else {
                        if currentRowOfCellRows.count == width {
                            swallowedNewline = true
                        }
                        else {
                            cellRows.append("")
                        }
                    }
                    currentRowOfCellRows = AttributedText()
                }
                else if w.count + currentRowOfCellRows.count <= width { // Not a newline, will it fit on the row?
                    if currentRowOfCellRows.isEmpty {
                        currentRowOfCellRows.appending(w)
                    }
                    else {
                        if w.count + currentRowOfCellRows.count + 1 <= width {
                            let other = AttributedText<Attributes>(" ", currentRowOfCellRows.fragments.last?.attributes)
                            currentRowOfCellRows.appending(other)
                            currentRowOfCellRows.appending(w)
                        }
                        else {
                            cellRows.append(currentRowOfCellRows)
                            currentRowOfCellRows = w
                        }
                    }
                }
                else { // Not a newline, but was too long to be appended on the row
                    // Flush the row now.
                    if currentRowOfCellRows.isEmpty == false {
                        cellRows.append(currentRowOfCellRows)
                    }

                    if w.count <= width { // Will the word fit on column at all?
                        // Yes => append it to the row
                        currentRowOfCellRows = w
                    }
                    else {
                        // No => word must be forcibly splitted to column width
                        // Split & append components to arr (last component will be put on row)
                        let comps = components(w, withMaxLength: width)
                        cellRows.append(contentsOf: comps.dropLast())
                        currentRowOfCellRows = comps.last ?? AttributedText<Attributes>("error: column width = \(width), components = \(comps.map { $0.unattributedString })")
                    }
                }
                // What's coming up next?
                if src.count > 0, let f = src.first {
                    if f == "\n" { // Next word is a newline
                        if w == "\n" { // Previous word was a newline as well
                            if swallowedNewline { // But it was swallowed

                            }
                            else { // Not, swallowed, just a newline => obey
                                cellRows.append(" ")
                            }
                        }
                        else { // Previous word was not a newline, but next will  => obey
                        }
                    }
                    else { // Next word is non-newline
                    }
                }
                else {
                    if w == "\n" {
                        if currentRowOfCellRows.isEmpty == false {
                            cellRows.append(currentRowOfCellRows)
                        }
                        cellRows.append("") // Obey newline
                    }
                    else {
                        if currentRowOfCellRows.isEmpty == false {
                            cellRows.append(currentRowOfCellRows)
                        }
                    }
                    currentRowOfCellRows = ""
                }
            }
            if currentRowOfCellRows.isEmpty == false {
                cellRows.append(currentRowOfCellRows)
            }
            return cellRows
        }
    }
    return rows
}
