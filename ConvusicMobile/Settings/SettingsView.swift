//
// Convusic
// Copyright 2026 Varun Santhanam
//

import ConvusicKit
import SwiftUI

struct SettingsView: View {

    @CloudPreference(.openFromClipboard)
    private var copyFromClipboard

    @CloudEnabled
    private var useCloud

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.settingsPath) {
            List {
                Section("Music Services") {
                    NavigationLink(value: SettingsRoute.defaultService) {
                        Label(
                            "Default Service",
                            systemImage: "app.badge.checkmark"
                        )
                    }
                }
                Section {
                    Toggle(isOn: $copyFromClipboard) {
                        Label(
                            "Copy from Clipboard",
                            systemImage: "clipboard"
                        )
                    }
                    Toggle(isOn: $useCloud) {
                        Label(
                            "Use iCloud",
                            systemImage: "icloud"
                        )
                    }
                    .disabled(!preferences.isCloudAccountAvailable)
                } header: {
                    Text("Options")
                } footer: {
                    if !preferences.isCloudAccountAvailable {
                        Text("Sign in to iCloud to sync your settings across your devices.")
                    }
                }
                Section("Get Help") {
                    NavigationLink(value: SettingsRoute.instructions) {
                        Label(
                            "Instructions",
                            systemImage: "lifepreserver"
                        )
                    }
                    Label(
                        "Email",
                        systemImage: "envelope"
                    )
                    Label(
                        "Website",
                        systemImage: "globe"
                    )
                    Label(
                        "Privacy",
                        systemImage: "shield.lefthalf.filled"
                    )
                }
                Section("Support Convusic") {
                    Text("Tell a Friend")
                    Text("Rate & Review")
                }
                Section("About") {
                    LabeledContent {
                        Text("2.0")
                    } label: {
                        Label("Version", systemImage: "info.circle")
                    }
                    NavigationLink(value: SettingsRoute.acknowledgements) {
                        Label(
                            "Acknowledgements",
                            systemImage: "heart.text.square"
                        )
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                preferences.refreshCloudAvailability()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .navigationDestination(for: SettingsRoute.self) { route in
                switch route {
                case .defaultService:
                    DefaultServiceView()
                case .instructions:
                    InstructionsView()
                case .acknowledgements:
                    AcknowledgementsView()
                }
            }
        }
    }

    @Environment(\.dismiss)
    private var dismiss

    @Environment(Router.self)
    private var router

    @Environment(PreferenceCoordinator.self)
    private var preferences

}

#Preview {
    SettingsView()
        .environment(Router())
        .environment(PreferenceCoordinator())
}
