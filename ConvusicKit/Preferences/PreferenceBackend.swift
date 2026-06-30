//
// Convusic
// Copyright 2026 Varun Santhanam
//

import Foundation

/// An abstract key/value store over `PreferencePrimitive` values. Concrete
/// backends wrap `UserDefaults` and `NSUbiquitousKeyValueStore`; fakes can be
/// injected into the coordinator for testing.
public protocol PreferenceBackend: Sendable {

    func primitive(forKey key: String) -> PreferencePrimitive?

    @discardableResult
    func set(_ primitive: PreferencePrimitive?, forKey key: String) -> Bool

    func registerDefaults(_ defaults: [String: PreferencePrimitive])

    @discardableResult
    func synchronize() -> Bool

}

/// Backed by `UserDefaults.standard`.
public struct StandardDefaultsBackend: PreferenceBackend {

    public init() {}

    public func primitive(forKey key: String) -> PreferencePrimitive? {
        PreferencePrimitive(anyObject: store.object(forKey: key))
    }

    @discardableResult
    public func set(_ primitive: PreferencePrimitive?, forKey key: String) -> Bool {
        if let primitive {
            store.set(primitive.anyObject, forKey: key)
        } else {
            store.removeObject(forKey: key)
        }
        return true
    }

    public func registerDefaults(_ defaults: [String: PreferencePrimitive]) {
        store.register(defaults: defaults.mapValues(\.anyObject))
    }

    @discardableResult
    public func synchronize() -> Bool {
        true // `UserDefaults.synchronize()` is a deprecated no-op.
    }

    private var store: UserDefaults {
        .standard
    }

}

/// Backed by a shared app-group `UserDefaults`, so extensions can read the
/// same mirror of values.
public struct AppGroupDefaultsBackend: PreferenceBackend {

    public init(suiteName: String) {
        self.suiteName = suiteName
    }

    public func primitive(forKey key: String) -> PreferencePrimitive? {
        PreferencePrimitive(anyObject: store.object(forKey: key))
    }

    @discardableResult
    public func set(_ primitive: PreferencePrimitive?, forKey key: String) -> Bool {
        if let primitive {
            store.set(primitive.anyObject, forKey: key)
        } else {
            store.removeObject(forKey: key)
        }
        return true
    }

    public func registerDefaults(_ defaults: [String: PreferencePrimitive]) {
        store.register(defaults: defaults.mapValues(\.anyObject))
    }

    @discardableResult
    public func synchronize() -> Bool {
        true
    }

    private let suiteName: String

    /// `UserDefaults` is not `Sendable`, so recompute the suite instance on demand
    /// (it is documented thread-safe) instead of storing it.
    private var store: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }

}

/// Backed by `NSUbiquitousKeyValueStore.default` (iCloud KVS).
public struct UbiquitousBackend: PreferenceBackend {

    public init(maxValueBytes: Int = 1_000_000) {
        self.maxValueBytes = maxValueBytes
    }

    public func primitive(forKey key: String) -> PreferencePrimitive? {
        PreferencePrimitive(anyObject: store.object(forKey: key))
    }

    @discardableResult
    public func set(_ primitive: PreferencePrimitive?, forKey key: String) -> Bool {
        guard let primitive else {
            store.removeObject(forKey: key)
            return true
        }
        // Guard against the KVS per-value size limit (default 1 MB). KVS enforces
        // this on both data and string values, so check both.
        switch primitive {
        case let .data(data) where data.count > maxValueBytes:
            return false
        case let .string(string) where string.utf8.count > maxValueBytes:
            return false
        default:
            break
        }
        store.set(primitive.anyObject, forKey: key)
        return true
    }

    public func registerDefaults(_ defaults: [String: PreferencePrimitive]) {
        // KVS has no register-defaults API; defaults come from `key.defaultValue`.
    }

    @discardableResult
    public func synchronize() -> Bool {
        store.synchronize()
    }

    private let maxValueBytes: Int

    private var store: NSUbiquitousKeyValueStore {
        .default
    }

}

/// The coordinator's current view of iCloud availability.
public enum CloudAvailability: Sendable {

    case available

    case accountUnavailable

    case quotaExceeded

}

/// A `Sendable` snapshot extracted synchronously from the (non-`Sendable`)
/// KVS change `Notification`, so nothing non-`Sendable` ever crosses into the
/// apply method.
public struct KVSExternalChange: Sendable {

    public enum Reason: Sendable {

        case server

        case initialSync

        case quota

        case accountChange

        case unknown

    }

    public let reason: Reason

    public let changedKeys: [String]

    public init(userInfo: [AnyHashable: Any]?) {
        let raw = (userInfo?[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int) ?? -1
        self.reason = switch raw {
        case NSUbiquitousKeyValueStoreServerChange:
            .server
        case NSUbiquitousKeyValueStoreInitialSyncChange:
            .initialSync
        case NSUbiquitousKeyValueStoreQuotaViolationChange:
            .quota
        case NSUbiquitousKeyValueStoreAccountChange:
            .accountChange
        default:
            .unknown
        }
        self.changedKeys = (userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String]) ?? []
    }

}
