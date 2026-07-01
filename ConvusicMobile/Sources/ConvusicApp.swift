//
// Convusic
// Copyright 2026 Varun Santhanam
//

import ConvusicKit
import SwiftUI

@main
struct ConvusicApp: App {

    var body: some Scene {
        WindowGroup {
            RootView { scope in
                SearchView(scope: scope)
            }
            .convusicService(
                apiKey: "d6a8c3c4-e997-4835-9441-f626bc7546b0",
                environment: .staging,
            )
            .environment(router)
            .environment(preferenceCoordinator)
            .onOpenURL { url in
                router.handle(url)
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    // The user may have signed in/out of iCloud while we were
                    // backgrounded (e.g. in Settings.app); re-check so settings
                    // sync (iCloud KVS) stays correct.
                    preferenceCoordinator.refreshCloudAvailability()
                }
            }
        }
    }

    @State
    private var router = Router()

    @State
    private var preferenceCoordinator = PreferenceCoordinator()

    @Environment(\.scenePhase)
    private var scenePhase

}
