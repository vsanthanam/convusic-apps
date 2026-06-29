//
// Convusic
// Copyright 2026 Varun Santhanam
//

import Foundation

public struct TrackPage: Codable, Equatable, Sendable {

    public init(
        isrc: String? = nil,
        title: String,
        artists: [Artist] = [],
        album: String? = nil,
        durationMs: Int? = nil,
        explicit: Bool? = nil,
        artworkURL: String? = nil,
        market: String
    ) {
        self.isrc = isrc
        self.title = title
        self.artists = artists
        self.album = album
        self.durationMs = durationMs
        self.explicit = explicit
        self.artworkURL = artworkURL
        self.market = market
    }

    public let isrc: String?

    public let title: String

    public let artists: [Artist]

    public let album: String?

    public let durationMs: Int?

    public let explicit: Bool?

    public let artworkURL: String?

    public let market: String

    /// Convenience: `artworkURL` parsed into a `URL`, if valid.
    public var artwork: URL? {
        artworkURL.flatMap(URL.init(string:))
    }

    /// Convenience: comma-joined artist names.
    public var artistNames: String {
        artists.map(\.name).joined(separator: ", ")
    }

    private enum CodingKeys: String, CodingKey {
        case isrc
        case title
        case artists
        case album
        case durationMs
        case explicit
        case artworkURL = "artworkUrl"
        case market
    }
}
