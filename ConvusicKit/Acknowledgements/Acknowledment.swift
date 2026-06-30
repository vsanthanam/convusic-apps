//
// Convusic
// Copyright 2026 Varun Santhanam
//

import Foundation

public struct Acknowledgement: Sendable, Equatable, Hashable, Identifiable {

    public let id: String
    public let name: String
    public let url: URL

    public static let tools: [Acknowledgement] = [
        .init(
            id: "jbird",
            name: "JBird",
            url: URL(string: "https://www.usejbird.com")!
        ),
        .init(
            id: "safariui",
            name: "SafariUI",
            url: URL(string: "https://www.safariui.com")!
        ),
        .init(
            id: "viewscope",
            name: "ViewScope",
            url: URL(string: "https://www.viewsco.pe")!
        )
    ]

    public static let services: [Acknowledgement] = [
        .init(
            id: "applemusic",
            name: "Apple Music",
            url: URL(string: "https://www.apple.com/apple-music/")!
        ),
        .init(
            id: "spotify",
            name: "Spotify",
            url: URL(string: "https://www.spotify.com")!
        ),
        .init(
            id: "musicfetch",
            name: "MusicFetch",
            url: URL(string: "https://musicfetch.io")!
        ),
        .init(
            id: "railway",
            name: "Railway",
            url: URL(string: "https://railway.com")!
        ),
        .init(
            id: "cloudflare",
            name: "Cloudflare",
            url: URL(string: "https://cloudflare.com")!
        )
    ]

}
