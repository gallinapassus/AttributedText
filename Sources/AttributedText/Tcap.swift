internal extension String.StringInterpolation {
    enum ControlCode {
        static let ESC   = "\u{001B}"
        static let CSI   = "\(ESC)["
        static let RESET = "\(CSI)0m"
    }
    mutating func applyTraits(attributes: DefaultAttributes?, reset:Bool?, to any: Any) {

        // Bail-out early if there are no attributes.
        guard let attributes = attributes, (attributes.rawValue > 0 || attributes.fgColor != .default || attributes.bgColor != .default) else {
            appendLiteral("\(any)")
            return
        }

        appendLiteral(ControlCode.CSI)

        var codeStrings: [String] = []

        if let colorCode = attributes.fgColor.code {
            codeStrings.append("38")
            codeStrings.append("5")
            codeStrings.append("\(colorCode)")
        }
        if let colorCode = attributes.bgColor.code {
            codeStrings.append("48")
            codeStrings.append("5")
            codeStrings.append("\(colorCode)")
        }
        for t in DefaultAttributes.Trait.allCases {
            if (attributes.rawValue & 1<<t.rawValue) != 0 {
                codeStrings.append("\(t.code)")
            }
        }
        appendLiteral(codeStrings.joined(separator: ";"))

        appendLiteral("m")
        appendLiteral("\(any)")
        if let reset = reset, reset == true {
            appendLiteral(ControlCode.RESET)
        }
        else {
            appendLiteral(ControlCode.RESET) // defult is to reset
        }
    }
}
internal extension String.StringInterpolation {
    mutating func appendInterpolation(_ any: Any, attributes: DefaultAttributes?, reset: Bool? = nil) {
        applyTraits(attributes: attributes, reset: reset, to: any)
    }
}

