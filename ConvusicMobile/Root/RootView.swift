//
// Convusic
// Copyright 2026 Varun Santhanam
//

import ConvusicKit
import SwiftUI
import ViewScope

struct RootView<T>: View where T: View {

    // MARK: - Initializers

    init(
        @ViewBuilder content: @escaping @MainActor (Binding<VisibilityScope>) -> T
    ) {
        self.content = content
    }

    // MARK: - View

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            content($scope)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .history:
                        // `.id` forces `@Query` to tear down and re-bind to the new
                        // store's context whenever the container is rebuilt.
                        HistoryView()
                            .id(historyStore.generation)
                    }
                }
        }
        .sheet(item: $router.sheet) { sheet in
            switch sheet {
            case .settings:
                SettingsView()
            }
        }
        .whileVisible($scope)
    }

    // MARK: - Private

    private let content: @MainActor (Binding<VisibilityScope>) -> T

    @ViewScope
    private var scope

    @Environment(Router.self)
    private var router

    @Environment(HistoryStore.self)
    private var historyStore

}

#Preview {
    RootView { _ in
        Text("Hello, Convusic")
            .font(.title2.bold())
    }
    .environment(Router())
    .environment(HistoryStore())
}
