//
// Convusic
// Copyright 2026 Varun Santhanam
//

import SwiftUI

struct UnknownContentView: View {

    // MARK: - View

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.secondary.opacity(0.15))
            Image(systemName: "questionmark.circle.dashed")
                .font(.system(size: 60, weight: .light))
                .foregroundStyle(.secondary)
        }
        .frame(width: 200, height: 200)
        Text("Unknown Content")
            .font(.title3.bold())
    }

}

#Preview(traits: .sizeThatFitsLayout) {
    VStack(spacing: 18) {
        UnknownContentView()
    }
    .padding()
}
