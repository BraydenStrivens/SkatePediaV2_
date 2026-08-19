//
//  PostCellViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/25/25.
//

import Foundation
import AVKit

/// Used to intialize a post's video player outside the body of a view. This prevents the video from being updated and flickering every time a @State variable
/// changes.
final class PostCellViewModel: ObservableObject {
    var player: AVPlayer
    
    private let postService: PostService
    private let userService: UserService
    private let postStore: PostStore
    private let errorStore: ErrorStore
    
    @Published var isDeleting: Bool = false
    
    init(
        videoUrl: String,
        postService: PostService = .shared,
        userService: UserService = .shared,
        postStore: PostStore,
        errorStore: ErrorStore
    ) {
        self.player = AVPlayer(url: URL(string: videoUrl)!)
        self.postService = postService
        self.userService = userService
        self.postStore = postStore
        self.errorStore = errorStore
    }
    
    @MainActor
    func deletePost(_ toDelete: Post) async {
        isDeleting = true
        defer { isDeleting = false }
        do {
            try await postService.deletePost(toDelete.id)
            postStore.removePost(toDelete.id)
        } catch {
            errorStore.present(error, title: "Error Deleting Post")
        }
    }
    
    @MainActor
    func fetchUser(_ userId: String) async -> User? {
        do {
            return try await userService.fetchUser(userId: userId)
        } catch {
            errorStore.present(error, title: "Error Fetching User")
            return nil
        }
    }
}
