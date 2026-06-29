//
// Convusic
// Copyright 2026 Varun Santhanam
//

public struct Artist: Codable, Equatable, Sendable {

    public init(
        name: String
    ) {
        self.name = name
    }

    public let name: String

}
