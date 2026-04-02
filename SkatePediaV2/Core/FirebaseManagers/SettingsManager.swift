//
//  SettingsManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/27/26.
//

import Foundation

@MainActor
final class SettingsManager: ObservableObject {
    @Published private(set) var profileSettings: ProfileSettings?
    @Published private(set) var trickSettings: TrickListSettings?
    
    func update(from user: User) {
        self.profileSettings = user.settings.profileSettings
        self.trickSettings = user.settings.trickSettings
    }
}
