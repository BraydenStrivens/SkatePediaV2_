//
//  AuthenticationViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/4/26.
//

import Foundation
import FirebaseAuth
import SwiftUI

@MainActor
final class AuthenticationViewModel: ObservableObject {

    @Published var userSession: FirebaseAuth.User?
    @Published var isLoading = true

    private let authService: AuthenticationService
    private var authHandle: AuthStateDidChangeListenerHandle?

    init(authService: AuthenticationService = .shared) {
        self.authService = authService

        self.authHandle = authService.addAuthStateListener { [weak self] user in
            self?.userSession = user
            self?.isLoading = false
        }
    }

    deinit {
        if let handle = authHandle {
            authService.removeAuthStateListener(handle)
        }
    }

//    func login(email: String, password: String) async throws {
//        do {
//            try await authService.login(email: email, password: password)
//        } catch {
//            throw error
//        }
//    }
//
//    func createUser(email: String, password: String, username: String, stance: String) async throws {
//        do {
//            try await authService.createUser(email: email, password: password, username: username, stance: stance)
//        } catch {
//            throw error
//        }
//    }
//    
//    func resetPassword(email: String) async throws {
//        do {
//            try await authService.resetPassword(email: email)
//        } catch {
//            throw error
//        }
//    }
//    
//    func updatePassword(password: String) async throws {
//        do {
//            try await authService.updatePassword(password: password)
//        } catch {
//            throw error
//        }
//    }
//    
//    func signOut() throws {
//        try? authService.signOut()
//    }
//
//    func deleteUser() async throws {
//        do {
//            try await authService.deleteUser()
//        } catch {
//            throw error
//        }
//    }
}
