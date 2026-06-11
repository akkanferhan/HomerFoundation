import Foundation
import Testing
@testable import HomerFoundation

@Suite("URL+Extensions")
struct URLExtensionsTests {
    @Test("appendingQueryItems adds items to a URL without a query")
    func appendToBareURL() throws {
        let url = try #require(URL(string: "https://api.example.com/users"))
        let result = url.appendingQueryItems([URLQueryItem(name: "page", value: "1")])
        #expect(result.absoluteString == "https://api.example.com/users?page=1")
    }

    @Test("appendingQueryItems preserves the existing query")
    func appendPreservesExistingQuery() throws {
        let url = try #require(URL(string: "https://api.example.com/users?sort=asc"))
        let result = url.appendingQueryItems([URLQueryItem(name: "page", value: "2")])
        #expect(result.absoluteString == "https://api.example.com/users?sort=asc&page=2")
    }

    @Test("appendingQueryItems with an empty array returns the URL unchanged")
    func appendEmptyArrayIsNoop() throws {
        let url = try #require(URL(string: "https://api.example.com/users?a=1"))
        #expect(url.appendingQueryItems([URLQueryItem]()) == url)
    }

    @Test("dictionary overload appends keys in sorted order")
    func dictionaryOverloadIsDeterministic() throws {
        let url = try #require(URL(string: "https://api.example.com/search"))
        let result = url.appendingQueryItems(["b": "2", "a": "1", "c": "3"])
        #expect(result.absoluteString == "https://api.example.com/search?a=1&b=2&c=3")
    }

    @Test("dictionary overload renders nil values as flag-style items")
    func dictionaryOverloadNilValue() throws {
        let url = try #require(URL(string: "https://api.example.com/search"))
        let result = url.appendingQueryItems(["debug": String?.none])
        #expect(result.absoluteString == "https://api.example.com/search?debug")
    }

    @Test("appendingQueryItems percent-encodes values that need it")
    func appendEncodesValues() throws {
        let url = try #require(URL(string: "https://api.example.com/search"))
        let result = url.appendingQueryItems([URLQueryItem(name: "q", value: "homer simpson")])
        #expect(result.absoluteString == "https://api.example.com/search?q=homer%20simpson")
        #expect(result.queryValue(for: "q") == "homer simpson")
    }

    @Test("queryValue returns the first match or nil")
    func queryValueLookup() throws {
        let url = try #require(URL(string: "https://api.example.com/users?page=1&page=2&sort=asc"))
        #expect(url.queryValue(for: "page") == "1")
        #expect(url.queryValue(for: "sort") == "asc")
        #expect(url.queryValue(for: "missing") == nil)
    }

    @Test("queryValue returns nil on a URL without a query")
    func queryValueWithoutQuery() throws {
        let url = try #require(URL(string: "https://api.example.com/users"))
        #expect(url.queryValue(for: "page") == nil)
    }
}
