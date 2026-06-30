//
// Convusic
// Copyright 2026 Varun Santhanam
//

import ConvusicKit
import SwiftData
import SwiftUI

struct HistoryView: View {

    // MARK: - View

    var body: some View {
        Group {
            if entries.isEmpty {
                ContentUnavailableView(
                    "No History Yet",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Resolved links will appear here.")
                )
            } else {
                List {
                    ForEach(entries) { entry in
                        Button {
                            select(entry)
                        } label: {
                            row(for: entry)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { offsets in
                        offsets.map { entries[$0] }.forEach(historyStore.delete)
                    }
                }
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !entries.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear", role: .destructive) {
                        historyStore.clear()
                    }
                }
            }
        }
    }

    // MARK: - Private

    @Query(sort: \SearchResultHistory.timestamp, order: .reverse)
    private var entries: [SearchResultHistory]

    @Environment(HistoryStore.self)
    private var historyStore

    @Environment(Router.self)
    private var router

    private func row(for entry: SearchResultHistory) -> some View {
        HStack(spacing: 14) {
            entityBadge(for: entry)
            VStack(alignment: .leading, spacing: 3) {
                Text(entityLabel(for: entry))
                    .font(.caption2.bold())
                    .tracking(2)
                    .foregroundStyle(.tint)
                Text(title(for: entry))
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                if let subtitle = subtitle(for: entry) {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Text("\(serviceName(for: entry)) · \(entry.timestamp.formatted(.relative(presentation: .named)))")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
    }

    private func entityBadge(
        for entry: SearchResultHistory
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(.tint.opacity(0.18))
            Image(systemName: entitySymbol(for: entry))
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.tint)
        }
        .frame(width: 40, height: 40)
    }

    private func entityLabel(for entry: SearchResultHistory) -> String {
        switch entry.entityData {
        case .song:
            "TRACK"
        case .album:
            "ALBUM"
        case .artist:
            "ARTIST"
        case .none:
            "LINK"
        }
    }

    private func entitySymbol(for entry: SearchResultHistory) -> String {
        switch entry.entityData {
        case .song:
            "music.note"
        case .album:
            "square.stack"
        case .artist:
            "person.fill"
        case .none:
            "link"
        }
    }

    private func serviceName(for entry: SearchResultHistory) -> String {
        let platform = Platform(host: entry.service)
        if case .unknown = platform {
            return entry.service.isEmpty ? "Link" : entry.service
        }
        return platform.displayName
    }

    private func title(for entry: SearchResultHistory) -> String {
        switch entry.entityData {
        case let .song(name, _, _):
            name
        case let .album(name, _):
            name
        case let .artist(name):
            name
        case .none:
            entry.url?.host() ?? entry.urlString
        }
    }

    private func subtitle(for entry: SearchResultHistory) -> String? {
        switch entry.entityData {
        case let .song(_, artists, _):
            artists
        case let .album(_, artists):
            artists
        case .artist:
            nil
        case .none:
            nil
        }
    }

    private func select(_ entry: SearchResultHistory) {
        guard let url = entry.url else { return }
        // Re-resolve the link (results may have changed / been delisted) and pop
        // the History page: SearchView observes `pendingResolveURL` and re-runs
        // `search(...)`; clearing the path dismisses History.
        router.pendingResolveURL = url.absoluteString
        router.path.removeAll()
    }

}

#Preview {
    let store = HistoryStore()
    NavigationStack {
        HistoryView()
    }
    .environment(Router())
    .environment(store)
    .modelContainer(store.container)
}
