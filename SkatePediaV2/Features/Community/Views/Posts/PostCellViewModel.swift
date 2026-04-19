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
    private let postStore: PostStore
    private let errorStore: ErrorStore
    
    init(
        videoUrl: String,
        postService: PostService = .shared,
        postStore: PostStore,
        errorStore: ErrorStore
    ) {
        self.player = AVPlayer(url: URL(string: videoUrl)!)
        self.postService = postService
        self.postStore = postStore
        self.errorStore = errorStore
    }
    
    @MainActor
    func deletePost(_ toDelete: Post) async {
        do {
            try await postService.deletePost(toDelete.id)
            postStore.removePost(toDelete.id)
//            try await useCases.delete(toDelete)
        } catch {
            errorStore.present(error, title: "Error Deleting Post")
        }
    }
}
