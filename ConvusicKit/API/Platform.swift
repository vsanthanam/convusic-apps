//
// Convusic
// Copyright 2026 Varun Santhanam
//

public enum Platform: Codable, Hashable, Sendable {

    case spotify

    case appleMusic

    case deezer

    case tidal

    case youtubeMusic

    case amazonMusic

    case unknown(String)

    public init(
        from decoder: Decoder
    ) throws {
        try self.init(rawValue: decoder.singleValueContainer().decode(String.self))
    }

    /// Reconstruct a `Platform` from its ``rawValue`` string. Non-failable: an
    /// unrecognized string maps to `.unknown(raw)`. `Platform` is not
    /// `RawRepresentable` because of that fallback, so this is a plain initializer.
    public init(rawValue raw: String) {
        switch raw {
        case "spotify":
            self = .spotify
        case "appleMusic":
            self = .appleMusic
        case "deezer":
            self = .deezer
        case "tidal":
            self = .tidal
        case "youtubeMusic":
            self = .youtubeMusic
        case "amazonMusic":
            self = .amazonMusic
        default:
            self = .unknown(raw)
        }
    }

    public func encode(
        to encoder: Encoder
    ) throws {
        var c = encoder.singleValueContainer()
        try c.encode(rawValue)
    }

    /// Best-effort inference of the platform from a URL host (e.g. the
    /// `service` recorded with a history entry). Falls back to `.unknown(host)`.
    public init(host: String?) {
        let host = (host ?? "").lowercased()
        switch true {
        case host.contains("spotify"):
            self = .spotify
        case host.contains("music.apple"), host.contains("itunes.apple"):
            self = .appleMusic
        case host.contains("deezer"):
            self = .deezer
        case host.contains("tidal"):
            self = .tidal
        case host.contains("youtube"), host.contains("youtu.be"):
            self = .youtubeMusic
        case host.contains("amazon"):
            self = .amazonMusic
        default:
            self = .unknown(host)
        }
    }

    public var rawValue: String {
        switch self {
        case .spotify:
            "spotify"
        case .appleMusic:
            "appleMusic"
        case .deezer:
            "deezer"
        case .tidal:
            "tidal"
        case .youtubeMusic:
            "youtubeMusic"
        case .amazonMusic:
            "amazonMusic"
        case let .unknown(raw):
            raw
        }
    }

    /// Human-friendly label for UI.
    public var displayName: String {
        switch self {
        case .spotify:
            "Spotify"
        case .appleMusic:
            "Apple Music"
        case .deezer:
            "Deezer"
        case .tidal:
            "Tidal"
        case .youtubeMusic:
            "YouTube Music"
        case .amazonMusic:
            "Amazon Music"
        case let .unknown(raw):
            raw
        }
    }
}
