//
// Convusic
// Copyright 2026 Varun Santhanam
//

public enum Confidence: Codable, Hashable, Sendable {

    case isrc

    case upc

    case fuzzyHigh

    case fuzzyLow

    case vendor

    case unknown(String)

    public var isExact: Bool {
        self == .isrc || self == .upc
    }

    public var rawValue: String {
        switch self {
        case .isrc:
            "isrc"
        case .upc:
            "upc"
        case .fuzzyHigh:
            "fuzzy_high"
        case .fuzzyLow:
            "fuzzy_low"
        case .vendor:
            "vendor"
        case let .unknown(raw):
            raw
        }
    }

    public init(
        from decoder: Decoder
    ) throws {
        switch try decoder.singleValueContainer().decode(String.self) {
        case "isrc":
            self = .isrc
        case "upc":
            self = .upc
        case "fuzzy_high":
            self = .fuzzyHigh
        case "fuzzy_low":
            self = .fuzzyLow
        case "vendor":
            self = .vendor
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
