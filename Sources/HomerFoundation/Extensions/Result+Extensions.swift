import Foundation

public extension Result {
    /// The success payload when `self` is `.success`, otherwise `nil`.
    /// Useful for `if let value = result.value { … }` patterns where a `switch`
    /// would be overkill.
    var value: Success? {
        switch self {
        case .success(let success): success
        case .failure: nil
        }
    }

    /// The failure payload when `self` is `.failure`, otherwise `nil`.
    var error: Failure? {
        switch self {
        case .success: nil
        case .failure(let failure): failure
        }
    }

    /// `true` when `self` is `.success`. Inverse of ``isFailure``.
    var isSuccess: Bool {
        switch self {
        case .success: true
        case .failure: false
        }
    }

    /// `true` when `self` is `.failure`. Inverse of ``isSuccess``.
    var isFailure: Bool { !isSuccess }

    /// `map` with an `async` transform. Failures pass through untouched,
    /// so async post-processing chains read the same as the sync `map`.
    /// - Parameter transform: Applied to the success payload only.
    func asyncMap<NewSuccess>(
        _ transform: (Success) async -> NewSuccess
    ) async -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let success): .success(await transform(success))
        case .failure(let failure): .failure(failure)
        }
    }
}

public extension Result where Failure == Error {
    /// Async counterpart of `Result(catching:)` — captures the value or
    /// the thrown error of an `async` body. Bridges async work into
    /// `Result`-shaped storage and legacy completion APIs:
    /// ```swift
    /// let result = await Result(asyncCatching: { try await loadUser() })
    /// ```
    /// - Parameter body: The async work whose outcome to capture.
    init(asyncCatching body: () async throws -> Success) async {
        do {
            self = .success(try await body())
        } catch {
            self = .failure(error)
        }
    }
}
