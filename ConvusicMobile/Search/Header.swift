//
// Convusic
// Copyright 2026 Varun Santhanam
//

import SwiftUI

struct Header: View {

    // MARK: - View

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "music.note.list")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(Color.accentColor.gradient)
            Text("Convusic")
                .font(.system(size: 34, weight: .bold, design: .rounded))
            Text("Paste a music link from any service to find it everywhere else.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }

}

#Preview(traits: .sizeThatFitsLayout) {
    Header()
        .padding()
}
