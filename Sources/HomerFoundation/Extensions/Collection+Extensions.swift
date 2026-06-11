public extension Collection {
    /// Negation of `isEmpty`. Available on `String`, `Array`, `Set`,
    /// `Dictionary`, and any other `Collection`.
    var isNotEmpty: Bool { !isEmpty }

    /// Returns the element at `index` or `nil` if it is out of bounds.
    /// Avoids the trap that the standard subscript would produce.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

    /// Splits the collection into consecutive chunks of at most `size`
    /// elements, preserving order. The final chunk holds whatever
    /// remains, so it may be shorter. Empty collections produce `[]`.
    /// `size` values below `1` are clamped to `1` rather than trapping —
    /// no element is ever dropped.
    func chunked(into size: Int) -> [[Element]] {
        let size = Swift.max(1, size)
        var chunks: [[Element]] = []
        chunks.reserveCapacity((count + size - 1) / size)
        var lower = startIndex
        while lower != endIndex {
            let upper = index(lower, offsetBy: size, limitedBy: endIndex) ?? endIndex
            chunks.append(Array(self[lower..<upper]))
            lower = upper
        }
        return chunks
    }
}
