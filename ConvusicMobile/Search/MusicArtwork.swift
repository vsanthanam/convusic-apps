//
// Convusic
// Copyright 2026 Varun Santhanam
//

import SwiftUI

struct MusicArtwork<Placeholder>: View where Placeholder: View {

    let url: URL?

    @ViewBuilder
    let placeholder: Placeholder

    var body: some View {
        ZStack {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case let .success(image):
                        image.resizable().scaledToFill()
                    case .failure:
                        placeholder
                    case .empty:
                        ZStack {
                            placeholder
                            ProgressView().tint(.white)
                        }
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(
            width: 200,
            height: 200
        )
        .clipShape(shape)
        .shadow(
            color: .black.opacity(0.22),
            radius: 22,
            x: 0,
            y: 12
        )
    }

    @Environment(\.musicArtworkStyle)
    var musicArtworkStyle

    private var shape: AnyShape {
        switch musicArtworkStyle {
        case .standard:
            AnyShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        case .circular:
            AnyShape(Circle())
        }
    }

}

extension EnvironmentValues {

    @Entry
    var musicArtworkStyle: MusicArtworkStyle = .standard

}

enum MusicArtworkStyle {
    case standard
    case circular
}

extension View {

    func musicArtworkStyle(
        _ style: MusicArtworkStyle
    ) -> some View {
        environment(\.musicArtworkStyle, style)
    }

}

private struct MusicArtworkPreviewPlaceholder: View {
    let symbol: String
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
            Image(systemName: symbol)
                .font(.system(size: 60, weight: .light))
                .foregroundStyle(.white.opacity(0.9))
        }
    }
}

#Preview("Standard", traits: .sizeThatFitsLayout) {
    MusicArtwork(url: nil) {
        MusicArtworkPreviewPlaceholder(symbol: "music.note")
    }
    .musicArtworkStyle(.standard)
    .padding()
}

#Preview("Circular", traits: .sizeThatFitsLayout) {
    MusicArtwork(url: nil) {
        MusicArtworkPreviewPlaceholder(symbol: "person.fill")
    }
    .musicArtworkStyle(.circular)
    .padding()
}
