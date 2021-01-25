
// Upgrading the Equatable requirement to hashable,
// would potentially unlock performance features like
// cached/pre-calculated control sequences.
public protocol AttributeProtocol : Equatable {
    static func render(_ attributed:AttributedText<Self>) -> String
}
// AttributedDocument uses Rendable protocol
public protocol Rendable {
    func render() -> String
}
