//
//  SettingsViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/28/25.
//

import Foundation
import SwiftUI
import PhotosUI
import AVKit
import FirebaseAuth
import FirebaseFirestore
import Firebase

/// Defines a class that contains functions for the 'SettingsView'
@MainActor
final class SettingsViewModel: ObservableObject {    
    @Published private(set) var user: User
    @Published var newUsername: String
    @Published var newStance: UserStance
    @Published var newBio: String
    @Published var deleteProfilePhoto: Bool = false
    @Published var profileImage: Image?
    @Published var selectedItem: PhotosPickerItem? {
        didSet { Task { await loadImage() } }
    }
    
    private var uiImage: UIImage?
    
    @Published var updatingUser: Bool = false
    @Published var isDeleting: Bool = false
    @Published var error: SPError? = nil
    
    private let errorStore: ErrorStore
    private let useCases: UserUseCases
    
    init(
        user: User,
        errorStore: ErrorStore,
        useCases: UserUseCases
    ) {
        self.user = user
        self.newUsername = user.username
        self.newStance = user.stance
        self.newBio = user.bio
        
        self.errorStore = errorStore
        self.useCases = useCases
    }
    
    func updateUserProfile() async -> Bool {
        var hasUpdate: Bool = false
        updatingUser = true
        defer { updatingUser = false }
        
        do {
            var updatedUser = self.user
                        
            if newUsername != user.username {
                let normalizedUsername = newUsername
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .lowercased()
                
                guard normalizedUsername.count > 4, normalizedUsername.count <= 15 else {
                    throw SPError.custom("Username must be between 5 and 15 characters.")
                }
                
                updatedUser.username = newUsername
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                updatedUser.usernameLowercase = normalizedUsername
                hasUpdate = true
            }
            if newStance != user.stance {
                updatedUser.stance = newStance
                hasUpdate = true
            }
            if newBio != user.bio {
                let normalizedBio = newBio.trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard normalizedBio.count < 1000 else {
                    throw SPError.custom("Bio must be less than 1000 characters.")
                }
                
                updatedUser.bio = normalizedBio
                hasUpdate = true
            }
            
            if let photo = self.uiImage, selectedItem != nil {
                let photoData = try await StorageManager.shared.uploadProfilePhoto(
                    photo,
                    userId: user.userId
                )
                updatedUser.profilePhoto = photoData
                hasUpdate = true
            }
            
            if deleteProfilePhoto {
                updatedUser.profilePhoto = nil
                hasUpdate = true
            }
            
            if hasUpdate {
                try useCases.updateUser(updatedUser: updatedUser)
            }
            
            self.user = updatedUser
            return true
            
        } catch {
            errorStore.present(error, title: "Error Updating Profile")
            return false
        }
    }
    
    func signOut() {
        do {
            try AuthenticationService.shared.signOut()
        } catch {
            errorStore.present(error, title: "Error Signing Out")
        }
    }
    
    /// Updates the password of the current user's account.
    func updatePassword(password: String) async -> Bool {
        do {
            guard password.count >= 6 else {
                throw SPError.custom("Password must be at least 6 characters.")
            }
            
            try await AuthenticationService.shared.updatePassword(
                password: password.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            return true
            
        } catch {
            errorStore.present(error, title: "Error Updating Password")
            return false
        }
    }
    
    /// Deletes the user account from the database and storage.
    func deleteUser() async {
        self.isDeleting = true
        defer { isDeleting = false }
        
        do {
            try await AuthenticationService.shared.deleteUser()
        } catch {
            errorStore.present(error, title: "Error Deleting Account")
        }
    }
    
    private func loadImage() async {
        guard let item = selectedItem else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        
        self.uiImage = uiImage
        self.profileImage = Image(uiImage: uiImage)
    }
    
    func resetEdit() {
        profileImage = nil
        selectedItem = nil
        uiImage = nil
        deleteProfilePhoto = false
        
        newBio = user.bio
        newStance = user.stance
        newUsername = user.username
    }
}
