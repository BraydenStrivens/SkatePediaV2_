//
//  TrickItemSettingsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/16/25.
//

import SwiftUI

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
