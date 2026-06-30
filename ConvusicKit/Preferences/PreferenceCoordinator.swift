//
// Convusic
// Copyright 2026 Varun Santhanam
//

import Foundation
import Observation
import SwiftUI

/// The single, shared, `@MainActor`-isolated source of truth for preferences.
///
/// It owns the three backends, the per-key cell registry, the one KVS
/// `didChangeExternallyNotification` subscription, the local-only `useiCloud`
/// gate, reconciliation, external-change application, and feedback-loop dedup.
/// SwiftUI wrappers delegate to it entirely.
@MainActor
@Observable
public final class PreferenceCoordinator {

    public init(
        local: any PreferenceBackend = StandardDefaultsBackend(),
        group: any PreferenceBackend = AppGroupDefaultsBackend(suiteName: "group.com.varunsanthanam.Convusic"),
        cloud: any PreferenceBackend = UbiquitousBackend()
    ) {
        self.local = local
        self.group = group
        self.cloud = cloud
        let defaults = PreferenceCatalog.encodedDefaults()
        local.registerDefaults(defaults)
        group.registerDefaults(defaults)
        self.cloudEnabledStorage =
            (group.primitive(forKey: "useiCloud") ?? local.primitive(forKey: "useiCloud"))
                .flatMap(Bool.decoded(from:)) ?? false
        refreshCloudAvailability() // `didChangeExternally` never fires for a steady "signed-out" state.
        startObservingCloud()
        cloud.synchronize() // Kick an initial pull.
    }

    // MARK: - Reactive value API

    public func value<V: Storable>(for key: PreferenceDescriptor<V>) -> V {
        let cell = cell(forKey: key.name, scope: key.scope) // Reads `cell.current` -> tracks dep.
        if let primitive = cell.current, let decoded = V.decoded(from: primitive) {
            return decoded
        }
        return key.defaultValue
    }

    public func setValue<V: Storable>(_ value: V, for key: PreferenceDescriptor<V>) {
        let primitive = value.encodedForStorage()
        write(primitive, name: key.name, scope: key.scope)
        let cell = cell(forKey: key.name, scope: key.scope)
        if cell.current != primitive {
            cell.current = primitive // Dedup -> no spurious render.
        }
    }

    public func binding<V: Storable>(for key: PreferenceDescriptor<V>) -> Binding<V> {
        Binding(
            get: { self.value(for: key) },
            set: { self.setValue($0, for: key) }
        )
    }

    // MARK: - Master flag (local-only)

    public var isCloudEnabled: Bool {
        get { cloudEnabledStorage }
        set { setCloudEnabled(newValue) }
    }

    public private(set) var cloudAvailability: CloudAvailability = .available

    /// Whether an iCloud account is currently signed in on the device. Drives
    /// whether the "Use iCloud" toggle should be interactive. Reading this in a
    /// SwiftUI `body` tracks `cloudAvailability`, so the UI updates when the user
    /// signs in/out (after a `refreshCloudAvailability()`).
    public var isCloudAccountAvailable: Bool {
        cloudAvailability != .accountUnavailable
    }

    /// Re-evaluate iCloud sign-in state from `ubiquityIdentityToken`. KVS only
    /// posts an account-change notification when the account *changes*, never for
    /// the steady signed-out state, so this must be called proactively: at launch
    /// (from `init`) and whenever the app returns to the foreground.
    public func refreshCloudAvailability() {
        let signedIn = FileManager.default.ubiquityIdentityToken != nil
        if !signedIn {
            cloudAvailability = .accountUnavailable
        } else if cloudAvailability == .accountUnavailable {
            // Recovered: an account is present again.
            cloudAvailability = .available
            if cloudEnabledStorage {
                flushPendingPushes() // Push edits made while signed out (local-wins) ...
                cloud.synchronize() // ... then let the external-change handler pull server state.
            }
        }
        // Token present + already `.available`/`.quotaExceeded`: leave as-is.
    }

