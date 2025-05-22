//
//  FriendsListViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/1/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

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
    
    @MainActor
    func fetchFriendsList() async throws {
        guard friendsList.count % 10 == 0 else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        self.isFetchingFriends = true

        let (newFriends, lastDocument) = try await UserManager.shared.fetchUserFriendsList(userId: currentUid, count: 10, lastDocument: lastFriendsListDocument)
        
        self.currentFriendBatch.append(contentsOf: newFriends)
        if let lastDocument { self.lastFriendsListDocument = lastDocument }
        
        try await fetchDataForFriendsList()
        
        self.currentFriendBatch.removeAll()

        self.isFetchingFriends = false
        self.fetchedFriends = true
    }
    
    @MainActor
    func fetchDataForFriendsList() async throws {
        for index in 0 ..< currentFriendBatch.count {
            let friend = self.currentFriendBatch[index]
            
            self.currentFriendBatch[index].user = try await UserManager.shared.fetchUser(withUid: friend.userId)
            self.friendsList.append(currentFriendBatch[index])
        }
    }
    
    @MainActor
    func fetchPendingFriendsList() async throws {
        guard pendingFriends.count % 10 == 0 else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        self.isFetchingPendingFriends = true
        
        let (newPendingFriends, lastDocument) = try await UserManager.shared.fetchPendingFriends(userId: currentUid, count: 10, lastDocument: lastPendingFriendsDocument)
        
        self.currentPendingFriendBatch = newPendingFriends
        try await fetchDataForPendingFriendsList()
        
        if let lastDocument { self.lastPendingFriendsDocument = lastDocument }
        self.currentPendingFriendBatch.removeAll()
        
        self.isFetchingPendingFriends = false
        self.fetchedPendingFriends = true
    }
    
    @MainActor
    func fetchDataForPendingFriendsList() async throws {
        for index in 0 ..< currentPendingFriendBatch.count {
            let pendingFriend = self.currentPendingFriendBatch[index]
            
            self.currentPendingFriendBatch[index].user = try await UserManager.shared.fetchUser(withUid: pendingFriend.userId)
            self.pendingFriends.append(currentPendingFriendBatch[index])
        }
    }
    
    func acceptFriendRequest(toAddUid: String) async throws {
        try await UserManager.shared.acceptFriendRequest(senderUid: toAddUid)
    }
    
    func removeFriend(toRemoveUid: String) {
        UserManager.shared.removeFriend(toRemoveUid: toRemoveUid)
    }
}
