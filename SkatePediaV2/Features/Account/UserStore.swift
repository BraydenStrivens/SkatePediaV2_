//
//  UserStore.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/27/26.
//

import Foundation
import FirebaseFirestore

struct UserUIState: Equatable {
    let username: String
    let stance: UserStance
    let bio: String
    let profilePhoto: ProfilePhotoData?
    let settings: UserSettings
    let trickListData: TrickListData
}

@MainActor
final class UserStore: ObservableObject {
    @Published private(set) var user: User?
    
    var trickSettings: TrickListSettings? {
        user?.settings.trickSettings
    }
    var profileSettings: ProfileSettings? {
        user?.settings.profileSettings
    }
    var trickListData: TrickListData? {
        user?.trickListData
    }

    @Published var isLoading = false
    @Published var blockingError: SPError?
    @Published var error: SPError?
    
    private var lastUIState: UserUIState?
    private var timeoutTask: Task<Void, Never>?
    private let service = UserService.shared
    
    func startListening(uid: String) {
        isLoading = true
        blockingError = nil
        
        startTimeout()
        
        service.listenToUser(userId: uid) { [weak self] result in
            guard let self else { return }
            
            self.timeoutTask?.cancel()
            
            Task { @MainActor in
                switch result {
                case .success(let newUser):
                    self.isLoading = false
                    
                    if self.shouldPublishUpdate(newUser) {
                        print("USER SNAPSHOT RECEIVED")
                        self.user = newUser
                    }
                case .failure(let error):
                    self.isLoading = false
                    self.blockingError = mapToSPError(error: error)
                }
            }
        }
    }
    
    func stopListening() {
        service.removeListener()
    }
    
    private func shouldPublishUpdate(_ newUser: User) -> Bool {
        let newState = UserUIState(
            username: newUser.username,
            stance: newUser.stance,
            bio: newUser.bio,
            profilePhoto: newUser.profilePhoto,
            settings: newUser.settings,
            trickListData: newUser.trickListData
        )
        
        defer { lastUIState = newState }
        
        return newState != lastUIState
    }
    
    private func startTimeout() {
        timeoutTask?.cancel()
        
        timeoutTask = Task {
            try? await Task.sleep(nanoseconds: 15_000_000_000)
            
            if !Task.isCancelled {
                await MainActor.run {
                    if self.user == nil {
                        self.isLoading = false
                        self.blockingError = SPError.custom("Failed to load account. Please logout and log back in.")
                    }
                }
            }
        }
    }
    
    func resetUnseenNotificationCount() {
//        guard var updated = user else { return }
//        updated.unseenNotificationCount = 0
//        user = updated
        user?.unseenNotificationCount = 0
    }
}
