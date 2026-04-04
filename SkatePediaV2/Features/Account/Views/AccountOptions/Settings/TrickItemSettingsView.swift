//
//  TrickItemSettingsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/16/25.
//

import SwiftUI

/// View that allows the user to configure their trick list settings.
///
/// Users can:
/// - Toggle whether "Learn First" tricks are displayed at the top of trick views.
/// - Toggle whether trick names are displayed in abbreviated form.
///
/// Settings changes are saved to the user's profile using `UserManager`.
///
/// Toolbar:
/// - A "Save" button appears in the toolbar and is enabled only if there are changes.
///
/// - Parameters:
///   - user: The current user whose trick settings are being modified.
struct TrickItemSettingsView: View {
    @EnvironmentObject var errorStore: ErrorStore

    @State private var currentTrickSettings: TrickListSettings
    @State private var showLearnFirst: Bool
    @State private var useTrickAbbreviations: Bool
    
    let user: User
    
    init(user: User) {
        self.user = user
        _currentTrickSettings = State(initialValue: user.settings.trickSettings)
        _showLearnFirst = State(initialValue: user.settings.trickSettings.showLearnFirst)
        _useTrickAbbreviations = State(initialValue: user.settings.trickSettings.useTrickAbbreviations)
    }
    
    /// Returns true if no changes have been made to the settings.
    var noChanges: Bool {
        showLearnFirst == currentTrickSettings.showLearnFirst &&
        useTrickAbbreviations == currentTrickSettings.useTrickAbbreviations
    }
    
    var body: some View {
        VStack {
            SettingsItemCell(
                id: "learnFirst",
                header: "Show Learn First",
                description: "Display the tricks that should be learned first at the top of each trick view.",
                value: $showLearnFirst
            )
            
            Divider()
            
            SettingsItemCell(
                id: "abbreviations",
                header: "Use Trick Abbreviations",
                description: "Displays trick names in abbreviated form (Backside 360 Shuvit -> BS 3 Shuv)",
                value: $useTrickAbbreviations
            )
            
            Spacer()
        }
        .padding(.vertical, 12)
        .customNavHeader(
            title: "Trick Settings",
            showDivider: true
        )
        .settingsInfoOverlay()
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
                            currentTrickSettings = newSettings.trickSettings
                        } catch {
                            errorStore.present(error, title: "Error Saving Settings")
                        }
                    }
                }
                .tint(Color.button)
                .disabled(noChanges)
            }
        }
    }
    
    /// Constructs a `UserSettings` object with the updated trick settings.
    func getUpdatedSetting() -> UserSettings {
        var updated = user.settings
        let newTrickListSettings = TrickListSettings(
            useTrickAbbreviations: useTrickAbbreviations,
            showLearnFirst: showLearnFirst
        )
        updated.trickSettings = newTrickListSettings
        return updated
    }
}
