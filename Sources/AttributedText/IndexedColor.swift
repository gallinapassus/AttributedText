public enum IndexedColor : Hashable, Equatable {
    case `default`
    case black
    case red
    case green
    case yellow
    case blue
    case magenta
    case cyan
    case white
    case colorAtIndex(Int)
    public var code:Int? {
        switch self {
        case .default: return nil
        case .black:   return 0
        case .red:     return 1
        case .green:   return 2
        case .yellow:  return 3
        case .blue:    return 4
        case .magenta: return 5
        case .cyan:    return 6
        case .white:   return 7
        case .colorAtIndex(let i): return i & 0xff
        }
    }
}
