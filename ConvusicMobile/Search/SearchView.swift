//
// Convusic
// Copyright 2026 Varun Santhanam
//

import ConvusicKit
import JBird
import SwiftUI
import ViewScope

struct SearchView: View {

    // MARK: - API

    @Binding
    var scope: VisibilityScope

    // MARK: - View

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                if let response {
                    VStack(spacing: 24) {
                        EntityCard(entity: response.entity) {
                            self.response = nil
                        }
                        if !response.links.isEmpty {
                            VStack(
                                alignment: .leading,
                                spacing: 12
                            ) {
                                Text("Open in")
                                    .font(.headline)
                                    .padding(.leading, 4)
                                VStack(spacing: 10) {
                                    ForEach(response.links) { link in
                                        if let url = link.link {
                                            PlatformLinkButton(platformLink: link) {
                                                openURL(url)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .transition(.scale(scale: 0.94).combined(with: .opacity))
                } else {
                    Header()
                    SearchBar(
                        input: $input,
                        isLoading: $isLoading
                    ) {
                        scope.task {
                            await search(input)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 48)
            .animation(.spring(response: 0.45, dampingFraction: 0.85), value: response)
            .animation(.easeInOut(duration: 0.2), value: isLoading)
        }
        .scrollDismissesKeyboard(.interactively)
        .background {
            SearchBackgroundGradient()
                .ignoresSafeArea()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    router.path.append(.history)
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                }
                .accessibilityLabel("History")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.sheet = .settings
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("Settings")
            }
        }
        .onChange(of: router.pendingResolveURL) { _, target in
            guard let target else { return }
            input = target
            router.pendingResolveURL = nil
            scope.task { await search(target) }
        }
    }

    // MARK: - Private

    @Convusic
    private var convusic

    @Environment(Router.self)
    private var router

    @State
    private var input: String = ""

    @Environment(\.openURL)
    private var openURL

    @State
    private var isLoading = false

    @State
    private var response: ResolveResponse? = nil

    private func search(
        _ string: String
    ) async {
        guard !string.isEmpty else { return }
        isLoading = true
        do {
            response = try await convusic.resolve(string)
            isLoading = false
        } catch {
            isLoading = false
        }
    }
}

#Preview {

    @ViewScope
    var scope

    NavigationStack {
        SearchView(scope: $scope)
    }
    .environment(Router())
}
