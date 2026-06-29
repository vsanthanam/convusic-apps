//
// Convusic
// Copyright 2026 Varun Santhanam
//

import SwiftUI

struct HistoryView: View {

    var body: some View {
        ContentUnavailableView(
            "No History Yet",
            systemImage: "clock.arrow.circlepath",
            description: Text("Resolved links will appear here.")
        )
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }

}

#Preview {
    NavigationStack {
        HistoryView()
    }
}
