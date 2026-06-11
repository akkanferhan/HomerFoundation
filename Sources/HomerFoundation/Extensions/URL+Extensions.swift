import Foundation

public extension URL {
    /// Returns a copy of the URL with `items` appended after any query
    /// items already present. Existing items are never replaced or
    /// deduplicated — appending `page=2` to a URL that already carries
    /// `page=1` yields both, matching `URLComponents` semantics. Returns
    /// `self` unchanged when `items` is empty or the URL cannot be
    /// decomposed into components.
    func appendingQueryItems(_ items: [URLQueryItem]) -> URL {
        guard items.isNotEmpty,
              var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }
        components.queryItems = (components.queryItems ?? []) + items
        return components.url ?? self
    }

    /// Dictionary convenience over ``appendingQueryItems(_:)``. Keys are
    /// appended in **sorted order** so the resulting URL is deterministic
    /// (dictionaries do not preserve insertion order). A `nil` value
    /// produces a flag-style item without `=` (e.g. `?debug`).
    func appendingQueryItems(_ parameters: [String: String?]) -> URL {
        let items = parameters
            .sorted { $0.key < $1.key }
            .map { URLQueryItem(name: $0.key, value: $0.value) }
        return appendingQueryItems(items)
    }

    /// The value of the first query item named `name`, or `nil` when the
    /// URL has no query or no item with that name. Percent-encoding is
    /// removed by `URLComponents` before the value is returned.
    func queryValue(for name: String) -> String? {
        URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first { $0.name == name }?
            .value
    }
}
