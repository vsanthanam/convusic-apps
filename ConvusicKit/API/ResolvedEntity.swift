//
// Convusic
// Copyright 2026 Varun Santhanam
//

/// The resolved entity, type-tagged so each case carries only the fields that apply.
public enum ResolvedEntity: Codable, Equatable, Sendable {

    case track(TrackPage)

    case album(AlbumPage)

    case artist(ArtistPage)

    case unknown(type: String)

    public init(from decoder: Decoder) throws {
        let type = try decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .type)
        switch type {
        case "track":
            self = try .track(TrackPage(from: decoder))
        case "album":
            self = try .album(AlbumPage(from: decoder))
        case "artist":
            self = try .artist(ArtistPage(from: decoder))
        case let other:
            self = .unknown(type: other)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .track(page):
            try container.encode("track", forKey: .type)
            try page.encode(to: encoder)
        case let .album(page):
            try container.encode("album", forKey: .type)
            try page.encode(to: encoder)
        case let .artist(page):
            try container.encode("artist", forKey: .type)
            try page.encode(to: encoder)
        case let .unknown(type):
            try container.encode(type, forKey: .type)
        }
    }

    /// Artwork URL for whichever page this is.
    public var artworkURL: String? {
        switch self {
        case let .track(page): page.artworkURL
        case let .album(page): page.artworkURL
        case let .artist(page): page.artworkURL
        case .unknown: nil
        }
    }

    /// The market the data was fetched in.
    public var market: String? {
        switch self {
        case let .track(page): page.market
        case let .album(page): page.market
        case let .artist(page): page.market
        case .unknown: nil
        }
    }

    /// A track/album title, or an artist's name.
    public var displayName: String? {
        switch self {
        case let .track(page): page.title
        case let .album(page): page.title
        case let .artist(page): page.name
        case .unknown: nil
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type
    }
}
