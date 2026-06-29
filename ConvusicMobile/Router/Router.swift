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
            presentSettings()
        case "default-service":
            presentSettings(at: .defaultService)
        case "instructions":
            presentSettings(at: .instructions)
        case "acknowledgements":
            presentSettings(at: .acknowledgements)
        case "open":
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if let target = components?.queryItems?.first(where: { $0.name == "url" })?.value {
                resolve(target)
            }
        default:
            break
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
        // Paths declared in apple-app-site-association:
        //   /instructions, /open, /open*, /settings
        switch url.path {
        case "/settings":
            path = []
            sheet = .settings
            settingsPath = []
        case "/instructions":
            presentSettings(at: .instructions)
        case "/open":
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if let target = components?.queryItems?.first(where: { $0.name == "url" })?.value {
                resolve(target)
            }
        case "/acknowledgements":
            presentSettings(at: .acknowledgements)
        default:
            break
        }
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
