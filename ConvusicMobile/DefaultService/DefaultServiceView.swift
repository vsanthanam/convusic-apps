//
// Convusic
// Copyright 2026 Varun Santhanam
//

import ConvusicKit
import SwiftUI

struct DefaultServiceView: View {

    @CloudPreference(.preferredService)
    private var service: Platform?

    var body: some View {
        Picker("Default Service", selection: $service) {
            Text("Ask Every Time")
                .tag(Platform?.none)
            ForEach(
                [Platform.spotify, .appleMusic, .deezer, .tidal, .youtubeMusic, .amazonMusic],
                id: \.self
            ) { platform in
                Text(platform.displayName)
                    .tag(Platform?.some(platform))
            }
        }
    }

}

#Preview {
    DefaultServiceView()
        .environment(PreferenceCoordinator())
}
