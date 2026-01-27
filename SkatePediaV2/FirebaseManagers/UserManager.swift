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
    
    @Published var currentUser: User?
    
    static let shared = UserManager()
    
    init() {
        Task { try await fetchCurrentUser() }
    }
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    private func userFriendsListCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("friends_list")
    }
    
    @MainActor
    func fetchCurrentUser() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            let user = try await userCollection.document(uid)
                .getDocument(as: User.self)
            
            self.currentUser = user

        } catch {
            print("DEBUG: COULDNT FETCH USER: \(error)")
        }
    }
    
    func reset() {
        self.currentUser = nil
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
    
    func fetchUserByUsername(searchString: String, includeCurrentUser: Bool) async throws -> [User] {
        var allUsers: [User] = []
        
        if includeCurrentUser {
            allUsers = try await fetchUsersIncludingCurrent()
        } else {
            allUsers = try await fetchUsers()
        }
        var matchedUsers: [User] = []
        
        for user in allUsers {
            print("User: \(user.username)")
            var matched = true
            
            for index in 0 ..< searchString.count {
                let searchChar = String(describing: searchString[index])
                let usernameChar = String(describing: user.username[index])
                
                if searchChar.caseInsensitiveCompare(usernameChar) != .orderedSame {
                    matched = false
                    break
                }
            }
            
            if matched {
                matchedUsers.append(user)
            }
        }
        
        return matchedUsers
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
    
    @MainActor
    func uploadUserData(id: String, withEmail email: String, username: String, stance: String) async throws {
        let user = User(
            userId: id,
            email: email,
            username: username,
            stance: stance,
            dateCreated: Date()
        )
        
        guard let userData = try? Firestore.Encoder().encode(user) else { return }
        
        // Creates a new user document and uploads the users data to it
        try await Firestore.firestore().collection("users").document(id).setData(userData)
        
        // Sets the current logged in user
        UserManager.shared.currentUser = user
    }
    
    func updateUserBio(newBio: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        try await userCollection.document(currentUid).updateData([
            User.CodingKeys.bio.rawValue : newBio
        ])
        
        self.currentUser?.bio = newBio
    }
    
    @MainActor
    func updateUserProfileImage(withPhotoUrl photoUrl: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        try await userCollection.document(currentUid).updateData([
            User.CodingKeys.photoUrl.rawValue : photoUrl
        ])
        
        self.currentUser?.photoUrl = photoUrl
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
        guard let currentUser = currentUser else { return }
        
        // Adds a pending friend to the senders friends list
        try await userFriendsListCollection(userId: currentUser.userId).document(friend.userId)
            .setData(friend.asDictionary(), merge: false)
        
        let currentUserFriendObject = Friend(userId: currentUser.userId, fromUid: currentUser.userId, dateCreated: Timestamp(), isPending: true)
        
        // Adds a pending friend to the recievers friends list
        try await userFriendsListCollection(userId: friend.userId).document(currentUser.userId)
            .setData(currentUserFriendObject.asDictionary(), merge: false)
        
        print("DEBUG: SENT FRIEND REQUEST TO BOTH USERS")
        
        // Sends notification to the reciever
        let notification = Notification(
            id: "",
            fromUserId: currentUser.userId,
            toUserId: friend.userId,
            notificationType: .friendRequest,
            dateCreated: Timestamp(),
            seen: false
        )
        
        try await NotificationManager.shared.sendNotification(notification: notification)
        
        print("DEBUG: Friend request notification sent to reciever")
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
}
