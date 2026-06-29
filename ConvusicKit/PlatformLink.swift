//
// Convusic
// Copyright 2026 Varun Santhanam
//

import Foundation

public struct PlatformLink: Identifiable, Codable, Equatable, Sendable {

    public init(
        platform: Platform,
        url: String,
        id: String,
        confidence: Confidence
    ) {
        self.platform = platform
        self.url = url
        self.id = id
        self.confidence = confidence
    }

    public let platform: Platform

    public let url: String

    public let id: String // platform-native ID

    public let confidence: Confidence

    /// Convenience: `url` parsed into a `URL`, if valid.
    public var link: URL? {
        URL(string: url)
    }

}
