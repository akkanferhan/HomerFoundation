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
}
