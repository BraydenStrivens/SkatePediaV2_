//
//  AuthenticationManger.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/20/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI


/// Defines a class that contains functions for creating, updating, and deleting user accounts in the database.
final class AuthenticationManager {
    
    @Published var userSession: FirebaseAuth.User?
    
    // Allows access to all methods contained in this class
    static let shared = AuthenticationManager()
    
    init() {
        self.userSession = Auth.auth().currentUser
    }
    
    @MainActor
    func login(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            try await UserManager.shared.fetchCurrentUser()
        }
    }
    
    @MainActor
    func createUser(withEmail email: String, password: String, username: String, stance: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            try await uploadUserData(
                id: result.user.uid,
                withEmail: email,
                username: username,
                stance: stance
            )
            
            try await TrickListManager.shared.readJSonFile(userId: result.user.uid)
        } catch {
            print("DEBUG: Failed to create or upload user data: \(error.localizedDescription)")
        }
        
    }
    
    func signOut() {
        try? Auth.auth().signOut() // Signs out on backend
        self.userSession = nil // Removes session locally
        UserManager.shared.reset() // Sets current user object to nil
    }
    
    @MainActor
    private func uploadUserData(
        id: String,
        withEmail email: String,
        username: String,
        stance: String
    ) async throws {
        let user = User(
            userId: id,
            email: email,
            username: username,
            stance: stance,
            dateCreated: Date()
        )
        
        guard let userData = try? Firestore.Encoder().encode(user) else { return }
        
        try await Firestore.firestore().collection("users").document(id).setData(userData)
        UserManager.shared.currentUser = user
    }
    
    
    /// Resets the password of the account with the given email.
    ///
    /// - Parameters: The email of the account to reset.
    func resetPassword(email: String) {
        
        let _ = Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                let errorMessage = Text(error.localizedDescription)
                let _ = Alert(title: Text("Error Resetting Password"), message: errorMessage)
                return
            }
        }
    }
    
    /// Changes the password of the current user
    ///
    /// - Parameters:
    ///     - password: The new password to give to the current user
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updatePassword(to: password)
    }
    
    /// Deletes the current user
    ///
    /// > Warning: Does not delete user information within the database and storage.
    @MainActor
    func deleteUser() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        signOut()
        try await user.delete()
    }
}
