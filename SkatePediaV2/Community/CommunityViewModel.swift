//
//  CommunityViewModeo.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/28/25.
//

import SwiftUI
import Foundation
import FirebaseFirestore
import FirebaseAuth

final class CommunityViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var fetchUserState: RequestState = .idle
    @Published var posts: [Post] = []
    @Published var initialFetchIsLoading: Bool = false
    @Published var paginationFetchIsLoading: Bool = false
    @Published var showFilters: Bool = false
    @Published var postFilter: PostFilter = PostFilter(stance: .all)
    @Published var error: SPError? = nil
    
    @Published var unseenNotificationsExist: Bool = false

    
    private var lastDocument: DocumentSnapshot? = nil
    private var lastPostIndex: Int = 0
    
    @MainActor
    init() {
        Task {
            do {
                fetchUserState = .loading
                guard let currentUserId = Auth.auth().currentUser?.uid else { return }
                self.user = try await UserManager.shared.fetchUser(withUid: currentUserId)
                fetchUserState = .success
                
            } catch let error as FirestoreError {
                fetchUserState = .failure(.firestore(error))
                
            } catch {
                fetchUserState = .failure(.unknown)
            }
        }
    }
    
    @MainActor
    func initialPostFetch() async {
        do {
            initialFetchIsLoading = true
            
            let (newPosts, lastDocument) = try await PostManager.shared.getAllPosts(count: 10, lastDocument: lastDocument)

            self.posts.append(contentsOf: newPosts)
            
            lastPostIndex += newPosts.count
            if let lastDocument { self.lastDocument = lastDocument }
            
        } catch let error as FirestoreError {
            self.error = .firestore(error)

        } catch {
            self.error = .unknown
        }
        
        initialFetchIsLoading = false
    }

    @MainActor
    func refreshPosts() async {
        self.posts.removeAll()
        self.lastDocument = nil
        await initialPostFetch()
    }

    @MainActor
    func deletePost(postToRemove: Post) async {
        do {
            try await PostManager.shared.deletePost(post: postToRemove)
            
            self.posts.removeAll { post in
                post == postToRemove
            }
            
        } catch let error as FirestoreError {
            self.error = .firestore(error)
            
        } catch {
            self.error = .unknown
        }
    }
}
