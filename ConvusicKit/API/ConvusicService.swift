//
// Convusic
// Copyright 2026 Varun Santhanam
//

import Foundation
import JBird
import SwiftUI

extension EnvironmentValues {

    @Entry
    var convusicService = ConvusicService(
        environment: .staging,
        apiKey: "d6a8c3c4-e997-4835-9441-f626bc7546b0"
    )

}

private struct ConvusicServiceModifier: ViewModifier {

    init(service: ConvusicService) {
        self.service = service
    }

    func body(content: Content) -> some View {
        content
            .environment(
                \.convusicService,
                service
            )
    }

    private let service: ConvusicService

}

extension View {

    public func convusicService(
        apiKey: String,
        environment: ConvusicService.Environment = .production
    ) -> some View {
        let service = ConvusicService(
            environment: environment,
            apiKey: apiKey
        )
        let modifier = ConvusicServiceModifier(service: service)
        return ModifiedContent(
            content: self,
            modifier: modifier
        )
    }

}

@propertyWrapper
public struct Convusic: DynamicProperty {

    public init() {}

    @Environment(\.convusicService)
    private var service

    public var wrappedValue: ConvusicService {
        service
    }

}

/// Minimal async client. Decodes a 2xx body into `ResolveResponse`, and any
/// non-2xx body into a thrown `APIError`.
public final class ConvusicService: Sendable {

    public enum Environment: String {
        case production = "https://api.convusic.app"
        case staging = "https://staging.api.convusic.app"
        case development = "http://localhost:3000"
    }

    init(
        environment: Environment,
        apiKey: String,
        session: URLSession = .shared
    ) {
        self.baseURL = URL(string: environment.rawValue)!
        self.apiKey = apiKey
        self.session = session
    }

    public func resolve(
        _ link: String,
        market: String? = nil
    ) async throws -> ResolveResponse {
        var request = URLRequest(url: baseURL.appendingPathComponent("v1/resolve"))

        request.httpMethod = "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.setValue(
            apiKey,
            forHTTPHeaderField: "X-Convusic-Key"
        )

        request.timeoutInterval = 20

        request.httpBody = try JSON.Encoder().encode(
            ResolveRequest(
                url: link,
                market: market
            )
        )

        let (data, response) = try await session.data(for: request)

        let status = (response as? HTTPURLResponse)?.statusCode ?? -1

        guard (200..<300).contains(status) else {
            if let apiError = try? JSON.Decoder().decode(
                APIError.self,
                from: data
            ) {
                throw apiError
            }
            throw APIError(
                error: .init(
                    code: .unknown("HTTP_\(status)"),
                    message: "Request failed (\(status))"
                )
            )
        }
        return try JSON.Decoder().decode(
            ResolveResponse.self,
            from: data
        )
    }

    public func health() async throws -> HealthResponse {
        let (data, _) = try await session.data(from: baseURL.appendingPathComponent("health"))
        return try JSON.Decoder().decode(
            HealthResponse.self,
            from: data
        )
    }

    private let baseURL: URL

    private let apiKey: String

    private let session: URLSession

}
