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
    private var hasMoreFriends: Bool = true
    @Published var isFetchingPendingFriends: Bool = false
    private var hasMorePendingFriends: Bool = true

    private var lastFriendsListDocument: DocumentSnapshot? = nil
    private var lastPendingFriendsDocument: DocumentSnapshot? = nil
    
    private let batchSize: Int = 15
    
    private let errorStore: ErrorStore
    private let useCases: UserUseCases
    
    init(
        errorStore: ErrorStore,
        useCases: UserUseCases
    ) {
        self.errorStore = errorStore
        self.useCases = useCases
    }
    
    ///
    /// Fetches the user's friends 10 at a time. After fetching each friend, the user data for that friend is fetched.
    ///
    @MainActor
    func fetchFriendsList(for userId: String) async {
        guard hasMoreFriends else { return }
        
        isFetchingFriends = true
        defer { isFetchingFriends = false }
        
        do {
            print("FETCHING FRIENDS")

            let (currentBatch, lastDocument) = try await useCases.fetchUserFriendsList(
                userId: userId,
                count: batchSize,
                lastDocument: lastFriendsListDocument
            )
            
            friendsList.append(contentsOf: currentBatch)
            if let lastDocument { lastFriendsListDocument = lastDocument }
            hasMoreFriends = currentBatch.count == batchSize
            
        } catch {
            errorStore.present(error, title: "Error Fetching Friends.")
        }
    }
    
    ///
    /// Fetches the user's friends 10 at a time. After fetching each friend, the user data for that friend is fetched.
    ///
    @MainActor
    func fetchPendingFriendsList(for userId: String) async {
        guard hasMorePendingFriends else { return }
        
        isFetchingPendingFriends = true
        defer { isFetchingPendingFriends = false }
        
        do {
            let (currentBatch, lastDocument) = try await useCases.fetchPendingFriends(
                userId: userId,
                count: batchSize,
                lastDocument: lastPendingFriendsDocument
            )
            
            pendingFriends.append(contentsOf: currentBatch)
            if let lastDocument { lastPendingFriendsDocument = lastDocument }
            hasMorePendingFriends = currentBatch.count == batchSize
            
        } catch {
            errorStore.present(error, title: "Error Fetching Pending Friends.")
        }
    }
    
    @MainActor
    func handleFriend(
        _ friend: Friend,
        accept: Bool
    ) async {
        do {
            try await useCases.handleFriendRequest(
                senderUid: friend.withUserData.userId,
                for: friend.userId,
                accept: accept
            )
            
            // Optimistic updates
            if accept {
                pendingFriends.removeAll(where: { $0.id == friend.id })
                friendsList.append(friend)
                
            } else {
                pendingFriends.removeAll(where: { $0.id == friend.id })
                friendsList.removeAll(where: { $0.id == friend.id })
            }
            
        } catch {
            errorStore.present(error, title: "Error Handling Friend Request")
        }
    }
}
