//
//  AuthService.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/4/26.
//

import Foundation

import FirebaseAuth

final class AuthenticationService {

    static let shared = AuthenticationService()
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
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            try await UserManager.shared.fetchCurrentUser()
            
        } catch let error as AuthError {
            throw error
            
        } catch {
            throw AuthError.mapFirebaseError(error)
        }
    }

    func createUser(email: String, password: String, username: String, stance: String) async throws {
        let authResult: AuthDataResult
        
        do {
            // Attemps to create a new user
            authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            
        } catch let error as AuthError {
            throw error
            
        } catch {
            throw AuthError.mapFirebaseError(error)
        }
        
        do {
            // Attempts to create a user document in firestore database
            try await UserManager.shared.uploadUserData(
                id: authResult.user.uid,
                withEmail: email,
                username: username,
                stance: stance
            )
            
            // Creates trick list as a subcollection in the user's document
            try await TrickListManager.shared.readJSonFile(userId: authResult.user.uid)

        } catch {
            // If auth successfully creates a user but firestore fails to upload their data, this deletes the user from
            // auth so the user can recreate their account
            try await deleteUser()
            throw FirestoreError.mapFirebaseError(error)
        }
        
        print(authResult.user)
    }

    func signOut() throws {
        do {
            try Auth.auth().signOut()
            UserManager.shared.reset()
        } catch {
            throw AuthError.mapFirebaseError(error)
        }
    }

    func deleteUser() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        do {
            try signOut()
            try await user.delete()
        } catch {
            throw AuthError.mapFirebaseError(error)
        }
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch let error as AuthError {
            throw error
        } catch {
            throw AuthError.mapFirebaseError(error)
        }
    }
    
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        do {
            try await user.updatePassword(to: password)
        } catch {
            throw AuthError.mapFirebaseError(error)
        }
    }
}
