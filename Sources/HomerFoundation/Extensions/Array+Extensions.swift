public extension Array {
    mutating func moveToFirst(from index: Int) {
        guard index >= 0, index < count else { return }
        let element = remove(at: index)
        insert(element, at: 0)
    }

    @discardableResult
    mutating func removeFirstSafely() -> Element? {
        isEmpty ? nil : removeFirst()
    }
}
