public extension Comparable {
    /// Clamps the value into a closed range. Below the lower bound it returns
    /// the lower bound; above the upper bound it returns the upper bound.
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
