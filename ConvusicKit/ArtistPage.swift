//
// Convusic
// Copyright 2026 Varun Santhanam
//

import Foundation

public struct ArtistPage: Codable, Equatable, Sendable {

    public init(
        name: String,
        artworkURL: String? = nil,
        market: String
    ) {
        self.name = name
        self.artworkURL = artworkURL
        self.market = market
    }

    public let name: String

    public let artworkURL: String?

    public let market: String

    /// Convenience: `artworkURL` parsed into a `URL`, if valid.
    public var artwork: URL? {
        artworkURL.flatMap(URL.init(string:))
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case artworkURL = "artworkUrl"
        case market
    }
}
