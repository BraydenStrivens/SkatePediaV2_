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
    @Published var error: SPError? = nil
    @Published var isFetchingMore: Bool = false
    
    private var listener: ListenerRegistration? = nil
    private var lastDocument: DocumentSnapshot? = nil
    private let batchCount: Int = 20
    private var lastFetchCount: Int = 0
    private var isInitialFetch: Bool = true
    
    @MainActor
    func addListenerToFirstNChats(user: User) async {
        do {
            self.initialListenerState = .loading
            
            self.listener = try await MessagingManager.shared.userChatsListenerQuery(userId: user.userId, count: batchCount)
                .addSnapshotListener({ [weak self] snapshot, error in
                    if let error = error {
                        let mappedError = FirestoreError.mapFirebaseError(error)
                        self?.initialListenerState = .failure(.firestore(mappedError))
                        return
                    }
                    guard let self = self, let snapshot = snapshot else { return }
                    
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
            self.initialListenerState = .success
            
        } catch let error as FirestoreError {
            self.initialListenerState = .failure(.firestore(error))
        } catch {
            self.initialListenerState = .failure(.unknown)
        }
    }
    
    @MainActor
    func removeListenerToFirstNChats() {
        self.listener?.remove()
    }
    
    @MainActor
    func fetchMoreUserChats(user: User) async {
        guard lastFetchCount == batchCount else { return }
        self.isFetchingMore = true

        do {
            let (currentBatch, lastDocument) = try await MessagingManager.shared.fetchUserChats(
                userId: user.userId, count: batchCount, lastDocument: lastDocument
            )
            self.chattingWithUsers.append(contentsOf: currentBatch)
            if let lastDocument { self.lastDocument = lastDocument }
            
        } catch let error as FirestoreError {
            self.error = .firestore(error)
        } catch {
            self.error = .unknown
        }
        self.isFetchingMore = false
    }
    
    func updateChatHidden(userId: String, withUserId: String, hidden: Bool) async {
        do {
            try await MessagingManager.shared.updateUserChatHidden(
                userId: userId,
                withUserId: withUserId,
                hidden: hidden
            )
        } catch let error as FirestoreError {
            self.error = .firestore(error)
        } catch {
            self.error = .unknown
        }
    }
}
