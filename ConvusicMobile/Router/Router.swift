//
// Convusic
// Copyright 2026 Varun Santhanam
//

import Foundation
import Observation

enum Route: Hashable {
    case history
}

enum SheetRoute: Hashable, Identifiable {
    case settings

    var id: Self {
        self
    }
}

enum SettingsRoute: Hashable {
    case defaultService
    case instructions
    case acknowledgements
}

@MainActor
@Observable
final class Router {

    var path: [Route] = []

    var sheet: SheetRoute?

    var settingsPath: [SettingsRoute] = []

    /// When set, the search screen should resolve this URL and clear the value.
    var pendingResolveURL: String?

    func handle(_ url: URL) {
        if url.scheme == "convusic" {
            handleCustomScheme(url)
        } else if url.scheme == "https" || url.scheme == "http" {
            handleUniversalLink(url)
        }
    }

    private func handleCustomScheme(
        _ url: URL
    ) {
        switch url.host {
        case "history":
            sheet = nil
            path = [.history]
        case "settings":
            path = []
            sheet = .settings
            settingsPath = []
        case "default-service":
            presentSettings(at: .defaultService)
        case "instructions":
            presentSettings(at: .instructions)
        case "acknowledgements":
            presentSettings(at: .acknowledgements)
        case "resolve":
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if let target = components?.queryItems?.first(where: { $0.name == "url" })?.value {
                resolve(target)
            }
        default:
            break
        }
    }

    private func presentSettings(at route: SettingsRoute) {
        path = []
        sheet = .settings
        settingsPath = [route]
    }

    private func handleUniversalLink(_ url: URL) {
        // Expected shape: https://convusic.app/r/<percent-encoded-url>
        // Adjust to match the App Site Association path you publish.
        let components = url.pathComponents.dropFirst()
        guard components.first == "r",
              let encoded = components.dropFirst().first,
              let decoded = encoded.removingPercentEncoding else {
            return
        }
        resolve(decoded)
    }

    private func resolve(_ target: String) {
        path = []
        sheet = nil
        settingsPath = []
        pendingResolveURL = target
    }

}
