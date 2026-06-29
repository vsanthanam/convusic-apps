//
// Convusic
// Copyright 2026 Varun Santhanam
//

import SwiftUI

struct SearchBackgroundGradient: View {

    var body: some View {
        LinearGradient(
            colors: [
                Color.accentColor.opacity(0.18),
                Color(.systemBackground),
                Color.accentColor.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

}

#Preview {
    SearchBackgroundGradient()
        .ignoresSafeArea()
}
