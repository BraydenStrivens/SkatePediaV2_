//
//  UserUseCases.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/26.
//

import Foundation
import FirebaseFirestore

struct AddFriendRequest {
    let senderUid: String
    let userId: String
    let withUserData: UserData
}

@MainActor
final class UserUseCases {
    private let userStore: UserStore
    private let service = UserService.shared
    
    init(
        userStore: UserStore
    ) {
        self.userStore = userStore
    }
    
    func fetchUserByUsername(
        searchString: String,
        count: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> (item: [User], lastDocument: DocumentSnapshot?) {
        
        let lowercased = searchString.lowercased()
        
        return try await service.fetchUserByUsername(
            searchString: lowercased,
            count: count,
            lastDocument: lastDocument
        )
    }
    
    func updateUser(updatedUser: User) throws {
        try service.updateUser(updatedUser: updatedUser)
    }
    
    func updateUserSettings(userId: String, newSettings: UserSettings) async throws {
        try await service.updateUserSettings(newSettings, for: userId)
    }
    
    func updateUserUnseenNotificationCount(userId: String) async throws {
        try await service.updateUserUnseenNotificationCount(for: userId)
        userStore.resetUnseenNotificationCount()
    }
    
    func sendFriendRequest(_ currentUser: User, to otherUser: User) async throws  {
        try await service.sendFriendRequest(currentUser, to: otherUser)
    }
    
    func fetchUserFriendsList(
        userId: String,
        count: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> (item: [Friend], lastDocument: DocumentSnapshot?) {
        
        return try await service.fetchUserFriendsList(
            for: userId,
            count: count,
            lastDocument: lastDocument
        )
    }
    
    func fetchPendingFriends(
        userId: String,
        count: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> (item: [Friend], lastDocument: DocumentSnapshot?) {
                
        return try await service.fetchPendingFriends(
            for: userId,
            count: count,
            lastDocument: lastDocument
        )
    }
    
    func handleFriendRequest(
        senderUid: String,
        for userId: String,
        accept: Bool
    ) async throws {
        
        if accept {
            try await service.acceptFriendRequest(senderUid, for: userId)
        } else {
            service.removeFriend(senderUid, for: userId)
        }
    }
    
    func markUserAsPendingDeletion(userId: String) async throws {
        try await service.markUserAsPendingDeletion(for: userId)
    }
    
    func resetUserUnseenNotificationCount(userId: String) async throws {
        try await service.updateUserUnseenNotificationCount(for: userId)
        userStore.resetUnseenNotificationCount()
    }
}
