//
// Convusic
// Copyright 2026 Varun Santhanam
//

import SwiftUI

struct MetadataView: View {

    // MARK: - Initializers

    init(
        label: String,
        title: String,
        secondary: String? = nil,
        subtitle: String? = nil
    ) {
        self.label = label
        self.title = title
        self.secondary = secondary
        self.subtitle = subtitle
    }

    // MARK: - View

    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.caption2.bold())
                .tracking(2)
                .foregroundStyle(.tint)
            Text(title)
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
                .lineLimit(3)
            if let secondary {
                Text(secondary)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
    }

    // MARK: - Private

    private let label: String
    private let title: String
    private let secondary: String?
    private let subtitle: String?

}

#Preview("Track", traits: .sizeThatFitsLayout) {
    MetadataView(
        label: "TRACK",
        title: "Bohemian Rhapsody",
        secondary: "A Night at the Opera",
        subtitle: "Queen"
    )
    .padding()
}

#Preview("Album", traits: .sizeThatFitsLayout) {
    MetadataView(
        label: "ALBUM",
        title: "The Dark Side of the Moon",
        subtitle: "Pink Floyd"
    )
    .padding()
}

#Preview("Artist", traits: .sizeThatFitsLayout) {
    MetadataView(
        label: "ARTIST",
        title: "Fleetwood Mac"
    )
    .padding()
}

#Preview("Long Title", traits: .sizeThatFitsLayout) {
    MetadataView(
        label: "TRACK",
        title: "The Show Must Go On (Live at Wembley Stadium, July 1986)",
        secondary: "Innuendo (Remastered 2011)",
        subtitle: "Queen, David Bowie, Annie Lennox"
    )
    .padding()
}
