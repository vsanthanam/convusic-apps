//
// Convusic
// Copyright 2026 Varun Santhanam
//

import CoreFoundation
import Foundation

/// A type-safe plist leaf value that can be round-tripped through
/// `UserDefaults` and `NSUbiquitousKeyValueStore`.
public enum PreferencePrimitive: Hashable, Sendable {

    case string(String)

    case bool(Bool)

    case int(Int)

    case double(Double)

    case data(Data)

    /// The plist object handed to `UserDefaults` / KVS `set(_:forKey:)`.
    public var anyObject: Any {
        switch self {
        case let .string(value):
            value
        case let .bool(value):
            value
        case let .int(value):
            value
        case let .double(value):
            value
        case let .data(value):
            value
        }
    }

    /// Rebuilds a primitive from `object(forKey:)`, disambiguating Bool vs Int
    /// vs Double via CoreFoundation type IDs (the classic NSNumber problem).
    public init?(anyObject: Any?) {
        guard let anyObject else {
            return nil
        }
        if let string = anyObject as? String {
            self = .string(string)
            return
        }
        if let data = anyObject as? Data {
            self = .data(data)
            return
        }
        let cf = anyObject as CFTypeRef
        if CFGetTypeID(cf) == CFBooleanGetTypeID() {
            self = .bool(anyObject as! Bool)
            return
        }
        if let number = anyObject as? NSNumber {
            if CFNumberIsFloatType(number) {
                self = .double(number.doubleValue)
            } else {
                self = .int(number.intValue)
            }
            return
        }
        return nil
    }

}
