//
//  UserAccountViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/11/26.
//

import Foundation

#warning("UPDATE")
final class UserAccountViewModel: ObservableObject {
    
    private let errorStore: ErrorStore
    private let useCases: UserUseCases
    
    init(
        errorStore: ErrorStore,
        useCases: UserUseCases
    ) {
        self.errorStore = errorStore
        self.useCases = useCases
    }
    
    @MainActor
    func sendFriendRequest(_ currentUser: User, to otherUser: User) async -> Bool {
        do {
            try await useCases.sendFriendRequest(currentUser, to: otherUser)
            return true
            
        } catch {
            errorStore.present(error, title: "Error Sending Friend Request")
            return false
        }
    }
    
    @MainActor
    func reportUser(_ currentUser: User, report otherUser: User) async {
        
    }
}
