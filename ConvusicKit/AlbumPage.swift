//
// Convusic
// Copyright 2026 Varun Santhanam
//

import Foundation

public struct AlbumPage: Codable, Equatable, Sendable {

    public init(
        upc: String? = nil,
        title: String,
        artists: [Artist] = [],
        artworkURL: String? = nil,
        market: String
    ) {
        self.upc = upc
        self.title = title
        self.artists = artists
        self.artworkURL = artworkURL
        self.market = market
    }

    public let upc: String?

    public let title: String

    public let artists: [Artist]

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
        case upc
        case title
        case artists
        case artworkURL = "artworkUrl"
        case market
    }
}
