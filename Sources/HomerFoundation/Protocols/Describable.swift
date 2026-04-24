public protocol Describable {
    var typeName: String { get }
    static var typeName: String { get }
}

public extension Describable {
    var typeName: String { String(describing: type(of: self)) }
    static var typeName: String { String(describing: self) }
}
