public extension Sequence where Element: Hashable {
    /// First-seen-order deduplication using a `Set`. `O(n)` and stable.
    func uniqued() -> [Element] {
        var seen: Set<Element> = []
        return filter { seen.insert($0).inserted }
    }
}

public extension Sequence {
    /// First-seen-order deduplication keyed by a `Hashable` key path. Useful
    /// when deduping by an `id` while keeping non-`Hashable` payload.
    func uniqued<ID: Hashable>(on keyPath: KeyPath<Element, ID>) -> [Element] {
        var seen: Set<ID> = []
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
}
