//
//  SettingsViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/28/25.
//

import Foundation
import SwiftUI
import FirebaseAuth

/// Defines a class that contains functions for the 'SettingsView'
@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var errorMessage: String = ""
    @Published var isDeleting: Bool = false
    
    init() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        Task {
            self.user = try await UserManager.shared.fetchUser(withUid: uid)
        }
    }
    
    /// Signs out the current user
    func signOut() throws {
        try AuthenticationService.shared.signOut()
    }
    
    /// Updates the password of the current user's account.
    ///
    /// - Parameters:
    ///  - password: The new password to update to the account.
    func updatePassword(password: String) async throws {
        try await AuthenticationService.shared.updatePassword(password: password)
    }
    
    /// Deletes the user account from the database and storage.
    ///
    /// - Parameters:
    ///  - userId: The id of an account in the database.
    func deleteUser(userId: String) async throws {
        self.isDeleting = true
        TrickListInfoManager.shared.removeListener()
        
        do {
            // Deletes the users account
            try await AuthenticationService.shared.deleteUser()
        } catch {
            self.errorMessage = "\(error)"
            print("COULDNT DELETE AUTH USER: \(error)")
            return
        }
        
        do {
            // Deletes all the users data and videos
            try await UserManager.shared.deleteUserData(userId: userId)
        } catch {
            print("COUDLNT DELETE USER DATA: \(error)")
            self.errorMessage = "\(error)"
        }
        
    }
}
