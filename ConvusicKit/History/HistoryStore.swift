//
// Convusic
// Copyright 2026 Varun Santhanam
//

import CoreData
import Foundation
import Observation
import SwiftData

/// The single, `@MainActor`-isolated owner of the search-history `ModelContainer`
/// and the ONLY writer into it.
///
/// CloudKit/SwiftData impose two hard constraints this type works around:
///   - `NSPersistentCloudKitContainer` forbids `@Attribute(.unique)`, so URL
///     uniqueness is enforced in CODE: a fetch-before-insert in ``record(url:entity:)``
///     and a deterministic post-merge ``deduplicate()`` pass.
///   - A container's `cloudKitDatabase` cannot change after creation, so toggling
///     iCloud REBUILDS the container over the SAME on-disk store URL. Existing
///     local rows therefore graduate to CloudKit on enable and survive on disable.
///
/// The store reassigns its `@Observable` ``container`` and bumps ``generation`` on
/// every rebuild; the App re-injects the new `mainContext` via `.modelContainer(_:)`
/// and the History destination keys off `generation` to force a clean `@Query` rebind.
@MainActor
@Observable
public final class HistoryStore {

    // MARK: - Initializers

    public init(
        cloudContainerIdentifier: String = "iCloud.Convusic",
        appGroupIdentifier: String = "group.com.varunsanthanam.Convusic"
    ) {
        self.cloudContainerIdentifier = cloudContainerIdentifier
        self.storeURL = Self.makeStoreURL(appGroupIdentifier: appGroupIdentifier)
        // Build a LOCAL-ONLY container synchronously: it is always safe and the
        // real cloud state is not yet known. The App calls `reconfigure` from its
        // `.task`/`.onChange` once preferences/account availability are resolved.
        let (container, isCloud) = Self.makeContainer(
            cloud: false,
            storeURL: storeURL,
            cloudContainerIdentifier: cloudContainerIdentifier
        )
        self.container = container
        self.isCloudActive = isCloud
        startObservingRemoteChanges()
    }

    // MARK: - API

    /// The current container. Attach via `.modelContainer(historyStore.container)`;
    /// reading it in the App body re-injects a fresh `mainContext` on rebuild.
    public private(set) var container: ModelContainer

    /// Bumped on every container rebuild. Put `.id(historyStore.generation)` on the
    /// History view so its `@Query` tears down and re-binds to the new context.
    public private(set) var generation: Int = 0

    /// Rebuild the container if the desired cloud mode differs from the active one.
    ///
    /// `wantCloud` requires BOTH the master flag and a signed-in iCloud account, so
    /// a signed-out device never attempts cloud (the `try?` fallback still covers a
    /// genuine throw). After a rebuild, a `deduplicate()` pass collapses any rows
    /// that arrived via the mirror.
    public func reconfigure(cloudEnabled: Bool, accountAvailable: Bool) {
        let wantCloud = cloudEnabled && accountAvailable
        guard wantCloud != isCloudActive else { return }
        let (newContainer, isCloud) = Self.makeContainer(
            cloud: wantCloud,
            storeURL: storeURL,
            cloudContainerIdentifier: cloudContainerIdentifier
        )
        container = newContainer
        isCloudActive = isCloud
        generation += 1
        deduplicate()
    }

    /// Record a successful resolve, enforcing URL uniqueness in code: if a row with
    /// the same URL exists, bump its timestamp (move-to-top) instead of inserting a
    /// duplicate. No-ops for `.unknown` entities (no displayable metadata).
    public func record(url: URL, entity: ResolvedEntity) {
        guard let data = EntityData(entity) else { return }
        let key = url.absoluteString
        let context = container.mainContext
        var descriptor = FetchDescriptor<SearchResultHistory>(
            predicate: #Predicate { $0.urlString == key }
        )
        descriptor.fetchLimit = 1
        let host = url.host() ?? ""
        // Distinguish a thrown fetch (store not ready / transient CloudKit error)
        // from an empty result: on a throw, bail rather than fall through to the
        // insert branch, which would manufacture a duplicate-URL row that the
        // fetch-before-insert guard is meant to prevent.
        let existing: SearchResultHistory?
        do {
            existing = try context.fetch(descriptor).first
        } catch {
            return
        }
        if let existing {
            existing.touch(service: host, entityData: data)
        } else {
            context.insert(
                SearchResultHistory(url: url, service: host, entityData: data)
            )
        }
        try? context.save()
    }

