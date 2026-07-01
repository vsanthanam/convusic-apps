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

}

#Preview {
    RootView { _ in
        Text("Hello, Convusic")
            .font(.title2.bold())
    }
    .environment(Router())
}
