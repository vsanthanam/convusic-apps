//
// Convusic
// Copyright 2026 Varun Santhanam
//

import SwiftUI

struct SearchBar: View {

    // MARK: - API

    @Binding
    var input: String

    let isLoading: Bool

    let onSearch: @MainActor () -> Void

    // MARK: - View

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "link")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.secondary)
                TextField(
                    "Paste a song, album, or artist link",
                    text: $input
                )
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.go)
                .onSubmit {
                    onSearch()
                }
                if !input.isEmpty {
                    Button {
                        input = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(
                .horizontal,
                18
            )
            .padding(
                .vertical,
                12
            )
            .glassEffect(
                .regular,
                in: .rect(cornerRadius: 22)
            )
            .animation(
                .easeInOut(duration: 0.18),
                value: input.isEmpty
            )
            if !input.isEmpty {
                Button {
                    onSearch()
                } label: {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "sparkle.magnifyingglass")
                        }
                        Text(isLoading ? "Searching" : "Search")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 30)
                }
                .buttonStyle(.glassProminent)
                .disabled(input.isEmpty || isLoading)
            }
        }
    }

}

#Preview("Empty", traits: .sizeThatFitsLayout) {
    @Previewable @State var input = ""
    SearchBar(input: $input, isLoading: false) {}
        .padding()
}

#Preview("Filled", traits: .sizeThatFitsLayout) {
    @Previewable @State var input = "https://open.spotify.com/track/123"
    @Previewable @State var isLoading = false
    SearchBar(input: $input, isLoading: false) {}
        .padding()
}

#Preview("Loading", traits: .sizeThatFitsLayout) {
    @Previewable @State var input = "https://open.spotify.com/track/123"
    SearchBar(input: $input, isLoading: true) {}
        .padding()
}
