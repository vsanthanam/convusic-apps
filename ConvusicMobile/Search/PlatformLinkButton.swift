//
// Convusic
// Copyright 2026 Varun Santhanam
//

import ConvusicKit
import SwiftUI

struct PlatformLinkButton: View {

    init(
        platformLink: PlatformLink,
        onTap: @escaping @MainActor () -> Void
    ) {
        self.platformLink = platformLink
        self.onTap = onTap
    }

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 14) {
                platformBadge(for: platformLink.platform)
                VStack(alignment: .leading, spacing: 2) {
                    Text(platformLink.platform.displayName)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(URL(string: platformLink.url)?.host() ?? platformLink.url)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
                Image(systemName: "arrow.up.right")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(.thinMaterial, in: Circle())
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 18))
    }

    private let platformLink: PlatformLink
    private let onTap: @MainActor () -> Void

    @ViewBuilder
    private func platformBadge(
        for platform: Platform
    ) -> some View {
        let appearance = platformAppearance(for: platform)
        ZStack {
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(appearance.color.opacity(0.18))
            Image(systemName: appearance.symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(appearance.color)
        }
        .frame(width: 40, height: 40)
    }

    private func platformAppearance(
        for platform: Platform
    ) -> (symbol: String, color: Color) {
        switch platform {
        case .spotify:
            ("music.note", .green)
        case .appleMusic:
            ("applelogo", .pink)
        case .deezer:
            ("waveform.circle.fill", .purple)
        case .tidal:
            ("water.waves", .cyan)
        case .youtubeMusic:
            ("play.rectangle.fill", .red)
        case .amazonMusic:
            ("cart.fill", .orange)
        case .unknown:
            ("link", .gray)
        }
    }
}

#Preview("Spotify", traits: .sizeThatFitsLayout) {
    PlatformLinkButton(
        platformLink: PlatformLink(
            platform: .spotify,
            url: "https://open.spotify.com/track/3z8h0TU7ReDPLIbEnYhWZb",
            id: "3z8h0TU7ReDPLIbEnYhWZb",
            confidence: .isrc
        )
    ) {}
        .padding()
}

#Preview("Apple Music", traits: .sizeThatFitsLayout) {
    PlatformLinkButton(
        platformLink: PlatformLink(
            platform: .appleMusic,
            url: "https://music.apple.com/us/album/1440857781",
            id: "1440857781",
            confidence: .isrc
        )
    ) {}
        .padding()
}

#Preview("Deezer", traits: .sizeThatFitsLayout) {
    PlatformLinkButton(
        platformLink: PlatformLink(
            platform: .deezer,
            url: "https://www.deezer.com/track/3135556",
            id: "3135556",
            confidence: .fuzzyHigh
        )
    ) {}
        .padding()
}

#Preview("Tidal", traits: .sizeThatFitsLayout) {
    PlatformLinkButton(
        platformLink: PlatformLink(
            platform: .tidal,
            url: "https://tidal.com/browse/track/77640617",
            id: "77640617",
            confidence: .isrc
        )
    ) {}
        .padding()
}

#Preview("YouTube Music", traits: .sizeThatFitsLayout) {
    PlatformLinkButton(
        platformLink: PlatformLink(
            platform: .youtubeMusic,
            url: "https://music.youtube.com/watch?v=fJ9rUzIMcZQ",
            id: "fJ9rUzIMcZQ",
            confidence: .fuzzyHigh
        )
    ) {}
        .padding()
}

#Preview("Amazon Music", traits: .sizeThatFitsLayout) {
    PlatformLinkButton(
        platformLink: PlatformLink(
            platform: .amazonMusic,
            url: "https://music.amazon.com/albums/B07XQVZJ7P",
            id: "B07XQVZJ7P",
            confidence: .fuzzyLow
        )
    ) {}
        .padding()
}

#Preview("Unknown", traits: .sizeThatFitsLayout) {
    PlatformLinkButton(
        platformLink: PlatformLink(
            platform: .unknown("bandcamp"),
            url: "https://bandcamp.com/track/example",
            id: "example",
            confidence: .vendor
        )
    ) {}
        .padding()
}
