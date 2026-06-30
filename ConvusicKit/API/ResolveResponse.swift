//
// Convusic
// Copyright 2026 Varun Santhanam
//

public struct ResolveResponse: Codable, Equatable, Sendable {

    public init(
        entity: ResolvedEntity,
        links: [PlatformLink]
    ) {
        self.entity = entity
        self.links = links
    }

    public let entity: ResolvedEntity

    public let links: [PlatformLink]

    public func link(
        for platform: Platform
    ) -> PlatformLink? {
        links
            .first { link in
                link.platform == platform
            }
    }
}
