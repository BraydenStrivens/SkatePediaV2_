//
//  AuthService.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/4/26.
//

import Foundation
import FirebaseAuth
import FirebaseFunctions

/// Service responsible for handling authentication with Firebase.
final class AuthenticationService {

    static let shared = AuthenticationService()
    private let functions = Functions.functions()
    private init() {}

    var currentUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }

    /// Adds a listener that is triggered when the authentication state changes.
    ///
    /// - Parameters:
    ///   - listener: Closure that receives the current user (or nil if signed out).
    ///
    /// - Returns: A handle used to remove the listener.
    func addAuthStateListener(_ listener: @escaping (FirebaseAuth.User?) -> Void) -> AuthStateDidChangeListenerHandle {
        Auth.auth().addStateDidChangeListener { _, user in
            listener(user)
        }
    }

    /// Removes a previously registered authentication state listener.
    ///
    /// - Parameters:
    ///   - handle: The handle returned when adding the listener.
    func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle) {
        Auth.auth().removeStateDidChangeListener(handle)
    }

    /// Signs in a user using email and password.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    ///
    /// - Throws: An error if authentication fails.
    func login(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    /// Creates a new user and initializes their account data via a backend function,
    /// then signs the user in.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    ///   - username: The user's chosen username.
    ///   - stance: The user's selected stance.
    ///
    /// - Throws: An error if user creation or login fails.
    func createUser(email: String, password: String, username: String, stance: UserStance) async throws {
        let payload: [String : Any] = [
            "email": email,
            "password": password,
            "username": username,
            "stance": stance.rawValue
        ]
        let _ = try await functions.httpsCallable("createInitialUserData")
            .call(payload)
        
        try await login(email: email, password: password)
    }

    /// Signs out the current user and resets application state.
    ///
    /// - Throws: An error if sign-out fails.
    func signOut() throws {
        AppResetManager.reset()
        try Auth.auth().signOut()
    }

    /// Marks the current user for deletion and signs them out.
    ///
    /// - Throws: An error if no user exists or the deletion process fails.
    func deleteUser() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        try await UserManager.shared.markUserAsPendingDeletion(userId: user.uid)
        try signOut()
    }
    
    /// Sends a password reset email to the specified address.
    ///
    /// - Parameters:
    ///   - email: The email address associated with the account.
    ///
    /// - Throws: An error if the request fails.
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    /// Updates the current user's password.
    ///
    /// - Parameters:
    ///   - password: The new password to set.
    ///
    /// - Throws: An error if no user exists or the update fails.
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updatePassword(to: password)
    }
}
