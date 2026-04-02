//
//  MessagesViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

final class UserChatsViewModel: ObservableObject {
    @Published var chattingWithUsers: [UserChat] = []
    @Published var searchString: String = ""
    @Published var initialListenerState: RequestState = .idle
    @Published var isFetchingMore: Bool = false
    
    private var listener: ListenerRegistration? = nil
    private var lastDocument: DocumentSnapshot? = nil
    private let batchCount: Int = 20
    private var lastFetchCount: Int = 0
    private var isInitialFetch: Bool = true
    
    private let errorStore: ErrorStore
    
    init(errorStore: ErrorStore) {
        self.errorStore = errorStore
    }
    
    @MainActor
    func addListenerToFirstNChats(user: User) async {
        do {
            initialListenerState = .loading
            
            listener = try await MessagingManager.shared.userChatsListenerQuery(userId: user.userId, count: batchCount)
                .addSnapshotListener({ [weak self] snapshot, error in
                    if let error = error {
                        let mappedError = FirestoreError.mapFirebaseError(error)
                        self?.initialListenerState = .failure(.firestore(mappedError))
                        return
                    }
                    guard let self = self, let snapshot = snapshot else {
                        return
                    }
                    
                    let initialBatch = snapshot.documents.compactMap {
                        try? $0.data(as: UserChat.self)
                    }
                    
                    if isInitialFetch {
                        self.chattingWithUsers = initialBatch
                        self.isInitialFetch = false
                        
                    } else {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self.chattingWithUsers = initialBatch
                        }
                    }
                    self.lastDocument = snapshot.documents.last
                    self.lastFetchCount = self.chattingWithUsers.count
                })
            initialListenerState = .success
            print("CHATS:")
            print(chattingWithUsers)
            
        } catch {
            initialListenerState = .failure(mapToSPError(error: error))
        }
    }
    
    @MainActor
    func removeListenerToFirstNChats() {
        self.listener?.remove()
    }
    
    @MainActor
    func fetchMoreUserChats(user: User) async {
        guard lastFetchCount == batchCount else { return }
        isFetchingMore = true
        defer { isFetchingMore = false }

        do {
            let (currentBatch, lastDocument) = try await MessagingManager.shared.fetchUserChats(
                userId: user.userId, count: batchCount, lastDocument: lastDocument
            )
            self.chattingWithUsers.append(contentsOf: currentBatch)
            if let lastDocument { self.lastDocument = lastDocument }
            
        } catch {
            errorStore.present(error, title: "Error Fetching Chats")
        }
    }
    
    @MainActor
    func updateChatHidden(
        userId: String,
        withUserId: String,
        hidden: Bool
    ) async {
        do {
            try await MessagingManager.shared.updateUserChatHidden(
                userId: userId,
                withUserId: withUserId,
                hidden: hidden
            )
        } catch {
            errorStore.present(error, title: "Error Updating Chat")
        }
    }
}
