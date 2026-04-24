/// Provides a `typeName` string both for instances and for the type itself.
/// Useful as a generic constraint when logging or registering types by name.
public protocol Describable {
    /// The runtime type name of `self`.
    var typeName: String { get }
    /// The static type name.
    static var typeName: String { get }
}

public extension Describable {
    var typeName: String { String(describing: type(of: self)) }
    static var typeName: String { String(describing: self) }
}
