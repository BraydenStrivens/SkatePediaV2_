//
//  Settings.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/20/25.
//

import Foundation

struct TrickListSettings: Codable, Identifiable, Hashable {
    var useTrickAbbreviations: Bool
    var showLearnFirst: Bool
    
    var id: String {
        UUID().uuidString
    }
    
    init(
        useTrickAbbreviations: Bool = false,
        showLearnFirst: Bool = true
    ) {
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

struct ProfileSettings: Codable, Identifiable, Hashable {
    var trickListDataIsPrivate: Bool
    var trickItemsArePrivate: Bool
    
    var id: String {
        UUID().uuidString
    }
    
    init(
        trickListDataIsPrivate: Bool = false,
        trickItemsArePrivate: Bool = false
    ) {
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

struct UserSettings: Codable, Identifiable, Hashable {
    var trickSettings: TrickListSettings
    var profileSettings: ProfileSettings
    
    var id: String {
        UUID().uuidString
    }
    
    init(
        trickSettings: TrickListSettings = TrickListSettings(),
        profileSettings: ProfileSettings = ProfileSettings()
    ) {
        self.trickSettings = trickSettings
        self.profileSettings = profileSettings
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
