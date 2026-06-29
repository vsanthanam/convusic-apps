//
// Convusic
// Copyright 2026 Varun Santhanam
//

import Foundation

public struct APIError: Codable, Equatable, Sendable, Error, LocalizedError {

    public init(
        error: Body
    ) {
        self.error = error
    }

    public struct Body: Codable, Equatable, Sendable {

        public init(
            code: ConvusicErrorCode,
            message: String
        ) {
            self.code = code
            self.message = message
        }

        public let code: ConvusicErrorCode

        public let message: String

    }

    public let error: Body

    public var code: ConvusicErrorCode {
        error.code
    }

    public var message: String {
        error.message
    }

    public var errorDescription: String? {
        error.message
    }

}
