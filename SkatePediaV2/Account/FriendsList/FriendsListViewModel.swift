//
//  FriendsListViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/1/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

///
/// Class that contains functions for fetching and manipulating the current user's friends list.
///
final class FriendsListViewModel: ObservableObject {
    @Published var friendsList: [Friend] = []
    @Published var pendingFriends: [Friend] = []
    @Published var isFetchingFriends: Bool = false
    @Published var isFetchingPendingFriends: Bool = false
    @Published var fetchedFriends: Bool = false
    @Published var fetchedPendingFriends: Bool = false
    
    private var currentFriendBatch: [Friend] = []
    private var currentPendingFriendBatch: [Friend] = []
    private var lastFriendsListDocument: DocumentSnapshot? = nil
    private var lastPendingFriendsDocument: DocumentSnapshot? = nil
    
    ///
    /// Fetches the user's friends 10 at a time. After fetching each friend, the user data for that friend is fetched.
    ///
    @MainActor
    func fetchFriendsList() async throws {
        // If the fetched friends list's count is not a multiple of 10, there are no more friends to fetch.
        guard friendsList.count % 10 == 0 else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        self.isFetchingFriends = true

        // Fetches 10 friends starting from the last fetched friend and the document of the last fetched friend.
        let (newFriends, lastDocument) = try await UserManager.shared.fetchUserFriendsList(userId: currentUid, count: 10, lastDocument: lastFriendsListDocument)
        
        // Stores the 10 fetched friends in the current batch and stores the last fetched document
        self.currentFriendBatch.append(contentsOf: newFriends)
        if let lastDocument { self.lastFriendsListDocument = lastDocument }
        
        // Fetches user data for each friend.
        try await fetchDataForFriendsList()
        
        // Resets the current batch of 10 friends for future fetching.
        self.currentFriendBatch.removeAll()

        self.isFetchingFriends = false
        self.fetchedFriends = true
    }
    
    ///
    /// Fetches user data for each user in the current batch of fetched friends. After fetching the data, the current batch is appended to the displayed list of friends.
    ///
    @MainActor
    func fetchDataForFriendsList() async throws {
        for index in 0 ..< currentFriendBatch.count {
            let friend = self.currentFriendBatch[index]
            
            self.currentFriendBatch[index].user = try await UserManager.shared.fetchUser(withUid: friend.userId)
            self.friendsList.append(currentFriendBatch[index])
        }
    }
    
    ///
    /// Fetches the user's friends 10 at a time. After fetching each friend, the user data for that friend is fetched.
    ///
    @MainActor
    func fetchPendingFriendsList() async throws {
        // If the fetched pending friends list's count is not a multiple of 10, there are no more friends to fetch.
        guard pendingFriends.count % 10 == 0 else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        self.isFetchingPendingFriends = true
        
        // Fetches 10 friends starting from the last fetched pending friend and the document of the last fetched pending friend.
        let (newPendingFriends, lastDocument) = try await UserManager.shared.fetchPendingFriends(userId: currentUid, count: 10, lastDocument: lastPendingFriendsDocument)
        
        // Stores the 10 fetched pending friends in the current batch and stores the last fetched document
        self.currentPendingFriendBatch = newPendingFriends
        if let lastDocument { self.lastPendingFriendsDocument = lastDocument }

        // Fetches user data for each pending friend.
        try await fetchDataForPendingFriendsList()
        
        // Resets the current batch of 10 pending friends for future fetching.
        self.currentPendingFriendBatch.removeAll()
        
        self.isFetchingPendingFriends = false
        self.fetchedPendingFriends = true
    }
    
    ///
    /// Fetches user data for each user in the current batch of fetched friends. After fetching the data, the current batch is appended to the displayed list of friends.
    ///
    @MainActor
    func fetchDataForPendingFriendsList() async throws {
        for index in 0 ..< currentPendingFriendBatch.count {
            let pendingFriend = self.currentPendingFriendBatch[index]
            
            self.currentPendingFriendBatch[index].user = try await UserManager.shared.fetchUser(withUid: pendingFriend.userId)
            self.pendingFriends.append(currentPendingFriendBatch[index])
        }
    }
    
    ///
    /// Changes the 'pending' field in the friend's document to false indicated the friend request has been accepted.
    ///
    /// - Parameters:
    ///  - toAddUid: The userId of a user who sent the friend request.
    ///
    func acceptFriendRequest(toAddUid: String) async throws {
        try await UserManager.shared.acceptFriendRequest(senderUid: toAddUid)
    }
    
    ///
    /// Removes the friend or pending friend document from the current user's friend list.
    ///
    /// - Parameters:
    ///  - toRemoveUid: The userId of a user on the current user's friend or pending friends list.
    ///
    func removeFriend(toRemoveUid: String) {
        UserManager.shared.removeFriend(toRemoveUid: toRemoveUid)
    }
}
