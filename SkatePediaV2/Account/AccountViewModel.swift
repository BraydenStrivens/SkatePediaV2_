//
//  ProfileViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import PhotosUI
import AVKit

@MainActor
final class AccountViewModel: ObservableObject {
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
    
    func fetchCurrentUser() async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        self.user = try await UserManager.shared.fetchUser(withUid: userId)
        if let bio = self.user?.bio { self.newBio = bio }
    }

    func getTrickListInfo(userId: String? = nil) async throws {
        if let userId = userId {
            self.userTrickListInfo = try await TrickListInfoManager.shared.fetchTrickListInfo(userId: userId)
        } else {
            guard let userId = currentUserId else { return }
            
            self.userTrickListInfo = try await TrickListInfoManager.shared.fetchTrickListInfo(userId: userId)
        }
    }
    
    func fetchPosts(userId: String? = nil) async throws {
        guard let userId = userId else { return }
        
        let (newPosts, lastDocument) = try await PostManager.shared.getAllPostsFromUser(userId: userId, count: 10, lastDocument: lastDocument)
        
        self.userPosts.append(contentsOf: newPosts)
        try await fetchDataForPosts()
        
        lastPostIndex += newPosts.count
        if let lastDocument { self.lastDocument = lastDocument }
        
    }
    
    func fetchDataForPosts() async throws {
        for index in lastPostIndex ..< userPosts.count {
            let post = userPosts[index]
            
            userPosts[index].user = try await UserManager.shared.fetchUser(withUid: post.ownerId)
            userPosts[index].trick = try await TrickListManager.shared.fetchTricksById(userId: post.ownerId, trickId: post.trickId)
        }
    }
    
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
    
    private func loadImage() async {
        guard let item = selectedItem else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        
        self.uiImage = uiImage
        self.profileImage = Image(uiImage: uiImage)
    }
    
    private func updateProfileImage(userId: String) async throws {
        guard let photo = self.uiImage else { return }
        guard let photoUrl = try? await StorageManager.shared.uploadImage(photo, userId: userId) else { return }
        
        try await UserManager.shared.updateUserProfileImage(withPhotoUrl: photoUrl)
    }
    
    func updateBio() async throws {
        try await UserManager.shared.updateUserBio(newBio: newBio)
        self.user?.bio = newBio
    }
}
