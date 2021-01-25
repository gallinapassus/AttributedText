public struct FrameElements<Attributes:AttributeProtocol> {

    public var topLeftCorner:                     AttributedText<Attributes>
    public var topHorizontalSeparator:            AttributedText<Attributes>
    public var topHorizontalVerticalSeparator:    AttributedText<Attributes>
    public var topRightCorner:                    AttributedText<Attributes>
    public var leftVerticalSeparator:             AttributedText<Attributes>
    public var rightVerticalSeparator:            AttributedText<Attributes>
    public var insideLeftVerticalSeparator:       AttributedText<Attributes>
    public var insideHorizontalSeparator:         AttributedText<Attributes>
    public var insideRightVerticalSeparator:      AttributedText<Attributes>
    public var insideHorizontalVerticalSeparator: AttributedText<Attributes>
    public var insideVerticalSeparator:           AttributedText<Attributes>
    public var bottomLeftCorner:                  AttributedText<Attributes>
    public var bottomHorizontalSeparator:         AttributedText<Attributes>
    public var bottomHorizontalVerticalSeparator: AttributedText<Attributes>
    public var bottomRightCorner:                 AttributedText<Attributes>
    public init(
        topLeftCorner:                     AttributedText<Attributes>,
        topHorizontalSeparator:            AttributedText<Attributes>,
        topHorizontalVerticalSeparator:    AttributedText<Attributes>,
        topRightCorner:                    AttributedText<Attributes>,
        leftVerticalSeparator:             AttributedText<Attributes>,
        rightVerticalSeparator:            AttributedText<Attributes>,
        insideLeftVerticalSeparator:       AttributedText<Attributes>,
        insideHorizontalSeparator:         AttributedText<Attributes>,
        insideRightVerticalSeparator:      AttributedText<Attributes>,
        insideHorizontalVerticalSeparator: AttributedText<Attributes>,
        insideVerticalSeparator:           AttributedText<Attributes>,
        bottomLeftCorner:                  AttributedText<Attributes>,
        bottomHorizontalSeparator:         AttributedText<Attributes>,
        bottomHorizontalVerticalSeparator: AttributedText<Attributes>,
        bottomRightCorner:                 AttributedText<Attributes>
    ) {
        let pairs = [
            (topLeftCorner, bottomLeftCorner),
            (topLeftCorner, leftVerticalSeparator),
            (topLeftCorner, insideLeftVerticalSeparator),

            (topRightCorner, bottomRightCorner),
            (topRightCorner, rightVerticalSeparator),
            (topRightCorner, insideRightVerticalSeparator),

            (topHorizontalSeparator, bottomHorizontalSeparator),
            (topHorizontalSeparator, insideHorizontalSeparator),

            (leftVerticalSeparator, insideLeftVerticalSeparator),

            (rightVerticalSeparator, insideRightVerticalSeparator),

            (topHorizontalVerticalSeparator, bottomHorizontalVerticalSeparator),
            (topHorizontalVerticalSeparator, insideHorizontalVerticalSeparator),
        ]
        for (l,r) in pairs {
            precondition(l.count == r.count, "\(FrameElements.self) \"\(l.unattributedString)\" and \"\(r.unattributedString)\" have different string lengths and would produce misaligned frame.")
        }
        for mustBeSingleChar in [topHorizontalSeparator, insideHorizontalSeparator, bottomHorizontalSeparator] {
            precondition(mustBeSingleChar.unattributedString.count == 1, "\(FrameElements.self) \"\(mustBeSingleChar.unattributedString)\" unattributed length must be 1.")
        }
        self.topLeftCorner                     = topLeftCorner
        self.topHorizontalSeparator            = topHorizontalSeparator
        self.topHorizontalVerticalSeparator    = topHorizontalVerticalSeparator
        self.topRightCorner                    = topRightCorner
        self.leftVerticalSeparator             = leftVerticalSeparator
        self.rightVerticalSeparator            = rightVerticalSeparator
        self.insideLeftVerticalSeparator       = insideLeftVerticalSeparator
        self.insideHorizontalSeparator         = insideHorizontalSeparator
        self.insideRightVerticalSeparator      = insideRightVerticalSeparator
        self.insideHorizontalVerticalSeparator = insideHorizontalVerticalSeparator
        self.insideVerticalSeparator           = insideVerticalSeparator
        self.bottomLeftCorner                  = bottomLeftCorner
        self.bottomHorizontalSeparator         = bottomHorizontalSeparator
        self.bottomHorizontalVerticalSeparator = bottomHorizontalVerticalSeparator
        self.bottomRightCorner                 = bottomRightCorner
    }
}
extension FrameElements where Attributes == DefaultAttributes {
    public static func squared(attributes:Attributes? = nil) -> Self {
        FrameElements(
            topLeftCorner:                        .init("┌", attributes),
            topHorizontalSeparator:               .init("─", attributes),
            topHorizontalVerticalSeparator:       .init("┬", attributes),
            topRightCorner:                       .init("┐", attributes),
            leftVerticalSeparator:                .init("│", attributes),
            rightVerticalSeparator:               .init("│", attributes),
            insideLeftVerticalSeparator:          .init("├", attributes),
            insideHorizontalSeparator:            .init("─", attributes),
            insideRightVerticalSeparator:         .init("┤", attributes),
            insideHorizontalVerticalSeparator:    .init("┼", attributes),
            insideVerticalSeparator:              .init("│", attributes),
            bottomLeftCorner:                     .init("└", attributes),
            bottomHorizontalSeparator:            .init("─", attributes),
            bottomHorizontalVerticalSeparator:    .init("┴", attributes),
            bottomRightCorner:                    .init("┘", attributes)
        )
    }
    public static func rounded(attributes:Attributes? = nil) -> Self {
        FrameElements(
            topLeftCorner:                        .init("╭", attributes),
            topHorizontalSeparator:               .init("─", attributes),
            topHorizontalVerticalSeparator:       .init("┬", attributes),
            topRightCorner:                       .init("╮", attributes),
            leftVerticalSeparator:                .init("│", attributes),
            rightVerticalSeparator:               .init("│", attributes),
            insideLeftVerticalSeparator:          .init("├", attributes),
            insideHorizontalSeparator:            .init("─", attributes),
            insideRightVerticalSeparator:         .init("┤", attributes),
            insideHorizontalVerticalSeparator:    .init("┼", attributes),
            insideVerticalSeparator:              .init("│", attributes),
            bottomLeftCorner:                     .init("╰", attributes),
            bottomHorizontalSeparator:            .init("─", attributes),
            bottomHorizontalVerticalSeparator:    .init("┴", attributes),
            bottomRightCorner:                    .init("╯", attributes)
        )
    }
}
extension FrameElements {
    public static var `default`:Self {
        FrameElements(
            topLeftCorner:                        "+",
            topHorizontalSeparator:               "-",
            topHorizontalVerticalSeparator:       "+",
            topRightCorner:                       "+",
            leftVerticalSeparator:                "|",
            rightVerticalSeparator:               "|",
            insideLeftVerticalSeparator:          "+",
            insideHorizontalSeparator:            "-",
            insideRightVerticalSeparator:         "+",
            insideHorizontalVerticalSeparator:    "+",
            insideVerticalSeparator:              "|",
            bottomLeftCorner:                     "+",
            bottomHorizontalSeparator:            "-",
            bottomHorizontalVerticalSeparator:    "+",
            bottomRightCorner:                    "+"
        )
    }
    public static var ascii:Self {
        `default`
    }
    public static var singleSpace:Self {
        FrameElements(
            topLeftCorner:                        " ",
            topHorizontalSeparator:               " ",
            topHorizontalVerticalSeparator:       " ",
            topRightCorner:                       " ",
            leftVerticalSeparator:                " ",
            rightVerticalSeparator:               " ",
            insideLeftVerticalSeparator:          " ",
            insideHorizontalSeparator:            " ",
            insideRightVerticalSeparator:         " ",
            insideHorizontalVerticalSeparator:    " ",
            insideVerticalSeparator:              " ",
            bottomLeftCorner:                     " ",
            bottomHorizontalSeparator:            " ",
            bottomHorizontalVerticalSeparator:    " ",
            bottomRightCorner:                    " "
        )
    }
}
