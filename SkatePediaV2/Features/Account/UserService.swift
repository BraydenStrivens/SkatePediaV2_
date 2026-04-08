//
//  UserService.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/27/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class UserService {
    static let shared = UserService()
    private init() {}
    
    private var userListener: ListenerRegistration?
    
    private let usersCollection = Firestore.firestore().collection("users")
    private func userRef(_ userId: String) -> DocumentReference {
        usersCollection.document(userId)
    }
    
    private func userFriendsListCollection(for userId: String) -> CollectionReference {
        userRef(userId).collection("friends_list")
    }
    private func friendDocument(userId: String, friendId: String) -> DocumentReference {
        userFriendsListCollection(for: userId).document(friendId)
    }
    
    func listenToUser(
        userId: String,
        onChange: @escaping (Result<User, Error>) -> Void
    ) {
        userListener = userRef(userId).addSnapshotListener({ snapshot, error in
            if let error {
                onChange(.failure(error))
                return
            }
            
            guard let snapshot, snapshot.exists else {
                onChange(.failure(AuthError.userNotFound))
                return
            }
            
            do {
                let user = try snapshot.data(as: User.self)
                onChange(.success(user))
            } catch {
                onChange(.failure(mapToSPError(error: error)))
            }
        })
    }
    
    func removeListener() {
        userListener?.remove()
        userListener = nil
    }
    
    func fetchUserByUsername(
        searchString: String,
        count: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> (item: [User], lastDocument: DocumentSnapshot?) {
        
        let lowercased = searchString.lowercased()
        
        return try await usersCollection
            .order(by: User.CodingKeys.usernameLowercase.rawValue)
            .start(at: [lowercased])
            .end(at: [lowercased + "\u{f8ff}"])
            .startOptionally(afterDocument: lastDocument)
            .limit(to: count)
            .getDocumentsWithSnapshot(as: User.self)
    }
    
    func updateUser(updatedUser: User) throws {
        try userRef(updatedUser.userId)
            .setData(from: updatedUser, merge: false)
    }
    
    func updateUserSettings(
        _ newSettings: UserSettings,
        for userId: String
    ) async throws {
        
        try await userRef(userId)
            .updateData(
                [ User.CodingKeys.settings.rawValue: newSettings.asDictionary() ]
            )
    }
    
    func updateUserUnseenNotificationCount(for userId: String) async throws {
        try await userRef(userId)
            .updateData(
                [ User.CodingKeys.unseenNotificationCount.rawValue: 0 ]
            )
    }
    
    func fetchUserFriendsList(
        for userId: String,
        count: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> (item: [Friend], lastDocument: DocumentSnapshot?) {
        
        return try await userFriendsListCollection(for: userId)
            .whereField(Friend.CodingKeys.isPending.rawValue, isEqualTo: false)
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Friend.self)
    }
    
    func fetchPendingFriends(
        for userId: String,
        count: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> (item: [Friend], lastDocument: DocumentSnapshot?) {
                
        return try await userFriendsListCollection(for: userId)
            .whereField(Friend.CodingKeys.isPending.rawValue, isEqualTo: true)
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Friend.self)
    }
    
    func sendFriendRequest(
        _ currentUser: User,
        to otherUser: User
    ) async throws {
        
        let senderRef = friendDocument(
            userId: currentUser.userId,
            friendId: otherUser.userId
        )
        let receiverRef = friendDocument(
            userId: otherUser.userId,
            friendId: currentUser.userId
        )
        
        let senderDoc = Friend(
            request: AddFriendRequest(
                senderUid: currentUser.userId,
                userId: currentUser.userId,
                withUserData: UserData(user: otherUser)
            )
        )
        let receiverDoc = Friend(
            request: AddFriendRequest(
                senderUid: currentUser.userId,
                userId: otherUser.userId,
                withUserData: UserData(user: currentUser)
            )
        )
        
        let batch = Firestore.firestore().batch()

        try batch.setData(from: senderDoc, forDocument: senderRef)
        try batch.setData(from: receiverDoc, forDocument: receiverRef)
        
        try await batch.commit()
    }
    
    func removeFriend(_ toRemoveUid: String, for userId: String) {
        let batch = Firestore.firestore().batch()
        
        batch.deleteDocument(
            friendDocument(userId: userId, friendId: toRemoveUid)
        )
        batch.deleteDocument(
            friendDocument(userId: toRemoveUid, friendId: userId)
        )
        batch.commit()
    }
    
    func acceptFriendRequest(_ senderUid: String, for userId: String) async throws {
        let batch = Firestore.firestore().batch()

        let receiverRef = friendDocument(userId: userId, friendId: senderUid)
        let senderRef = friendDocument(userId: senderUid, friendId: userId)
        
        batch.updateData(
            [ Friend.CodingKeys.isPending.rawValue : false ],
            forDocument: receiverRef
        )
        batch.updateData(
            [ Friend.CodingKeys.isPending.rawValue : false ],
            forDocument: senderRef
        )
        try await batch.commit()
    }
    
    func markUserAsPendingDeletion(for userId: String) async throws {
        try await userRef(userId)
            .updateData(
                [ User.CodingKeys.pendingDeletion.rawValue: true ]
            )
    }
}
