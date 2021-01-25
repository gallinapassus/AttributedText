public struct DefaultAttributes : OptionSet, ExpressibleByArrayLiteral, AttributeProtocol {
    public static func render(_ attributed: AttributedText<Self>) -> String {
        var str = ""
        for fragment in attributed.fragmentIterator() {
            guard let attributes = fragment.1 else {
                str += fragment.0
                continue
            }
            str += "\(fragment.0, attributes: attributes)"
        }
        return str
    }
    public typealias RawValue = Int
    public let rawValue: RawValue
    internal enum Trait : Int, CaseIterable {
        case bold = 0
        case dim
        case italic
        case underlined
        case blink
        case inverse
        case hidden
        case strikethrough

        var code:Int {
            switch self {
            case .bold         : return 1
            case .dim          : return 2
            case .italic       : return 3
            case .underlined   : return 4
            case .blink        : return 5
            case .inverse      : return 7
            case .hidden       : return 8
            case .strikethrough: return 9
            }
        }
    }
    internal init(trait:Trait) {
        self.rawValue = 1 << trait.rawValue
    }
    public init(rawValue:RawValue) {
        self.rawValue = rawValue
    }
    public init<S>(_ sequence: __owned S) where S : Sequence, Self.Element == S.Element {
        self = sequence.reduce(Self(), { $0.union($1) })
    }
    private init(raw value:RawValue, fgColor:IndexedColor, bgColor:IndexedColor) {
        self.rawValue = value
        self.fgColor = fgColor
        self.bgColor = bgColor
    }

    private (set) public var fgColor:IndexedColor = .default
    private (set) public var bgColor:IndexedColor = .default
    //private (set) public var prefix:String        = "-"
    public static let bold          = Self(trait: .bold)
    public static let dim           = Self(trait: .dim)
    public static let italic        = Self(trait: .italic)
    public static let underlined    = Self(trait: .underlined)
    public static let blink         = Self(trait: .blink)
    public static let inverse       = Self(trait: .inverse)
    public static let hidden        = Self(trait: .hidden)
    public static let strikethrough = Self(trait: .strikethrough)
    public static func fgColor(_ color:IndexedColor) -> Self {
        return Self(raw: 0, fgColor: color, bgColor: .default)
    }
    public static func bgColor(_ color:IndexedColor) -> Self {
        return Self(raw: 0, fgColor: .default, bgColor: color)
    }
    public var traitsInEffect:String {
        var str:[String] = []
        for i in 0...7 {
            switch rawValue & (1 << i) {
            case Self.bold.rawValue: str.append("bold")
            case Self.dim.rawValue: str.append("dim")
            case Self.italic.rawValue: str.append("italic")
            case Self.underlined.rawValue: str.append("underlined")
            case Self.blink.rawValue: str.append("blink")
            case Self.inverse.rawValue: str.append("inverse")
            case Self.hidden.rawValue: str.append("hidden")
            case Self.strikethrough.rawValue: str.append("strikethrough")
            default: break
            }
        }
        str.append("fgColor(\(fgColor))")
        str.append("bgColor(\(bgColor))")
        return str.joined(separator: ", ")
    }

}
// Conformance to Equatable
extension DefaultAttributes : Equatable {
    public static func ==(lhs:Self, rhs:Self) -> Bool {
        lhs.rawValue == rhs.rawValue && lhs.fgColor == rhs.fgColor && lhs.bgColor == rhs.bgColor /*&& lhs.prefix == rhs.prefix*/
    }
}
extension DefaultAttributes {
    public func contains(_ member: Self) -> Bool {
        if self.rawValue & member.rawValue > 0 { return true }
        else if self.fgColor != .default, self.fgColor == member.fgColor { return true }
        else if self.bgColor != .default, self.bgColor == member.bgColor { return true }
        return false
    }
    public func union(_ other: Self) -> Self {
        let raw = self.rawValue | other.rawValue
        let fg = other.fgColor == .default ? self.fgColor : other.fgColor
        let bg = other.bgColor == .default ? self.bgColor : other.bgColor
        return Self(raw: raw, fgColor: fg, bgColor: bg)
    }
    public func intersection(_ other: Self) -> Self {
        let rawIntersection = self.rawValue & other.rawValue
        let fgIntersection = self.fgColor == other.fgColor ? self.fgColor : .default
        let bgIntersection = self.bgColor == other.bgColor ? self.bgColor : .default
        return Self(raw: rawIntersection, fgColor: fgIntersection, bgColor: bgIntersection)
    }
    public mutating func update(with newMember: Self) -> Self? {
        let raw = newMember.rawValue
        let fg = newMember.fgColor == .default ? self.fgColor : newMember.fgColor
        let bg = newMember.bgColor == .default ? self.bgColor : newMember.bgColor
        let intersect = self.intersection(newMember)
        self = Self(raw: raw, fgColor: fg, bgColor: bg)
        return intersect == Self() ? nil : intersect
    }
    public mutating func remove(_ member: Self) -> Self? {
        let raw = self.rawValue ^ member.rawValue
        let fg = member.fgColor == .default ? self.fgColor : .default
        let bg = member.bgColor == .default ? self.bgColor : .default
        let intersect = self.intersection(member)
        self = Self(raw: raw, fgColor: fg, bgColor: bg)
        return intersect == Self() ? nil : intersect
    }
    public func isSubset(of other: Self) -> Bool {
        return union(other) == other
    }
    public mutating func insert(_ newMember: Self) -> (inserted: Bool, memberAfterInsert: Self) {
        guard contains(newMember) == false else {
            return (false, self)
        }
        let raw = rawValue | newMember.rawValue
        let fg = newMember.fgColor == .default ? self.fgColor : newMember.fgColor
        let bg = newMember.bgColor == .default ? self.bgColor : newMember.bgColor
        self = Self(raw: raw, fgColor: fg, bgColor: bg)
        return (true, self)
    }
    public func isSuperset(of other: DefaultAttributes) -> Bool {
        union(other) == self
    }
    public func isStrictSuperset(of other: Self) -> Bool {
        isSuperset(of: other) && self != other
    }
}
