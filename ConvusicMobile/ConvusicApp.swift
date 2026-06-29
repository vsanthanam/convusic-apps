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
            .onOpenURL { url in
                router.handle(url)
            }
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                if let url = activity.webpageURL {
                    router.handle(url)
                }
            }
        }
    }

    @State
    private var router = Router()

}
