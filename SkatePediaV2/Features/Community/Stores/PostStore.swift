//
//  PostStore.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/27/26.
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class PostStore: ObservableObject {
    @Published private(set) var posts: [String : Post] = [:]
    private var postIds: Set<String> = []
    
    let postCreated = PassthroughSubject<Post, Never>()
          
    func clear() {
        posts = [:]
        postIds = []
    }
    
    func post(postId: String) -> Post? {
        posts[postId]
    }
    
    func alreadyFetched(for postId: String) -> Bool {
        return postIds.contains(postId)
    }
    
    func onPostUpload(_ newPost: Post) {
        addPost(newPost)
        postCreated.send(newPost)
    }
    
    func addPost(_ newPost: Post) {
        if postIds.insert(newPost.postId).inserted {
            posts[newPost.id] = newPost
        }
    }

    func addPosts(_ currentBatch: [Post]) {
        for post in currentBatch {
            addPost(post)
        }
    }
    
    func updatePostLocally(updatedPost: Post) {
        posts[updatedPost.id] = updatedPost
    }
    
    func updatePostCommentCountLocally(
        postId: String,
        increment: Bool,
        value: Int = 1
    ) {
        guard var toUpdate = posts[postId] else { return }
        
        let incrementValue = increment ? value : -value
        toUpdate.commentCount = toUpdate.commentCount + incrementValue
        posts[postId] = toUpdate
    }
    
    func removePost(_ toRemoveId: String) {
        self.postIds.remove(toRemoveId)
        self.posts.removeValue(forKey: toRemoveId)
    }
}