    public func setCloudEnabled(_ enabled: Bool) {
        guard enabled != cloudEnabledStorage else {
            return
        }
        cloudEnabledStorage = enabled
        let primitive = PreferencePrimitive.bool(enabled)
        local.set(primitive, forKey: "useiCloud")
        group.set(primitive, forKey: "useiCloud") // Mirror so the extension knows the mode; NEVER cloud.
        if enabled {
            reconcileOnEnable() // Disable == freeze: keep local, keep cloud.
        }
    }

    // MARK: - Private state

    @ObservationIgnored
    private let local: any PreferenceBackend

    @ObservationIgnored
    private let group: any PreferenceBackend

    @ObservationIgnored
    private let cloud: any PreferenceBackend

    @ObservationIgnored
    private var cells: [String: PreferenceCell] = [:]

    @ObservationIgnored
    private nonisolated(unsafe) var observerToken: NSObjectProtocol?

    /// Set when iCloud was just enabled: local values are seeded UP to the cloud
    /// only after the next external change confirms the actual server state, so
    /// we never clobber not-yet-downloaded server data (`synchronize()` does not
    /// download synchronously).
    @ObservationIgnored
    private var pendingCloudSeed = false

    /// Synced keys written while the cloud was unavailable (quota/account). They
    /// are pushed UP when availability recovers, so offline edits are not lost.
    @ObservationIgnored
    private var pendingCloudPushes: Set<String> = []

    private var cloudEnabledStorage: Bool

    private func cell(
        forKey name: String,
        scope: PreferenceScope
    ) -> PreferenceCell {
        if let existing = cells[name] {
            return existing
        }
        let cell = PreferenceCell(readPrimitive(name: name, scope: scope))
        cells[name] = cell
        return cell
    }

    /// Resolution order: cloud (if synced + enabled + available) -> group -> local.
    private func readPrimitive(
        name: String,
        scope: PreferenceScope
    ) -> PreferencePrimitive? {
        if scope == .synced,
           cloudEnabledStorage,
           cloudAvailability == .available,
           let cloudPrimitive = cloud.primitive(forKey: name) {
            return cloudPrimitive
        }
        return group.primitive(forKey: name) ?? local.primitive(forKey: name)
    }

    private func write(
        _ primitive: PreferencePrimitive?,
        name: String,
        scope: PreferenceScope
    ) {
        local.set(primitive, forKey: name)
        group.set(primitive, forKey: name)
        guard scope == .synced, cloudEnabledStorage else {
            return
        }
        if cloudAvailability == .available {
            if cloud.set(primitive, forKey: name) {
                cloud.synchronize()
            }
            // `false` == KVS rejected (oversize); local mirrors still hold the value.
        } else {
            // Cloud is temporarily unavailable (quota/account). Remember the key
            // so the local edit is pushed up once availability recovers.
            pendingCloudPushes.insert(name)
        }
    }

