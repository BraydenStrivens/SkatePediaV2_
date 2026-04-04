//
//  ProfileSettingsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/16/25.
//

import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject var errorStore: ErrorStore
    
    @State private var currentProfileSettings: ProfileSettings
    @State private var trickListDataIsPrivate: Bool
    
    var noChanges: Bool {
        trickListDataIsPrivate == currentProfileSettings.trickListDataIsPrivate
    }
    
    let user: User
    
    init(user: User) {
        self.user = user
        _currentProfileSettings = State(initialValue: user.settings.profileSettings)
        _trickListDataIsPrivate = State(initialValue: user.settings.profileSettings.trickListDataIsPrivate)
    }
    
    var body: some View {
        VStack {
            SettingsItemCell(
                id: "trickListDataPrivate",
                header: "Trick List Data is Private",
                description: "Other users can see your trick list progress when viewing your profile.",
                value: $trickListDataIsPrivate
            )
            Spacer()
        }
        .padding(.vertical, 12)
        .settingsInfoOverlay()
        .customNavHeader(
            title: "Profile Settings",
            showDivider: true
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    let newSettings = getUpdatedSetting()
                    Task {
                        do {
                            try await UserManager.shared.updateUserSettings(
                                userId: user.userId,
                                newSettings: newSettings
                            )
                            currentProfileSettings = newSettings.profileSettings
                        } catch {
                            errorStore.present(error, title: "Error Updating Settings")
                        }
                    }
                }
                .tint(Color.button)
                .disabled(noChanges)
            }
        }
    }
    
    func getUpdatedSetting() -> UserSettings {
        var updated = user.settings
        let newProfileSettings = ProfileSettings(
            trickListDataIsPrivate: trickListDataIsPrivate
        )
        updated.profileSettings = newProfileSettings
        return updated
    }
}
