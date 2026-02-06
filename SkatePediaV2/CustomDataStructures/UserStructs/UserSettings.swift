//
//  Settings.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/20/25.
//

import Foundation

struct TrickListSettingsDTO: Codable {
    let use_trick_abbreviations: Bool?
    let show_learn_first: Bool?
}

struct TrickListSettings: Codable, Identifiable, Hashable {
    let useTrickAbbreviations: Bool
    let showLearnFirst: Bool
    
    var id: String {
        UUID().uuidString
    }
    
    init() {
        self.useTrickAbbreviations = false
        self.showLearnFirst = true
    }
    
    init(dto: TrickListSettingsDTO) throws {
        guard
            let useTrickAbbreviations = dto.use_trick_abbreviations,
            let showLearnFirst = dto.show_learn_first
        else {
            throw SPError.custom("INCOMPLETE TRICK LIST SETTINGS DOC")
        }
        
        self.useTrickAbbreviations = useTrickAbbreviations
        self.showLearnFirst = showLearnFirst
    }
    
    enum CodingKeys: String, CodingKey {
        case useTrickAbbreviations = "use_trick_abbreviations"
        case showLearnFirst = "show_learn_first"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.useTrickAbbreviations = try container.decode(Bool.self, forKey: .useTrickAbbreviations)
        self.showLearnFirst = try container.decode(Bool.self, forKey: .showLearnFirst)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.useTrickAbbreviations, forKey: .useTrickAbbreviations)
        try container.encode(self.showLearnFirst, forKey: .showLearnFirst)
    }
    
    static func ==(lhs: TrickListSettings, rhs: TrickListSettings) -> Bool {
        return (
            lhs.useTrickAbbreviations == rhs.useTrickAbbreviations &&
            lhs.showLearnFirst == rhs.showLearnFirst
        )
    }
}

struct ProfileSettingsDTO: Codable {
    let trick_list_data_is_private: Bool?
    let trick_items_are_private: Bool?
}

struct ProfileSettings: Codable, Identifiable, Hashable {
    let trickListDataIsPrivate: Bool
    let trickItemsArePrivate: Bool
    
    var id: String {
        UUID().uuidString
    }
    
    init() {
        self.trickListDataIsPrivate = false
        self.trickItemsArePrivate = false
    }
    
    init(dto: ProfileSettingsDTO) throws {
        guard
            let trickListDataIsPrivate = dto.trick_list_data_is_private,
            let trickItemsArePrivate = dto.trick_items_are_private
        else {
            throw SPError.custom("PROFILE SETTINGS INCOMPLETE")
        }
        self.trickListDataIsPrivate = trickListDataIsPrivate
        self.trickItemsArePrivate = trickItemsArePrivate
    }
    
    enum CodingKeys: String, CodingKey {
        case trickListDataIsPrivate = "trick_list_data_is_private"
        case trickItemsArePrivate = "trick_items_are_private"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.trickListDataIsPrivate = try container.decode(Bool.self, forKey: .trickListDataIsPrivate)
        self.trickItemsArePrivate = try container.decode(Bool.self, forKey: .trickItemsArePrivate)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.trickListDataIsPrivate, forKey: .trickListDataIsPrivate)
        try container.encode(self.trickItemsArePrivate, forKey: .trickItemsArePrivate)
    }
    
    static func ==(lhs: ProfileSettings, rhs: ProfileSettings) -> Bool {
        return (
            lhs.trickListDataIsPrivate == rhs.trickListDataIsPrivate &&
            lhs.trickItemsArePrivate == rhs.trickItemsArePrivate
        )
    }
}

struct UserSettingsDTO: Codable {
    let trick_list_settings: TrickListSettingsDTO?
    let profile_settings: ProfileSettingsDTO?
}
struct UserSettings: Codable, Identifiable, Hashable {
    let trickSettings: TrickListSettings
    let profileSettings: ProfileSettings
    
    var id: String {
        UUID().uuidString
    }
    
    init() {
        self.trickSettings = TrickListSettings()
        self.profileSettings = ProfileSettings()
    }
    
    init(dto: UserSettingsDTO) throws {
        guard
            let trickSettingsDT0 = dto.trick_list_settings,
            let profileSettingsDTO = dto.profile_settings
        else {
            throw SPError.custom("USER SETTINGS INCOMPLETE")
        }
        self.trickSettings = try TrickListSettings(dto: trickSettingsDT0)
        self.profileSettings = try ProfileSettings(dto: profileSettingsDTO)
    }
    
    enum CodingKeys: String, CodingKey {
        case trickSettings = "trick_list_settings"
        case profileSettings = "profile_settings"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.trickSettings = try container.decode(TrickListSettings.self, forKey: .trickSettings)
        self.profileSettings = try container.decode(ProfileSettings.self, forKey: .profileSettings)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.trickSettings, forKey: .trickSettings)
        try container.encode(self.profileSettings, forKey: .profileSettings)
    }
    
    static func ==(lhs: UserSettings, rhs: UserSettings) -> Bool {
        return (
            lhs.trickSettings == rhs.trickSettings &&
            lhs.profileSettings == rhs.profileSettings
        )
    }
}
