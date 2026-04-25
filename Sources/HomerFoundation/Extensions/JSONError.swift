/// Error cases shared between the JSON helpers in HomerFoundation.
public enum JSONError: Error, Equatable {
    /// `Data.asJSONDictionary()` parsed valid JSON, but the top-level value
    /// was not an object (e.g. it was an array or a scalar).
    case notADictionary
    /// `Dictionary.asJSONString()` was called on a dictionary containing
    /// values that `JSONSerialization` cannot represent (`Date`, `URL`, etc.).
    case notValidJSON
}
