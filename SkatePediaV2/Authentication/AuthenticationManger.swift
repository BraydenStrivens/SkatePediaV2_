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


///
/// Defines a class that contains functions for creating, updating, and deleting user accounts in the database.
///
final class AuthenticationManager {
    
    // Stores the current logged in user
    @Published var userSession: FirebaseAuth.User?
    
    static let shared = AuthenticationManager()
    
    init() {
        self.userSession = Auth.auth().currentUser
    }
    
    ///
    /// Logs in a user given an email and password.
    ///
    /// - Parameters:
    ///  - email: The email of a user's account in the database.
    ///  - password: The password linked to a user's account in the database.
    ///
    @MainActor
    func login(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            try await UserManager.shared.fetchCurrentUser()
        }
    }
    
    ///
    /// Creates a new user in Firebase's Authentication. Creates a new user document in the database and generates a trick list for that user.
    ///
    @MainActor
    func createUser(withEmail email: String, password: String, username: String, stance: String) async throws {
        do {
            // Creates a new authenticated user and assigns it to the current logged in user
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            // Creates user document in database
            try await uploadUserData(
                id: result.user.uid,
                withEmail: email,
                username: username,
                stance: stance
            )
            
            // Creates trick list as a subcollection in the user's document
            try await TrickListManager.shared.readJSonFile(userId: result.user.uid)
            
        } catch {
            print("DEBUG: Failed to create or upload user data: \(error)")
        }
        
    }
    
    ///
    /// Signs out the current user.
    ///
    func signOut() {
        try? Auth.auth().signOut() // Signs out on backend
        self.userSession = nil // Removes session locally
        UserManager.shared.reset() // Sets current user object to nil
    }
    
    ///
    /// Creates a User object and uploads it to the database.
    ///
    /// - Parameters:
    ///  - id: A unique ID for a new user in the database.
    ///  - email: The email linked to a user account.
    ///  - username: The display name for a user account.
    ///  - stance: The skateboard stance of a user.
    ///
    @MainActor
    private func uploadUserData(id: String, withEmail email: String, username: String, stance: String) async throws {
        let user = User(
            userId: id,
            email: email,
            username: username,
            stance: stance,
            dateCreated: Date()
        )
        
        guard let userData = try? Firestore.Encoder().encode(user) else { return }
        
        // Creates a new user document and uploads the users data to it
        try await Firestore.firestore().collection("users").document(id).setData(userData)
        
        // Sets the current logged in user
        UserManager.shared.currentUser = user
    }
    
    
    ///
    /// Resets the password of the account with the given email.
    ///
    /// - Parameters: The email of the account to reset.
    ///
    func resetPassword(email: String) {
        
        let _ = Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                let errorMessage = Text(error.localizedDescription)
                let _ = Alert(title: Text("Error Resetting Password"), message: errorMessage)
                return
            }
        }
    }
    
    ///
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
    
    ///
    /// Deletes the current user from Firebase's authentication.
    ///
    /// > Warning: Does not delete the user's document in the database or items linked to the user in storage. 
    ///
    @MainActor
    func deleteUser() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        signOut()
        try await user.delete()
    }
}
