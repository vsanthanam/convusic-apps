//
// Convusic
// Copyright 2026 Varun Santhanam
//

import Foundation

/// `Platform` has a `rawValue: String` and a `.unknown(String)` case but no
/// `init?(rawValue:)`, so it is not `RawRepresentable`. This explicit
/// conformance stores its String `rawValue` and reconstructs it via
/// `Platform.init(rawValue:)`, avoiding the JSON overhead of `JSONStorable` and
/// the generic `RawRepresentable` default.
extension Platform: Storable {

    public func encodedForStorage() -> PreferencePrimitive? {
        .string(rawValue)
    }

    public static func decoded(from primitive: PreferencePrimitive) -> Platform? {
        guard case let .string(raw) = primitive else {
            return nil
        }
        return Platform(rawValue: raw)
    }

}
