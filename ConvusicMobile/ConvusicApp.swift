//
// Convusic
// Copyright 2026 Varun Santhanam
//

import ConvusicKit
import SwiftData
import SwiftUI
import UIKit

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
            .environment(historyStore)
            .modelContainer(historyStore.container)
            .onOpenURL { url in
                router.handle(url)
            }
            .task {
                historyStore.reconfigure(
                    cloudEnabled: preferenceCoordinator.isCloudEnabled,
                    accountAvailable: preferenceCoordinator.isCloudAccountAvailable
                )
                UIApplication.shared.registerForRemoteNotifications()
            }
            .onChange(of: preferenceCoordinator.isCloudEnabled) { _, enabled in
                historyStore.reconfigure(
                    cloudEnabled: enabled,
                    accountAvailable: preferenceCoordinator.isCloudAccountAvailable
                )
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    // The user may have signed in/out of iCloud while we were
                    // backgrounded (e.g. in Settings.app); re-check, then graduate
                    // or downgrade the history container to match, and run a dedup
                    // backstop in case a remote-change push was missed.
                    preferenceCoordinator.refreshCloudAvailability()
                    historyStore.reconfigure(
                        cloudEnabled: preferenceCoordinator.isCloudEnabled,
                        accountAvailable: preferenceCoordinator.isCloudAccountAvailable
                    )
                    historyStore.deduplicate()
                }
            }
        }
    }

    @State
    private var router = Router()

    @State
    private var preferenceCoordinator = PreferenceCoordinator()

    @State
    private var historyStore = HistoryStore()

    @Environment(\.scenePhase)
    private var scenePhase

}
