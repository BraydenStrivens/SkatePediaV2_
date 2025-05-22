//
//  CommunityViewModeo.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/28/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class CommunityViewModel: ObservableObject {
    @Published var userId: String? = nil
    @Published var posts: [Post] = []
    @Published var unseenNotificationsExist: Bool = false
    @Published var isFetching = false
    @Published var newPost: Post? = nil {
        didSet {
            if self.newPost != nil {
                posts.insert(newPost!, at: 0)
                self.newPost = nil
            }
        }
    }
    
    private var lastDocument: DocumentSnapshot? = nil
    private var lastPostIndex: Int = 0
    
    init() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        self.userId = currentUserId
        Task {
            try await fetchNotificationCount(userId: currentUserId)
        }
    }
    
    @MainActor
    func fetchPosts() {
        isFetching = true
        Task {
            let (newPosts, lastDocument) = try await PostManager.shared.getAllPosts(count: 10, filterUserOnly: false, lastDocument: lastDocument)
            
            self.posts.append(contentsOf: newPosts)
            try await fetchDataForPosts()
            
            lastPostIndex += newPosts.count
            if let lastDocument { self.lastDocument = lastDocument }
        }
        isFetching = false
    }
    
    @MainActor
    func fetchDataForPosts() async throws {
        for index in lastPostIndex ..< posts.count {
            let post = posts[index]
            
            posts[index].user = try await UserManager.shared.fetchUser(withUid: post.ownerId)
            posts[index].trick = try await TrickListManager.shared.fetchTricksById(userId: post.ownerId, trickId: post.trickId)
        }
    }

    @MainActor
    func refreshPosts() {
        self.posts.removeAll()
        self.lastDocument = nil
        self.lastPostIndex = 0
        fetchPosts()
    }
    
    @MainActor
    func fetchNotificationCount(userId: String) async throws {
        let notificationCount = try await NotificationManager.shared.getUnseenNotificationCount(userId: userId)
        if notificationCount > 0 { self.unseenNotificationsExist = true }
    }
}
