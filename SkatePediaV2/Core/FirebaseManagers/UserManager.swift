//
//  UserManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Firebase
import FirebaseAuth
import Combine

/// Defines a class that contains functions for fetching and updating data pertaining to a user in the database.
final class UserManager {
    static let shared = UserManager()
    private init() { }
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    private func userFriendsListCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("friends_list")
    }
    private func friendDocument(userId: String, friendId: String) {
        
    }
    
    func fetchUser(withUid uid: String) async throws -> User? {
        do {
            let snapshot = try await userCollection.document(uid).getDocument()
            let user = try snapshot.data(as: User.self)
            return user
        } catch {
            print("Couldnt fetch User: \(error)")
            return nil
        }
    }
    
    func fetchUserByUsername(searchString: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (item: [User], lastDocument: DocumentSnapshot?) {
        let lowercased = searchString.lowercased()
        
        return try await userCollection
            .order(by: User.CodingKeys.usernameLowercase.rawValue)
            .start(at: [lowercased])
            .end(at: [lowercased + "\u{f8ff}"])
            .startOptionally(afterDocument: lastDocument)
            .limit(to: count)
            .getDocumentsWithSnapshot(as: User.self)
    }
    
    func fetchUsersIncludingCurrent() async throws -> [User] {
        let snapshot = try await userCollection.getDocuments()
        return snapshot.documents.compactMap({ try? $0.data(as: User.self) })
    }
    
    func fetchUsers() async throws -> [User] {
        guard let currentUid = Auth.auth().currentUser?.uid else { return [] }
        
        let snapshot = try await userCollection.getDocuments()
        let users = snapshot.documents.compactMap({ try? $0.data(as: User.self) })
        
        return users.filter({ $0.userId != currentUid })
    }
    
    func updateUserBio(newBio: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        try await userCollection.document(currentUid).updateData([
            User.CodingKeys.bio.rawValue : newBio
        ])
    }
    
    func updateUser(updatedUser: User) throws {
        try userCollection.document(updatedUser.userId)
            .setData(from: updatedUser, merge: false)
    }
    
    func updateUserSettings(userId: String, newSettings: UserSettings) async throws {
        try await userDocument(userId: userId)
            .updateData(
                [ User.CodingKeys.settings.rawValue: newSettings.asDictionary() ]
            )
    }
    
    func updateUserProfileImage(userId: String, photoData: ProfilePhotoData) async throws {
        try await userCollection.document(userId)
            .updateData(
                [ User.CodingKeys.profilePhoto.rawValue : photoData.asDictionary() ]
            )
    }
    
    func fetchAllUserFriends(userId: String) async throws -> [Friend] {
        return try await userFriendsListCollection(userId: userId)
            .getDocuments(as: Friend.self)
    }
    
    func fetchUserFriendsList(userId: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (item: [Friend], lastDocument: DocumentSnapshot?) {
        
        return try await userFriendsListCollection(userId: userId)
            .whereField(Friend.CodingKeys.isPending.rawValue, isEqualTo: false)
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Friend.self)
    }
    
    func fetchPendingFriends(userId: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (item: [Friend], lastDocument: DocumentSnapshot?) {
                
        return try await userFriendsListCollection(userId: userId)
            .whereField(Friend.CodingKeys.isPending.rawValue, isEqualTo: true)
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Friend.self)
    }
    
    func addFriendRequest(friend: Friend) async throws {
//        guard let currentUser = currentUser else { return }
//        
//        // Adds a pending friend to the senders friends list
//        try await userFriendsListCollection(userId: currentUser.userId).document(friend.userId)
//            .setData(friend.asDictionary(), merge: false)
//        
//        let currentUserFriendObject = Friend(userId: currentUser.userId, fromUid: currentUser.userId, dateCreated: Date(), isPending: true)
//        
//        // Adds a pending friend to the recievers friends list
//        try await userFriendsListCollection(userId: friend.userId).document(currentUser.userId)
//            .setData(currentUserFriendObject.asDictionary(), merge: false)
//        
//        print("DEBUG: SENT FRIEND REQUEST TO BOTH USERS")
//        
//        
//        print("DEBUG: Friend request notification sent to reciever")
    }
    
    func removeFriend(toRemoveUid: String) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // Deletes the pending or already added friend from the senders friends list
        userFriendsListCollection(userId: currentUid).document(toRemoveUid).delete()
        
        // Deletes the pending or already added friend from the recievers friends list
        userFriendsListCollection(userId: toRemoveUid).document(currentUid).delete()
    }
    
    func acceptFriendRequest(senderUid: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // Updates the friend in the senders friends list to accepted
        try await userFriendsListCollection(userId: currentUid).document(senderUid)
            .updateData(
                [ Friend.CodingKeys.isPending.rawValue : false ]
            )
        
        // Updates the friend in the recievers friends list to accepted
        try await userFriendsListCollection(userId: senderUid).document(currentUid)
            .updateData(
                [ Friend.CodingKeys.isPending.rawValue : false ]
            )
    }
    
    func markUserAsPendingDeletion(userId: String) async throws {
        try await userDocument(userId: userId)
            .updateData(
                [ User.CodingKeys.pendingDeletion.rawValue: true ]
            )
    }
}
