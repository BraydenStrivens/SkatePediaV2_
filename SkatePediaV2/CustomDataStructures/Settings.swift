//
//  Settings.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/20/25.
//

import Foundation

struct Settings: Encodable {
    // Trick settings
    let useTrickAbbreviations: Bool
    let showLearnFirst: Bool
    
    // Profile settings
    let profileIsPrivate: Bool
        
    init(useTrickAbbreviation: Bool, showLearnFirst: Bool, profileIsPrivate: Bool) {
        self.useTrickAbbreviations = useTrickAbbreviation
        self.showLearnFirst = showLearnFirst
        self.profileIsPrivate = profileIsPrivate
    }
    
    /// Defines naming conventions for the post document's fields in the database.
    enum CodingKeys: String, CodingKey {
        case useTrickAbbreviations = "use_trick_abbreviations"
        case showLearnFirst = "show_learn_first"
        case profileIsPrivate = "profile_is_private"
    }
    
    /// Defines a decoder to decode a 'post' document into a 'Post' object.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.useTrickAbbreviations = try container.decode(Bool.self, forKey: .useTrickAbbreviations)
        self.showLearnFirst = try container.decode(Bool.self, forKey: .showLearnFirst)
        self.profileIsPrivate = try container.decode(Bool.self, forKey: .profileIsPrivate)
    }
    
    /// Defines an encoder to encode a 'Post' object into a 'post' document.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.useTrickAbbreviations, forKey: .useTrickAbbreviations)
        try container.encode(self.showLearnFirst, forKey: .showLearnFirst)
        try container.encode(self.profileIsPrivate, forKey: .profileIsPrivate)
    }
}
