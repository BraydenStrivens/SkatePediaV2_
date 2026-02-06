//
//  User.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import Foundation
import FirebaseFirestore

struct UserDTO: Codable {
    let user_id: String?
    let email: String?
    var username: String?
    let username_lowercase: String?
    let stance: UserStance?
    var profile_pic_url: String?
    var bio: String?
    let unseen_notification_count: Int?
    let deleted: Bool?
    @ServerTimestamp var date_created: Date?
    
    let settings: UserSettingsDTO?
    let trick_list_data: TrickListDataDTO?
}

struct User: Codable, Identifiable, Hashable {
    let userId: String
    let email: String?
    var username: String
    let usernameLowercase: String
    let stance: UserStance
    var photoUrl: String
    var bio: String
    let unseenNotificationCount: Int
    let deleted: Bool
    var dateCreated: Date
    
    let settings: UserSettings
    let trickListData: TrickListData
    
    var id: String {
        return userId
    }
    
    init(
        userId: String,
        email: String? = "",
        username: String,
        stance: UserStance,
        photoUrl: String = "",
        bio: String = "",
        dateCreated: Date,
        settings: UserSettings,
        trickListData: TrickListData
    ) {
        self.userId = userId
        self.email = email
        self.username = username
        self.usernameLowercase = username.lowercased()
        self.stance = stance
        self.photoUrl = photoUrl
        self.bio = bio
        self.unseenNotificationCount = 0
        self.deleted = false
        self.dateCreated = dateCreated
        self.settings = UserSettings()
        self.trickListData = TrickListData()
    }
    
    init(dto: UserDTO) throws {
        guard
            let userId = dto.user_id,
            let username = dto.username,
            let usernameLowercase = dto.username_lowercase,
            let stance = dto.stance,
            let photoUrl = dto.profile_pic_url,
            let bio = dto.bio,
            let unseenNotificationCount = dto.unseen_notification_count,
            let deleted = dto.deleted,
            let dateCreated = dto.date_created,
            let settingsDTO = dto.settings,
            let trickListDataDTO = dto.trick_list_data
        else {
            throw SPError.custom("USER DOC IS INCOMPLETE")
        }
        
        self.userId = userId
        self.username = username
        self.usernameLowercase = usernameLowercase
        self.email = dto.email ?? nil
        self.stance = stance
        self.photoUrl = photoUrl
        self.bio = bio
        self.unseenNotificationCount = unseenNotificationCount
        self.deleted = deleted
        self.dateCreated = dateCreated
        self.settings = try UserSettings(dto: settingsDTO)
        self.trickListData = try TrickListData(dto: trickListDataDTO)
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email = "email"
        case username = "username"
        case usernameLowercase = "username_lowercase"
        case stance = "stance"
        case photoUrl = "profile_pic_url"
        case bio = "bio"
        case unseenNotificationCount = "unseen_notification_count"
        case deleted = "deleted"
        case dateCreated = "date_created"
        case settings = "settings"
        case trickListData = "trick_list_data"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.username = try container.decode(String.self, forKey: .username)
        self.usernameLowercase = try container.decode(String.self, forKey: .usernameLowercase)
        self.stance = try container.decode(UserStance.self, forKey: .stance)
        self.photoUrl = try container.decode(String.self, forKey: .photoUrl)
        self.bio = try container.decode(String.self, forKey: .bio)
        self.unseenNotificationCount = try container.decode(Int.self, forKey: .unseenNotificationCount)
        self.deleted = try container.decode(Bool.self, forKey: .deleted)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.settings = try container.decode(UserSettings.self, forKey: .settings)
        self.trickListData = try container.decode(TrickListData.self, forKey: .trickListData)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encode(self.username, forKey: .username)
        try container.encode(self.usernameLowercase, forKey: .usernameLowercase)
        try container.encode(self.stance, forKey: .stance)
        try container.encode(self.photoUrl, forKey: .photoUrl)
        try container.encode(self.bio, forKey: .bio)
        try container.encode(self.unseenNotificationCount, forKey: .unseenNotificationCount)
        try container.encode(self.deleted, forKey: .deleted)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.settings, forKey: .settings)
        try container.encode(self.trickListData, forKey: .trickListData)
    }
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}
