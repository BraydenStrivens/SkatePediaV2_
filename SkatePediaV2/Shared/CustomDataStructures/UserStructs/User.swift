//
//  User.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable, Hashable {
    let userId: String
    let email: String?
    var username: String
    var usernameLowercase: String
    var stance: UserStance
    var profilePhoto: ProfilePhotoData?
    var bio: String
    var unseenNotificationCount: Int
    let deleted: Bool
    var dateCreated: Date
    
    let settings: UserSettings
    let trickListData: TrickListData
    
    let pendingDeletion: Bool?
    
    var id: String {
        return userId
    }
    
    init(
        userId: String,
        email: String? = "",
        username: String,
        stance: UserStance,
        bio: String = "",
        dateCreated: Date,
        settings: UserSettings,
        trickListData: TrickListData,
        pendingDeletion: Bool? = nil
    ) {
        self.userId = userId
        self.email = email
        self.username = username
        self.usernameLowercase = username.lowercased()
        self.stance = stance
        self.bio = bio
        self.unseenNotificationCount = 0
        self.deleted = false
        self.dateCreated = dateCreated
        self.settings = UserSettings()
        self.trickListData = TrickListData()
        self.pendingDeletion = pendingDeletion
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email = "email"
        case username = "username"
        case usernameLowercase = "username_lowercase"
        case stance = "stance"
        case profilePhoto = "profile_photo_data"
        case bio = "bio"
        case unseenNotificationCount = "unseen_notification_count"
        case deleted = "deleted"
        case dateCreated = "date_created"
        case settings = "settings"
        case trickListData = "trick_list_data"
        case pendingDeletion = "pending_deletion"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.username = try container.decode(String.self, forKey: .username)
        self.usernameLowercase = try container.decode(String.self, forKey: .usernameLowercase)
        self.stance = try container.decode(UserStance.self, forKey: .stance)
        self.profilePhoto = try container.decodeIfPresent(ProfilePhotoData.self, forKey: .profilePhoto)
        self.bio = try container.decode(String.self, forKey: .bio)
        self.unseenNotificationCount = try container.decode(Int.self, forKey: .unseenNotificationCount)
        self.deleted = try container.decode(Bool.self, forKey: .deleted)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.settings = try container.decode(UserSettings.self, forKey: .settings)
        self.trickListData = try container.decode(TrickListData.self, forKey: .trickListData)
        
        self.pendingDeletion = try container.decodeIfPresent(Bool.self, forKey: .pendingDeletion)

    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encode(self.username, forKey: .username)
        try container.encode(self.usernameLowercase, forKey: .usernameLowercase)
        try container.encode(self.stance, forKey: .stance)
        try container.encodeIfPresent(self.profilePhoto, forKey: .profilePhoto)
        try container.encode(self.bio, forKey: .bio)
        try container.encode(self.unseenNotificationCount, forKey: .unseenNotificationCount)
        try container.encode(self.deleted, forKey: .deleted)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.settings, forKey: .settings)
        try container.encode(self.trickListData, forKey: .trickListData)
        try container.encode(self.pendingDeletion, forKey: .pendingDeletion)
    }
}
