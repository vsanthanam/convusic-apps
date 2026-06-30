//
// Convusic
// Copyright 2026 Varun Santhanam
//

import Foundation
import SwiftData

@Model
public final class SearchResultHistory {

    public init(
        url: URL,
        service: String = "",
        entityData: EntityData? = nil,
        timestamp: Date = .now,
        identifier: String = UUID().uuidString
    ) {
        self.urlString = url.absoluteString
        self.service = service
        self.entityData = entityData
        self.timestamp = timestamp
        self.identifier = identifier
    }

    public private(set) var urlString: String = ""

    public private(set) var service: String = ""

    public private(set) var entityData: EntityData?

    public internal(set) var timestamp: Date = Date.now

    public private(set) var identifier: String = UUID().uuidString

    public var url: URL? {
        URL(string: urlString)
    }

    public func touch(
        service: String,
        entityData: EntityData?,
        at date: Date = .now
    ) {
        timestamp = date
        if let entityData { self.entityData = entityData }
        if !service.isEmpty { self.service = service }
    }
}

public enum EntityData: Equatable, Hashable, Sendable, Codable {

    case song(name: String, artists: String, album: String)
    case album(name: String, artists: String)
    case artist(name: String)

    /// Bridge from the API's resolved entity. Returns `nil` for `.unknown` so the
    /// caller skips recording entries with no displayable metadata.
    public init?(_ entity: ResolvedEntity) {
        switch entity {
        case let .track(page):
            self = .song(name: page.title, artists: page.artistNames, album: page.album ?? "")
        case let .album(page):
            self = .album(name: page.title, artists: page.artistNames)
        case let .artist(page):
            self = .artist(name: page.name)
        case .unknown:
            return nil
        }
    }
}
