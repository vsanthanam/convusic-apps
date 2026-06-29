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
        switch try decoder.singleValueContainer().decode(String.self) {
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
        case let other:
            self = .unknown(other)
        }
    }

    public func encode(
        to encoder: Encoder
    ) throws {
        var c = encoder.singleValueContainer()
        try c.encode(rawValue)
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
