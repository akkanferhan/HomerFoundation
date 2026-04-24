public extension Collection {
    /// Negation of `isEmpty`. Available on `String`, `Array`, `Set`,
    /// `Dictionary`, and any other `Collection`.
    var isNotEmpty: Bool { !isEmpty }

    /// Returns the element at `index` or `nil` if it is out of bounds.
    /// Avoids the trap that the standard subscript would produce.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
