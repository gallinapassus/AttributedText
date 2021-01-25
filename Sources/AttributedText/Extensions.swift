internal extension Character {
    var isNonNewlineWhitespace:Bool {
        isWhitespace && isNewline == false
    }
}
internal extension Array {
    mutating func insert(inBetween:Element) {
        for i in self.indices.reversed().dropLast() {
            self.insert(inBetween, at: i)
        }
    }
}