    /// Delete a single entry.
    public func delete(_ entry: SearchResultHistory) {
        let context = container.mainContext
        context.delete(entry)
        try? context.save()
    }

    /// Delete every entry. Uses per-object deletes (NOT the batch
    /// `delete(model:)`) so each removal produces persistent history that
    /// `NSPersistentCloudKitContainer` exports — a batch delete bypasses the
    /// export pipeline, leaving rows in CloudKit to resurrect on the next import.
    public func clear() {
        let context = container.mainContext
        let rows = (try? context.fetch(FetchDescriptor<SearchResultHistory>())) ?? []
        for row in rows {
            context.delete(row)
        }
        try? context.save()
    }

    /// Collapse duplicate-URL rows to one survivor per URL.
    ///
    /// Winner is deterministic across devices — newest `timestamp`, breaking ties on
    /// the device-independent `identifier` (descending) — so every device converges
    /// on the SAME survivor and no delete/insert churn loops through the mirror.
    public func deduplicate() {
        let context = container.mainContext
        guard let all = try? context.fetch(FetchDescriptor<SearchResultHistory>()) else { return }
        let groups = Dictionary(grouping: all, by: \.urlString)
        var didDelete = false
        for (_, rows) in groups where rows.count > 1 {
            let sorted = rows.sorted { lhs, rhs in
                if lhs.timestamp != rhs.timestamp {
                    return lhs.timestamp > rhs.timestamp
                }
                return lhs.identifier > rhs.identifier
            }
            for loser in sorted.dropFirst() {
                context.delete(loser)
                didDelete = true
            }
        }
        if didDelete {
            try? context.save()
        }
    }

    // MARK: - Private

    @ObservationIgnored
    private let cloudContainerIdentifier: String

    @ObservationIgnored
    private let storeURL: URL

    @ObservationIgnored
    private var isCloudActive: Bool

    @ObservationIgnored
    private nonisolated(unsafe) var observerToken: NSObjectProtocol?

    @ObservationIgnored
    private var deduplicateTask: Task<Void, Never>?

    nonisolated deinit {
        if let observerToken {
            NotificationCenter.default.removeObserver(observerToken)
        }
    }

    /// App-group store so the local and cloud configs hit the SAME file (rows
    /// graduate). Falls back to Application Support if the group container is nil.
    private static func makeStoreURL(appGroupIdentifier: String) -> URL {
        if let group = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) {
            return group.appending(path: "History.sqlite")
        }
        return URL.applicationSupportDirectory.appending(path: "History.sqlite")
    }

    /// Build a container. Cloud builds are wrapped so a CloudKit failure (not signed
    /// in, container unavailable) falls back to local-only, then to a last-resort
    /// in-memory store so the app never bricks. Returns whether cloud is active.
    private static func makeContainer(
        cloud: Bool,
        storeURL: URL,
        cloudContainerIdentifier: String
    ) -> (ModelContainer, Bool) {
        let schema = Schema([SearchResultHistory.self])
        if cloud {
            let cloudConfig = ModelConfiguration(
                schema: schema,
                url: storeURL,
                cloudKitDatabase: .private(cloudContainerIdentifier)
            )
            if let container = try? ModelContainer(for: schema, configurations: cloudConfig) {
                return (container, true)
            }
        }
        let localConfig = ModelConfiguration(
            schema: schema,
            url: storeURL,
            cloudKitDatabase: .none
        )
        if let container = try? ModelContainer(for: schema, configurations: localConfig) {
            return (container, false)
        }
        let memoryConfig = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        // If even an in-memory container cannot be built the process is unusable;
        // this `try!` mirrors SwiftData's own non-recoverable failure semantics.
        let container = try! ModelContainer(for: schema, configurations: memoryConfig)
        return (container, false)
    }

    /// Observe CloudKit-driven imports and collapse duplicates that arrive via the
    /// mirror. Filtered by notification NAME (not by store object) so the single
    /// observer survives every container rebuild.
    private func startObservingRemoteChanges() {
        observerToken = NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            // `queue: .main` guarantees the main thread, so assume isolation.
            MainActor.assumeIsolated {
                self?.scheduleDeduplicate()
            }
        }
    }

    /// Debounce: coalesce an import burst into a single dedup pass.
    private func scheduleDeduplicate() {
        deduplicateTask?.cancel()
        deduplicateTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            self?.deduplicate()
        }
    }
}
