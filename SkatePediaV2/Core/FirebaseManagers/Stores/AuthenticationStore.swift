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

@MainActor
final class AuthenticationStore: ObservableObject {

    @Published var userSession: FirebaseAuth.User?
    @Published var isLoading = true

    private let authService: AuthenticationService
    private var authHandle: AuthStateDidChangeListenerHandle?

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

    deinit {
        if let handle = authHandle {
            authService.removeAuthStateListener(handle)
        }
    }
}
