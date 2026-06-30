//
// Convusic
// Copyright 2026 Varun Santhanam
//

import Foundation

/// `Platform` has a `rawValue: String` and a `.unknown(String)` case but no
/// `init?(rawValue:)`, so it is not `RawRepresentable`. This explicit
/// conformance stores its String `rawValue` and reconstructs it (mirroring
/// `Platform.init(from:)`), avoiding the JSON overhead of `JSONStorable` and
/// the generic `RawRepresentable` default.
extension Platform: Storable {

    public func encodedForStorage() -> PreferencePrimitive? {
        .string(rawValue)
    }

    public static func decoded(from primitive: PreferencePrimitive) -> Platform? {
        guard case let .string(raw) = primitive else {
            return nil
        }
        return switch raw {
        case "spotify":
            .spotify
        case "appleMusic":
            .appleMusic
        case "deezer":
            .deezer
        case "tidal":
            .tidal
        case "youtubeMusic":
            .youtubeMusic
        case "amazonMusic":
            .amazonMusic
        default:
            .unknown(raw)
        }
    }

}
