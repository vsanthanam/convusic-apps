//
// Convusic
// Copyright 2026 Varun Santhanam
//

public struct HealthResponse: Codable, Equatable, Sendable {

    public init(
        status: String,
        version: String
    ) {
        self.status = status
        self.version = version
    }

    public let status: String

    public let version: String

}