    private func startObservingCloud() {
        observerToken = NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: NSUbiquitousKeyValueStore.default,
            queue: .main
        ) { [weak self] note in
            let change = KVSExternalChange(userInfo: note.userInfo) // Sendable snapshot.
            // `queue: .main` guarantees the main thread, so we can assume isolation
            // and apply synchronously -> no async hop, no interleave with a local
            // write mid-flight. `[weak self]` breaks the NotificationCenter retain
            // cycle so injected (non-singleton) instances can deallocate.
            MainActor.assumeIsolated {
                guard let self else {
                    return
                }
                self.applyExternalChange(change)
            }
        }
    }

    private func applyExternalChange(
        _ change: KVSExternalChange
    ) {
        switch change.reason {
        case .quota:
            cloudAvailability = .quotaExceeded // Surface; do NOT re-write.
        case .accountChange:
            // Posted on sign-IN as well as sign-out, so re-evaluate rather than
            // latching `.accountUnavailable` until an unrelated server push. A
            // non-nil identity token means an account is present and the local
            // KVS now reflects it; re-prime from it.
            if FileManager.default.ubiquityIdentityToken != nil {
                becomeCloudAvailable(change: change)
            } else {
                cloudAvailability = .accountUnavailable // Keep local mirrors intact.
            }
        case .server, .initialSync, .unknown:
            becomeCloudAvailable(change: change)
        }
    }

    /// Transition to `.available` and reconcile: push any edits made while the
    /// cloud was unavailable UP first (local-wins for those keys), pull the
    /// remaining changed keys DOWN, then finish a pending enable-seed for keys
    /// still absent in the cloud.
    private func becomeCloudAvailable(
        change: KVSExternalChange
    ) {
        cloudAvailability = .available
        guard cloudEnabledStorage else {
            return // Disabled => ignore cloud.
        }
        let pushed = flushPendingPushes()
        var names = change.reason == .unknown || change.changedKeys.isEmpty
            ? PreferenceCatalog.syncedKeyNames // Defensive full refresh.
            : Set(change.changedKeys).intersection(PreferenceCatalog.syncedKeyNames)
        names.subtract(pushed) // Don't pull-clobber edits we just pushed up.
        for name in names {
            pull(name: name)
        }
        if pendingCloudSeed {
            seedCloudFromLocal()
            pendingCloudSeed = false
        }
    }

    /// Push keys edited while the cloud was unavailable UP to iCloud. Returns the
    /// set pushed so callers can avoid immediately pulling them back down.
    @discardableResult
    private func flushPendingPushes() -> Set<String> {
        guard !pendingCloudPushes.isEmpty else {
            return []
        }
        let flushed = pendingCloudPushes
        pendingCloudPushes.removeAll()
        for name in flushed {
            let primitive = group.primitive(forKey: name) ?? local.primitive(forKey: name)
            cloud.set(primitive, forKey: name)
        }
        cloud.synchronize()
        return flushed
    }

    /// Seed the cloud from local ONLY for synced keys it does not already hold,
    /// after an external change has confirmed the real server state. Never
    /// overwrites a value present in the cloud (cloud-wins on enable).
    private func seedCloudFromLocal() {
        for name in PreferenceCatalog.syncedKeyNames where cloud.primitive(forKey: name) == nil {
            if let localPrimitive = group.primitive(forKey: name) ?? local.primitive(forKey: name) {
                cloud.set(localPrimitive, forKey: name)
            }
        }
        cloud.synchronize()
    }

    /// Mirror a cloud value down (type-agnostic primitive copy) and update the cell.
    ///
    /// A `nil` cloud value means "iCloud has nothing for this key", NOT "delete";
    /// treating it as a deletion would wipe the user's local/group preferences on
    /// an empty/initial-sync push, so we leave the mirrors untouched in that case.
    private func pull(name: String) {
        guard let primitive = cloud.primitive(forKey: name) else {
            return
        }
        local.set(primitive, forKey: name)
        group.set(primitive, forKey: name)
        if let cell = cells[name] {
            if cell.current != primitive {
                cell.current = primitive // Dedup -> exact invalidation.
            }
        }
        // If no cell exists yet, the next `value(for:)` primes from the freshly-mirrored stores.
    }

    private func reconcileOnEnable() {
        guard cloudAvailability == .available else {
            return // Do not seed while signed-out.
        }
        // `NSUbiquitousKeyValueStore.synchronize()` only schedules a download; it
        // does NOT fetch from the server synchronously. Reading the cloud here and
        // seeding from local would therefore overwrite another device's data that
        // simply has not finished downloading. So:
        //   1. Apply whatever the cloud ALREADY holds locally (cloud-wins).
        //   2. Defer seeding local -> cloud until the `didChangeExternally`
        //      handler confirms the real server state (`pendingCloudSeed`).
        pendingCloudSeed = true
        cloud.synchronize() // Kick a pull; the external-change handler completes the seed.
        for name in PreferenceCatalog.syncedKeyNames {
            pull(name: name) // Non-destructive: only mirrors keys the cloud already holds.
        }
    }

    nonisolated deinit {
        if let observerToken {
            NotificationCenter.default.removeObserver(observerToken)
        }
    }

}
