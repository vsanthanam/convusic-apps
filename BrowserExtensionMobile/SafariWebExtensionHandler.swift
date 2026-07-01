//
// Convusic
// Copyright 2026 Varun Santhanam
//

import ConvusicKit
import Foundation
import SafariServices

/// Native side of the Safari extension's `sendNativeMessage` bridge.
///
/// Three messages, mirroring the JS in `Resources/`:
///   - `"service"`   → `{ service: <preferred display name> }` (or empty when unset)
///   - `"request"`   → eligibility: `{ message: "pass" }` if the page is a known
///                     music host on a service other than the preferred one,
///                     else `{ error: "ineligible" }`
///   - `"transform"` → resolve via ``ConvusicService`` and return
///                     `{ url: <preferred-service link> }`.
final class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        let item = context.inputItems.first as? NSExtensionItem
        let message = item?.userInfo?[SFExtensionMessageKey] as? [String: String]

        func respond(_ payload: [String: Any]) {
            let response = NSExtensionItem()
            response.userInfo = [SFExtensionMessageKey: payload]
            context.completeRequest(returningItems: [response], completionHandler: nil)
        }

        switch message?["message"] {
        case "service":
            if let name = preferredPlatform?.displayName {
                respond(["service": name])
            } else {
                respond([:])
            }

        case "request":
            guard let urlString = message?["url"],
                  let url = URL(string: urlString),
                  let preference = preferredPlatform,
                  isKnown(preference),
                  isKnown(Platform(host: url.host())),
                  Platform(host: url.host()) != preference else {
                respond(["error": "ineligible"])
                return
            }
            respond(["message": "pass"])

        case "transform":
            guard let urlString = message?["url"],
                  let preference = preferredPlatform,
                  isKnown(preference) else {
                respond(["error": "ineligible"])
                return
            }
            Task {
                do {
                    let market = Locale.current.region?.identifier
                    let result = try await ConvusicService.shared.resolve(urlString, market: market)
                    guard let destination = result.link(for: preference)?.url else {
                        respond([
                            "error": "no_match",
                            "description": "No \(preference.displayName) link found for this page.",
                        ])
                        return
                    }
                    respond(["url": destination])
                } catch let error as APIError {
                    respond(["error": "conversion_failed", "description": error.message])
                } catch {
                    respond(["error": "conversion_failed", "description": error.localizedDescription])
                }
            }

        default:
            respond(["error": "unknown_message"])
        }
    }

    // MARK: - Private

    private let appGroupIdentifier = "group.com.varunsanthanam.Convusic"

    /// The user's preferred service, mirrored into the app group by the app's
    /// `PreferenceCoordinator` under the `"preferredService"` key.
    private var preferredPlatform: Platform? {
        guard let raw = UserDefaults(suiteName: appGroupIdentifier)?
            .string(forKey: "preferredService"),
            !raw.isEmpty else {
            return nil
        }
        return Platform(rawValue: raw)
    }

    private func isKnown(_ platform: Platform) -> Bool {
        if case .unknown = platform { false } else { true }
    }
}

extension NSExtensionItem: @retroactive @unchecked Sendable {}
extension NSExtensionContext: @retroactive @unchecked Sendable {}
