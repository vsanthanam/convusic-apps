//
// Convusic
// Copyright 2026 Varun Santhanam
//

import ConvusicKit
import SwiftUI

struct EntityCard: View {

    // MARK: - Initializers

    init(
        entity: ResolvedEntity,
        onDismiss: @escaping () -> Void
    ) {
        self.entity = entity
        self.onDismiss = onDismiss
    }

    // MARK: - View

    var body: some View {
        VStack(spacing: 18) {
            switch entity {
            case let .album(album):
                MusicArtwork(url: album.artwork) {
                    EntityPlaceholder(entity: entity)
                }
                .musicArtworkStyle(.standard)
                MetadataView(
                    label: "ALBUM",
                    title: album.title,
                    subtitle: album.artistNames
                )
            case let .artist(artist):
                MusicArtwork(url: artist.artwork) {
                    EntityPlaceholder(entity: entity)
                }
                .musicArtworkStyle(.circular)
                MetadataView(
                    label: "ARTIST",
                    title: artist.name
                )
            case let .track(track):
                MusicArtwork(url: track.artwork) {
                    EntityPlaceholder(entity: entity)
                }
                .musicArtworkStyle(.standard)
                MetadataView(
                    label: "TRACK",
                    title: track.title,
                    secondary: track.album,
                    subtitle: track.artistNames
                )
            case .unknown:
                UnknownContentView()
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .glassEffect(.regular, in: .rect(cornerRadius: 28))
        .overlay(alignment: .topTrailing) {
            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(.thinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .padding(12)
            .accessibilityLabel("Dismiss")
        }
    }

    // MARK: - Private

    private let entity: ResolvedEntity
    private let onDismiss: () -> Void

}

struct EntityPlaceholder: View {

    let entity: ResolvedEntity

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    .accentColor.opacity(0.65),
                    .accentColor.opacity(0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: symbol(for: entity))
                .font(
                    .system(size: 60, weight: .light)
                )
                .foregroundStyle(.white.opacity(0.9))
        }
    }

    private func symbol(
        for kind: ResolvedEntity
    ) -> String {
        switch kind {
        case .album:
            "square.stack"
        case .artist:
            "person.fill"
        case .track:
            "music.note"
        case .unknown:
            "questionmark.app.fill"
        }
    }

}

#Preview("Track", traits: .sizeThatFitsLayout) {
    EntityCard(
        entity: .track(
            TrackPage(
                title: "Bohemian Rhapsody",
                artists: [Artist(name: "Queen")],
                album: "A Night at the Opera",
                market: "US"
            )
        )
    ) {}
        .padding()
}

#Preview("Album", traits: .sizeThatFitsLayout) {
    EntityCard(
        entity: .album(
            AlbumPage(
                title: "The Dark Side of the Moon",
                artists: [Artist(name: "Pink Floyd")],
                market: "US"
            )
        )
    ) {}
        .padding()
}

#Preview("Artist", traits: .sizeThatFitsLayout) {
    EntityCard(
        entity: .artist(
            ArtistPage(
                name: "Fleetwood Mac",
                market: "US"
            )
        )
    ) {}
        .padding()
}

#Preview("Unknown", traits: .sizeThatFitsLayout) {
    EntityCard(entity: .unknown(type: "podcast")) {}
        .padding()
}
