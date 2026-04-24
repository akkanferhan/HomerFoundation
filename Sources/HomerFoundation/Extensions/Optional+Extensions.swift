import Foundation
import CoreGraphics

public extension Optional where Wrapped: RangeReplaceableCollection {
    var orEmpty: Wrapped { self ?? Wrapped() }
}

public extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool { self?.isEmpty ?? true }
    var isNotNilOrEmpty: Bool { !isNilOrEmpty }
}

public extension Optional where Wrapped: AdditiveArithmetic {
    var orZero: Wrapped { self ?? .zero }
}

public extension Optional where Wrapped == Bool {
    var orFalse: Bool { self ?? false }
    var orTrue: Bool { self ?? true }
}
