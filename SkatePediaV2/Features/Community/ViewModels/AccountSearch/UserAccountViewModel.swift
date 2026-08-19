//
//  UserAccountViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/11/26.
//

import Foundation

final class UserAccountViewModel: ObservableObject {
    
    private let errorStore: ErrorStore
    private let appEnv: AppEnvironment
    
    init(
        errorStore: ErrorStore,
        appEnv: AppEnvironment
    ) {
        self.errorStore = errorStore
        self.appEnv = appEnv
    }
    
    @MainActor
    func sendFriendRequest(
        _ currentUser: User,
        to otherUser: User
    ) async -> AppSuccess? {
        
        do {
            try await appEnv.relationshipService.createRelationship(
                otherUid: otherUser.userId
            )
            
            return AppSuccess(message: "Friend Request Sent!")
            
        } catch {
            errorStore.present(error, title: "Error Sending Friend Request")
            return nil
        }
    }
    
    @MainActor
    func blockUser(
        currentUid: String,
        otherUid: String
    ) async -> AppSuccess? {
        do {
            try await appEnv.relationshipService.blockUser(
                currentUid: currentUid,
                otherUid: otherUid
            )
            
            return AppSuccess(message: "User Successfully Blocked")

        } catch {
            errorStore.present(error, title: "Error Blocking User")
            return nil
        }
    }
}
