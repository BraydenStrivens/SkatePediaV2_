//
//  UserAccountViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/11/26.
//

import Foundation

final class UserAccountViewModel: ObservableObject {
    
    private let errorStore: ErrorStore
    private let userService: UserService
    
    init(
        errorStore: ErrorStore,
        userService: UserService = .shared
    ) {
        self.errorStore = errorStore
        self.userService = userService
    }
    
    @MainActor
    func sendFriendRequest(_ currentUser: User, to otherUser: User) async -> Bool {
        do {
            try await userService.sendFriendRequest(currentUser, to: otherUser)
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
