//
//  AuthenticationViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/4/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

/// Observable store that manages authentication state for the app.
///
/// Listens for Firebase auth state changes and updates the current user session.
@MainActor
final class AuthenticationStore: ObservableObject {

    @Published var userSession: FirebaseAuth.User?
    @Published var isLoading = true

    private let authService: AuthenticationService
    private var authHandle: AuthStateDidChangeListenerHandle?

    /// Initializes the store and begins listening for authentication state changes.
    ///
    /// - Parameters:
    ///   - authService: Service used to observe authentication state. Defaults to shared instance.
    init(authService: AuthenticationService = .shared) {
        self.authService = authService

        self.authHandle = authService.addAuthStateListener { [weak self] user in
            guard let self else { return }
            
            print("AUTH STATE CHANGE DETECTED")
            print("USER ID: ", user?.uid ?? "nil")
            print("===============================")
            
            self.userSession = user
            self.isLoading = false
        }
    }

    /// Cleans up the authentication state listener when the store is deallocated.
    deinit {
        if let handle = authHandle {
            authService.removeAuthStateListener(handle)
        }
    }
}
