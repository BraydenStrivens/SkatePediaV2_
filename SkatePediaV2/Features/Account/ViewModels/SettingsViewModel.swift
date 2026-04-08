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

/// Manages the state and actions for the account options (settings) view.
///
/// This class handles updating user profile information, managing profile images,
/// handling authentication actions such as signing out and deleting the account,
/// and coordinating with services for data persistence and validation.
@MainActor
final class AccountOptionsViewModel: ObservableObject {
    @Published private(set) var user: User
    @Published var newUsername: String
    @Published var newStance: UserStance
    @Published var newBio: String
    @Published var deleteProfilePhoto: Bool = false
    @Published var profileImage: Image?
    
    /// The selected photo picker item used to load a new profile image.
    ///
    /// When set, triggers loading of the image data.
    @Published var selectedItem: PhotosPickerItem? {
        didSet { Task { await loadImage() } }
    }
    
    private var uiImage: UIImage?
    
    @Published var updatingUser: Bool = false
    @Published var isDeleting: Bool = false
    
    private let errorStore: ErrorStore
    private let authService: AuthenticationService
    private let userService: UserService
    
    /// Creates a new `AccountOptionsViewModel`.
    ///
    /// - Parameters:
    ///   - user: The current user whose data will be edited.
    ///   - errorStore: The shared error store for handling errors.
    ///   - authService: The authentication service. Defaults to `.shared`.
    ///   - userService: The user service. Defaults to `.shared`.
    init(
        user: User,
        errorStore: ErrorStore,
        authService: AuthenticationService = .shared,
        userService: UserService = .shared
    ) {
        self.user = user
        self.newUsername = user.username
        self.newStance = user.stance
        self.newBio = user.bio
        
        self.errorStore = errorStore
        self.authService = authService
        self.userService = userService
    }
    
    /// Updates the user's profile information if any changes were made.
    ///
    /// This includes validating and updating the username, stance, bio,
    /// and profile photo. Only modified fields are persisted.
    ///
    /// - Returns: `true` if the update succeeds, otherwise `false`.
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
                try userService.updateUser(updatedUser: updatedUser)
            }
            
            self.user = updatedUser
            return true
            
        } catch {
            errorStore.present(error, title: "Error Updating Profile")
            return false
        }
    }
    
    /// Signs the current user out of their account.
    ///
    /// Any errors during sign-out are presented using the error store.
    func signOut() {
        do {
            try authService.signOut()
        } catch {
            errorStore.present(error, title: "Error Signing Out")
        }
    }
    
    /// Updates the password of the current user's account.
    ///
    /// The password must meet minimum length requirements before being submitted.
    ///
    /// - Parameter password: The new password to set.
    /// - Returns: `true` if the update succeeds, otherwise `false`.
    func updatePassword(password: String) async -> Bool {
        do {
            guard password.count >= 6 else {
                throw SPError.custom("Password must be at least 6 characters.")
            }
            
            try await authService.updatePassword(
                password: password.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            return true
            
        } catch {
            errorStore.present(error, title: "Error Updating Password")
            return false
        }
    }
    
    /// Deletes the current user's account.
    ///
    /// This removes the user from authentication, database, and storage.
    /// Any errors are presented using the error store.
    func deleteUser() async {
        self.isDeleting = true
        defer { isDeleting = false }
        
        do {
            try await authService.deleteUser()
        } catch {
            errorStore.present(error, title: "Error Deleting Account")
        }
    }
    
    /// Loads the selected image from the photo picker.
    ///
    /// Converts the selected item into a `UIImage` for uploading and a SwiftUI `Image`
    /// for previewing in the UI.
    private func loadImage() async {
        guard let item = selectedItem else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        
        self.uiImage = uiImage
        self.profileImage = Image(uiImage: uiImage)
    }
    
    /// Resets all editable fields back to the current user's saved values.
    ///
    /// This clears any selected images and restores original profile data.
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
