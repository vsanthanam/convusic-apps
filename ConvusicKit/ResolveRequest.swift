//
// Convusic
// Copyright 2026 Varun Santhanam
//

public struct ResolveRequest: Codable, Equatable, Sendable {

    public init(
        url: String,
        market: String? = nil
    ) {
        self.url = url
        self.market = market
    }

    public let url: String

    public let market: String?

}
