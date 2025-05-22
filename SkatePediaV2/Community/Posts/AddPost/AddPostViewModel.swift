//
//  AddPostViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/13/25.
//

import Foundation
import PhotosUI
import AVKit
import SwiftUI
import Firebase
import FirebaseAuth

final class AddPostViewModel: ObservableObject {
    
    @Published var currentUser: User? = nil
    @Published var selectedTrick: Trick? = nil
    @Published var content: String = ""
    
    @Published var selectedAVideo = false
    @Published var loadState = LoadState.unknown
    @Published var selectedItem: PhotosPickerItem?
    @Published var currentUserId: String? = nil

    var previewVideo: AVPlayer? = nil
    
    enum LoadState {
        case unknown, loading, loaded(PreviewVideo), failed
    }
    
    @MainActor
    init() {
        loadCurrentUser()
    }
    
    @MainActor
    func loadCurrentUser() {
        Task {
            do {
                self.currentUserId = Auth.auth().currentUser?.uid
                self.currentUser = try await UserManager.shared.fetchUser(withUid: currentUserId!)
                
            } catch {
                print("Couldn't get new user: \(error)")
            }
        }
    }
    
    func isValidInput() -> Bool {
        return selectedTrick != nil && !content.isEmpty && selectedItem != nil
    }
    
    func uploadPost() async throws -> Post? {
        guard let item = selectedItem else { return nil }
        guard let videoData = try await item.loadTransferable(type: Data.self) else { return nil }
        
        if let userId = currentUserId, let trick = selectedTrick {
            let postToUpload = Post(
                postId: "",
                ownerId: userId,
                trickId: trick.id,
                content: content,
                commentCount: 0,
                dateCreated: Timestamp(),
//                videoUrl: ""
                videoData: VideoData(videoUrl: "", width: 0, height: 0)
            )
            
            
            var newPost = try await PostManager.shared.uploadPost(post: postToUpload, videoData: videoData)
            newPost.user = currentUser
            newPost.trick = trick
            
            return newPost
        }
        
        return nil
    }
}
