//
//  AuthService.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/4/26.
//

import Foundation

import FirebaseAuth
import FirebaseFunctions

final class AuthenticationService {

    static let shared = AuthenticationService()
    private let functions = Functions.functions()
    private init() {}

    var currentUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }

    func addAuthStateListener(_ listener: @escaping (FirebaseAuth.User?) -> Void) -> AuthStateDidChangeListenerHandle {
        Auth.auth().addStateDidChangeListener { _, user in
            listener(user)
        }
    }

    func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle) {
        Auth.auth().removeStateDidChangeListener(handle)
    }

    func login(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
//        try await UserManager.shared.fetchCurrentUser()
    }

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

    func signOut() throws {
        do {
            try Auth.auth().signOut()
            UserManager.shared.reset()
        } catch {
            throw error
        }
    }

    func deleteUser() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        try signOut()
        try await user.delete()
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updatePassword(to: password)
    }
}
