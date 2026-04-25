import Foundation
import CoreGraphics

public extension Optional where Wrapped: RangeReplaceableCollection {
    /// Returns the wrapped collection or an empty one (`""`, `[]`, etc.) when `nil`.
    var orEmpty: Wrapped { self ?? Wrapped() }
}

public extension Optional where Wrapped: Collection {
    /// `true` when the optional is `nil` or its wrapped collection is empty.
    var isNilOrEmpty: Bool { self?.isEmpty ?? true }
    /// Negation of ``isNilOrEmpty``.
    var isNotNilOrEmpty: Bool { !isNilOrEmpty }
}

public extension Optional where Wrapped: AdditiveArithmetic {
    /// Returns the wrapped value or `Wrapped.zero` when `nil`. Works for `Int`,
    /// `Double`, `CGFloat`, `CGPoint`, etc.
    var orZero: Wrapped { self ?? .zero }
}

public extension Optional where Wrapped == Bool {
    /// Returns the wrapped value or `false` when `nil` — covers the common
    /// "settings flag defaults to off" case. Use `?? true` directly for the
    /// rarer reverse default.
    var orFalse: Bool { self ?? false }
}
