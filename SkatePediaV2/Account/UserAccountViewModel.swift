//
//  ProfileViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Firebase
import SwiftUI
import PhotosUI
import AVKit

///
/// Class that contains functions for fetching user data and interacting with other users.
///
@MainActor
final class UserAccountViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var userTrickListInfo: TrickListInfo? = nil
    @Published var userPosts: [Post] = []
    @Published var newBio: String = ""
    @Published var profileImage: Image?
    @Published var selectedItem: PhotosPickerItem? {
        didSet { Task { await loadImage() } }
    }
    
    private var lastDocument: DocumentSnapshot? = nil
    private var lastPostIndex: Int = 0
    private var uiImage: UIImage?
    private let currentUserId = Auth.auth().currentUser?.uid
    
    @Published var getUserFetchState: RequestState = .idle
    @Published var getTrickInfoFetchState: RequestState = .idle
    @Published var getUserPostsFetchState: RequestState = .idle
    @Published var updateProfileState: RequestState = .idle
    
    init(user: User?) {
        if let user = user {
            self.user = user
            getUserFetchState = .success
        } else {
            Task {
                await fetchCurrentUser()
            }
        }
    }
    
    ///
    /// Fetches the current user from the database as a User object.
    ///
    func fetchCurrentUser() async {
        do {
            getUserFetchState = .loading
            
            guard let userId = Auth.auth().currentUser?.uid else { throw FirestoreError.unknown }
            self.user = try await UserManager.shared.fetchUser(withUid: userId)
            if let bio = self.user?.bio { self.newBio = bio }
            
            getUserFetchState = .success
            
        } catch let error as FirestoreError {
            getUserFetchState = .failure(.firestore(error))
            
        } catch {
            getUserFetchState = .failure(.unknown)
        }
    }

    ///
    /// Fetches the trick list info for the current user by default, or the user corresponding to the passed userId.
    ///
    /// - Parameters:
    ///  - userId: An optional string representing the Id of a user.
    ///
    func getTrickListInfo(userId: String) async {
        do {
            getTrickInfoFetchState = .loading
            self.userTrickListInfo = try await TrickListInfoManager.shared.fetchTrickListInfo(userId: userId)
            getTrickInfoFetchState = .success
            
        } catch let error as FirestoreError {
            getTrickInfoFetchState = .failure(.firestore(error))
            
        } catch {
            getTrickInfoFetchState = .failure(.unknown)
        }
    }
    
    ///
    /// Fetches the posts belonging to the current user by default, or the user corresponding to the passed userId. The posts are fetched 10 at a time
    /// and starting from the last fetched document.
    ///
    /// - Parameters:
    ///  - userId: An optional string representing the Id of a user.
    ///
    func fetchPosts(userId: String) async throws {
        // If the number of fetched posts is not divisible by 10, then there are no more posts left to be fetched.
        guard self.userPosts.count % 10 == 0 else { return }

        do {
            getUserPostsFetchState = .loading
            
            // Fetches 10 posts starting from the last fetched document and stores the last fetched document.
            let (newPosts, lastDocument) = try await PostManager.shared.getAllPostsFromUser(userId: userId, count: 10, lastDocument: lastDocument)
            
            self.userPosts.append(contentsOf: newPosts)
            
            lastPostIndex += newPosts.count
            if let lastDocument { self.lastDocument = lastDocument }
            
            getUserPostsFetchState = .success
            
        } catch let error as FirestoreError {
            getUserPostsFetchState = .failure(.firestore(error))
            
        } catch {
            getUserPostsFetchState = .failure(.unknown)
        }
        
    }
    
    ///
    /// Sends a friend request to a specified user.
    ///
    /// - Parameters:
    ///  - toAddUserId: The userId of the user to send a friend request to.
    ///
    func sendFriendRequest(toAddUserId: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let newFriend = Friend(userId: toAddUserId, fromUid: currentUid, dateCreated: Timestamp(), isPending: true)
        
        try await UserManager.shared.addFriendRequest(friend: newFriend)
    }
    
    func updateUserProfile() async throws {
        guard let userId = currentUserId else { return }
        try await updateProfileImage(userId: userId)
        try await updateBio()
    }
    
    ///
    /// Converts a selected item from a PhotoPicker to a UI Image and Image. 
    ///
    private func loadImage() async {
        guard let item = selectedItem else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        
        self.uiImage = uiImage
        self.profileImage = Image(uiImage: uiImage)
    }
    
    ///
    /// Updates the user's profile with the selected UI Image from the users camera roll. Uploads the new photo to storage and replaces the old photo if it exists.
    ///
    private func updateProfileImage(userId: String) async throws {
        guard let photo = self.uiImage else { return }
        guard let photoUrl = try? await StorageManager.shared.uploadImage(photo, userId: userId) else { return }
        
        try await UserManager.shared.updateUserProfileImage(withPhotoUrl: photoUrl)
    }
    
    ///
    /// Updates the user's bio with the input contained in a text field.
    ///
    func updateBio() async throws {
        try await UserManager.shared.updateUserBio(newBio: newBio)
        self.user?.bio = newBio
    }
}
