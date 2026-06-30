//
// Convusic
// Copyright 2026 Varun Santhanam
//

import Foundation

/// Where a given preference is persisted.
public enum PreferenceScope: Sendable {

    /// `UserDefaults.standard` + the app-group mirror only.
    case appLocal

    /// Also `NSUbiquitousKeyValueStore`, but only when `useiCloud` is ON.
    case synced

}

/// A strongly-typed description of a single preference: its name, default, and
/// storage scope.
public struct PreferenceDescriptor<Value: Storable>: Sendable {

    public let name: String

    public let defaultValue: Value

    public let scope: PreferenceScope

    public init(
        _ name: String,
        default defaultValue: Value,
        scope: PreferenceScope
    ) {
        self.name = name
        self.defaultValue = defaultValue
        self.scope = scope
    }

}

// MARK: - Canonical keys

extension PreferenceDescriptor where Value == Platform? {

    /// The user's preferred / default music service. Synced via iCloud.
    public static var preferredService: Self {
        .init("preferredService", default: nil, scope: .synced)
    }

}

extension PreferenceDescriptor where Value == Bool {

    /// Whether the app should open links found on the clipboard. Synced.
    public static var openFromClipboard: Self {
        .init("openFromClipboard", default: false, scope: .synced)
    }

    /// The local-only master iCloud toggle. Used internally by the coordinator.
    public static var useICloud: Self {
        .init("useiCloud", default: false, scope: .appLocal)
    }

}

/// Catalog of synced preference names and their encodable defaults. Used by the
/// coordinator to drive external-change pulls and default registration.
public enum PreferenceCatalog {

    /// Names the coordinator pulls on an external iCloud push.
    public static let syncedKeyNames: Set<String> = [
        "preferredService",
        "openFromClipboard",
    ]

    /// Encoded defaults registered into `UserDefaults` at launch.
    ///
    /// Synced keys are deliberately NOT registered here: a registered default
    /// makes `object(forKey:)` return a value for a key the user never set, which
    /// would be indistinguishable from a real user value and cause the enable-seed
    /// to push a phantom default UP to iCloud (clobbering another device). For
    /// synced keys the coordinator falls back to `key.defaultValue` instead, so
    /// reads are unaffected. Only app-local keys with a non-nil default belong here.
    public static func encodedDefaults() -> [String: PreferencePrimitive] {
        [:]
        // `openFromClipboard` / `preferredService` are `.synced` -> not registered.
    }

}
