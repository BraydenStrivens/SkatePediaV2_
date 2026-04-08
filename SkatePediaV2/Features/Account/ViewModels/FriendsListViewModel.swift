//
//  FriendsListViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/1/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

/// Manages fetching and handling the current user's friends and pending friend requests.
///
/// This class is responsible for loading paginated friends data,
/// handling incoming friend requests, and updating the UI state accordingly.
/// It interacts with `UserService` for network operations and uses
/// `ErrorStore` to present any errors to the user.
final class FriendsListViewModel: ObservableObject {
    @Published var friendsList: [Friend] = []
    @Published var pendingFriends: [Friend] = []
    
    @Published var isFetchingFriends: Bool = false
    private var hasMoreFriends: Bool = true
    private var lastFriendsListDocument: DocumentSnapshot? = nil

    @Published var isFetchingPendingFriends: Bool = false
    private var hasMorePendingFriends: Bool = true
    private var lastPendingFriendsDocument: DocumentSnapshot? = nil
    
    private let batchSize: Int = 15
    
    private let errorStore: ErrorStore
    private let userService: UserService
    
    /// Creates a new `FriendsListViewModel`.
    ///
    /// - Parameters:
    ///   - errorStore: The shared error store used for error handling.
    ///   - userService: The service used for fetching and updating user data. Defaults to `.shared`.
    init(
        errorStore: ErrorStore,
        userService: UserService = .shared
    ) {
        self.errorStore = errorStore
        self.userService = userService
    }
    
    /// Fetches a paginated batch of the user's friends list.
    ///
    /// This method retrieves friends in batches and appends them to the existing list.
    /// Pagination is handled using the last fetched document snapshot.
    ///
    /// - Parameter userId: The unique identifier of the user whose friends are being fetched.
    @MainActor
    func fetchFriendsList(for userId: String) async {
        guard hasMoreFriends else { return }
        
        isFetchingFriends = true
        defer { isFetchingFriends = false }
        
        do {
            print("FETCHING FRIENDS")

            let (currentBatch, lastDocument) = try await userService.fetchUserFriendsList(
                for: userId,
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
    
    /// Fetches a paginated batch of the user's pending friend requests.
    ///
    /// This method retrieves pending friends in batches and appends them to the existing list.
    /// Pagination is handled using the last fetched document snapshot.
    ///
    /// - Parameter userId: The unique identifier of the user whose pending requests are being fetched.
    @MainActor
    func fetchPendingFriendsList(for userId: String) async {
        guard hasMorePendingFriends else { return }
        
        isFetchingPendingFriends = true
        defer { isFetchingPendingFriends = false }
        
        do {
            let (currentBatch, lastDocument) = try await userService.fetchPendingFriends(
                for: userId,
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
    
    /// Handles accepting or rejecting a friend request. Also used to remove an already accepted friend.
    ///
    /// If accepted, the friend is moved from the pending list to the friends list.
    /// If rejected, the friend is removed from both lists.
    ///
    /// - Parameters:
    ///   - friend: The friend request to handle.
    ///   - accept: A Boolean indicating whether to accept (`true`) or reject (`false`) the request.
    @MainActor
    func handleFriend(
        _ friend: Friend,
        accept: Bool
    ) async {
        do {
            if accept {
                try await userService.acceptFriendRequest(
                    friend.userId,
                    for: friend.withUserData.userId
                )
                
                pendingFriends.removeAll(where: { $0.id == friend.id })
                friendsList.append(friend)
                
            } else {
                userService.removeFriend(
                    friend.userId,
                    for: friend.withUserData.userId
                )
                
                pendingFriends.removeAll(where: { $0.id == friend.id })
                friendsList.removeAll(where: { $0.id == friend.id })
            }
            
        } catch {
            errorStore.present(error, title: "Error Handling Friend Request")
        }
    }
}
