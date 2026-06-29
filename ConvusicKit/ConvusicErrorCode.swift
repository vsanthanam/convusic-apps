//
// Convusic
// Copyright 2026 Varun Santhanam
//

public enum ConvusicErrorCode: Codable, Hashable, Sendable {

    case unauthorized // 401 — missing/invalid X-Convusic-Key

    case unsupportedURL // 422 — unparseable / unsupported link or invalid body

    case unsupportedPlatform // 422

    case rateLimited // 429

    case sourceFetchFailed // 502 — upstream platform unreachable

    case notFound // 404

    case serverError // 500 — "INTERNAL"

    case unknown(String)

    public var rawValue: String {
        switch self {
        case .unauthorized:
            "UNAUTHORIZED"
        case .unsupportedURL:
            "UNSUPPORTED_URL"
        case .unsupportedPlatform:
            "UNSUPPORTED_PLATFORM"
        case .rateLimited:
            "RATE_LIMITED"
        case .sourceFetchFailed:
            "SOURCE_FETCH_FAILED"
        case .notFound:
            "NOT_FOUND"
        case .serverError:
            "INTERNAL"
        case let .unknown(raw):
            raw
        }
    }

    public init(
        from decoder: Decoder
    ) throws {
        switch try decoder.singleValueContainer().decode(String.self) {
        case "UNAUTHORIZED":
            self = .unauthorized
        case "UNSUPPORTED_URL":
            self = .unsupportedURL
        case "UNSUPPORTED_PLATFORM":
            self = .unsupportedPlatform
        case "RATE_LIMITED":
            self = .rateLimited
        case "SOURCE_FETCH_FAILED":
            self = .sourceFetchFailed
        case "NOT_FOUND":
            self = .notFound
        case "INTERNAL":
            self = .serverError
        case let other:
            self = .unknown(other)
        }
    }

    public func encode(
        to encoder: Encoder
    ) throws {
        var c = encoder.singleValueContainer()
        try c.encode(rawValue)
    }

}
