public extension Array {
    /// Moves the element at `index` to the front of the array. No-op if
    /// `index` is out of bounds.
    mutating func moveToFirst(from index: Int) {
        guard index >= 0, index < count else { return }
        let element = remove(at: index)
        insert(element, at: 0)
    }

    /// Removes and returns the first element, or `nil` when empty.
    /// Mirrors `removeFirst()` without the trap on empty arrays.
    @discardableResult
    mutating func removeFirstSafely() -> Element? {
        isEmpty ? nil : removeFirst()
    }
}
