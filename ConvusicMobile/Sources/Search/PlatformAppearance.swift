//
// Convusic
// Copyright 2026 Varun Santhanam
//

import ConvusicKit
import SwiftUI

extension Platform {

    /// SF Symbol used to represent the platform in badges and labels.
    var symbol: String {
        switch self {
        case .spotify:
            "music.note"
        case .appleMusic:
            "applelogo"
        case .deezer:
            "waveform.circle.fill"
        case .tidal:
            "water.waves"
        case .youtubeMusic:
            "play.rectangle.fill"
        case .amazonMusic:
            "cart.fill"
        case .unknown:
            "link"
        }
    }

    /// Brand-ish tint used for the platform's icon and badge.
    var tint: Color {
        switch self {
        case .spotify:
            .green
        case .appleMusic:
            .pink
        case .deezer:
            .purple
        case .tidal:
            .cyan
        case .youtubeMusic:
            .red
        case .amazonMusic:
            .orange
        case .unknown:
            .gray
        }
    }
}
