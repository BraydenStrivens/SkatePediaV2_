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

/// Contains data related to the new post being uploaded and a function to upload the post.
///
final class AddPostViewModel: ObservableObject {
    @Published var content: String = ""
    /// Saves the old content if the user selects useTrickItemNotes. Gets reset as the content if the user unselects useTrickItemNotes.
    @Published var oldContent: String = ""
    @Published var useTrickItemNotes: Bool = false
    @Published var showProgress: Bool = true
    @Published var isUploading: Bool = false
    
    private let errorStore: ErrorStore
    private let postStore: PostStore
    private let postService: PostService
    let player: AVPlayer?
    
    init(
        errorStore: ErrorStore,
        postService: PostService = .shared,
        postStore: PostStore,
        videoUrl: String
    ) {
        self.errorStore = errorStore
        self.postService = postService
        self.postStore = postStore
        self.player = AVPlayer(url: URL(string: videoUrl)!)
    }
    
    /// Uploads a new post to the database. Sets the newPost variable on success which is appended to the community view models posts array in the view.
    ///
    /// - Parameters:
    ///  - user: A 'User' object containing information about the current user.
    ///  - trick: A 'Trick' object containing information about the trick for which the trick item is uploaded for.
    ///  - trickItem: A 'TrickItem' object containing information about the trick item the post is based on.
    ///  
    @MainActor
    func uploadPost(user: User, trick: Trick, trickItem: TrickItem) async -> Bool {
        isUploading = true
        defer { isUploading = false }
        
        do {
            let request = UploadPostRequest(
                content: content,
                showTrickItemRating: showProgress,
                user: user,
                trick: trick,
                trickItem: trickItem
            )
            let postId = FirebaseHelpers.generateFirebaseId()
            let newPost = Post(postId: postId, request: request)
            
            try await postService.uploadPost(newPost: newPost)
            postStore.addPost(newPost)
//            try await useCases.upload(request)
            return true
            
        } catch {
            errorStore.present(error, title: "Error Uploading Post")
            return false
        }
    }
}
