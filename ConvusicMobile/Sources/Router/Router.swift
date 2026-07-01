//
// Convusic
// Copyright 2026 Varun Santhanam
//

import Foundation
import Observation

/// Navigation-stack destinations. Currently empty (history was removed); kept as
/// the `NavigationStack` path element type for future push destinations.
enum Route: Hashable {}

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
        case "settings":
            presentSettings()
        case "default-service":
            presentSettings(at: .defaultService)
        case "instructions":
            presentSettings(at: .instructions)
        case "acknowledgements":
            presentSettings(at: .acknowledgements)
        case "open":
            handleOpen(url)
        default:
            break
        }
    }

    private func handleOpen(_ url: URL) {
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        if queryItems.isEmpty {
            clear()
            return
        }
        if let plain = queryItems.first(where: { $0.name == "url" })?.value {
            resolve(plain)
            return
        }
        if let encoded = queryItems.first(where: { $0.name == "encodedUrl" })?.value,
           let data = Data(base64Encoded: encoded),
           let decoded = String(data: data, encoding: .utf8) {
            resolve(decoded)
        }
    }

    private func presentSettings(
        at route: SettingsRoute? = nil
    ) {
        path = []
        sheet = .settings
        settingsPath = [route].compactMap(\.self)
    }

    private func handleUniversalLink(_ url: URL) {
        // Rewrite https://(www.)convusic.app/<path>?<query> to convusic://<path>?<query>
        // then route through the custom-scheme handler.
        guard let host = url.host(),
              host == "convusic.app" || host == "www.convusic.app" else {
            return
        }
        let prefix = "https://" + host + "/"
        let tail = url.absoluteString
            .replacingOccurrences(of: "http://" + host + "/", with: "")
            .replacingOccurrences(of: prefix, with: "")
        guard let rewritten = URL(string: "convusic://" + tail) else {
            return
        }
        handleCustomScheme(rewritten)
    }

    private func clear() {
        path = []
        sheet = nil
        settingsPath = []
        pendingResolveURL = nil
    }

    private func resolve(
        _ target: String
    ) {
        path = []
        sheet = nil
        settingsPath = []
        pendingResolveURL = target
    }

}
