public protocol AnyOptional {
    var isNil: Bool { get }
    var isNotNil: Bool { get }
}

extension Optional: AnyOptional {
    public var isNil: Bool { self == nil }
    public var isNotNil: Bool { self != nil }
}
