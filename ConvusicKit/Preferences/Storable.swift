//
// Convusic
// Copyright 2026 Varun Santhanam
//

import Foundation
import JBird

/// A value type that can be serialized to and from a `PreferencePrimitive`
/// for storage in `UserDefaults` / `NSUbiquitousKeyValueStore`.
public protocol Storable: Sendable {

    /// Returns `nil` to mean "no value" (the key is removed from the store).
    func encodedForStorage() -> PreferencePrimitive?

    static func decoded(from primitive: PreferencePrimitive) -> Self?

}

extension String: Storable {

    public func encodedForStorage() -> PreferencePrimitive? {
        .string(self)
    }

    public static func decoded(from primitive: PreferencePrimitive) -> String? {
        if case let .string(value) = primitive {
            value
        } else {
            nil
        }
    }

}

extension Bool: Storable {

    public func encodedForStorage() -> PreferencePrimitive? {
        .bool(self)
    }

    public static func decoded(from primitive: PreferencePrimitive) -> Bool? {
        // Booleans can re-materialize as integer NSNumbers (legacy values, KVS
        // server round-trips, `set(1, forKey:)`); coerce them like `Double` does.
        switch primitive {
        case let .bool(value):
            value
        case let .int(value):
            value != 0
        case let .double(value):
            value != 0
        default:
            nil
        }
    }

}

extension Int: Storable {

    public func encodedForStorage() -> PreferencePrimitive? {
        .int(self)
    }

    public static func decoded(from primitive: PreferencePrimitive) -> Int? {
        if case let .int(value) = primitive {
            value
        } else {
            nil
        }
    }

}

extension Double: Storable {

    public func encodedForStorage() -> PreferencePrimitive? {
        .double(self)
    }

    public static func decoded(from primitive: PreferencePrimitive) -> Double? {
        switch primitive {
        case let .double(value):
            value
        case let .int(value):
            Double(value)
        default:
            nil
        }
    }

}

extension Data: Storable {

    public func encodedForStorage() -> PreferencePrimitive? {
        .data(self)
    }

    public static func decoded(from primitive: PreferencePrimitive) -> Data? {
        if case let .data(value) = primitive {
            value
        } else {
            nil
        }
    }

}

extension URL: Storable {

    public func encodedForStorage() -> PreferencePrimitive? {
        .string(absoluteString)
    }

    public static func decoded(from primitive: PreferencePrimitive) -> URL? {
        if case let .string(value) = primitive {
            URL(string: value)
        } else {
            nil
        }
    }

}

extension Optional: Storable where Wrapped: Storable {

    public func encodedForStorage() -> PreferencePrimitive? {
        switch self {
        case let .some(wrapped):
            wrapped.encodedForStorage()
        case .none:
            nil
        }
    }

    public static func decoded(from primitive: PreferencePrimitive) -> Wrapped?? {
        // `Self` == `Optional<Wrapped>`; returns `Optional<Self>`.
        Wrapped.decoded(from: primitive).map(Optional.some)
    }

}

/// Generic convenience for PLAIN raw enums only (where `RawValue: Storable`).
///
/// `Platform` deliberately does NOT use this (see `Platform+Storable.swift`)
/// because it is not `RawRepresentable` and has a `.unknown(String)` case.
extension Storable where Self: RawRepresentable, Self.RawValue: Storable {

    public func encodedForStorage() -> PreferencePrimitive? {
        rawValue.encodedForStorage()
    }

    public static func decoded(from primitive: PreferencePrimitive) -> Self? {
        RawValue.decoded(from: primitive).flatMap(Self.init(rawValue:))
    }

}

/// Opt-in conformance for `Codable` value types that should be stored as JSON
/// `Data`. It is a separate protocol (rather than a default on `Storable where
/// Self: Codable`) so it cannot collide with the `RawRepresentable` default
/// extension above.
public protocol JSONStorable: Storable, Codable {}

extension JSONStorable {

    public func encodedForStorage() -> PreferencePrimitive? {
        (try? JSON.Encoder().encode(self)).map(PreferencePrimitive.data)
    }

    public static func decoded(from primitive: PreferencePrimitive) -> Self? {
        guard case let .data(data) = primitive else {
            return nil
        }
        return try? JSON.Decoder().decode(Self.self, from: data)
    }

}
