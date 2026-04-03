//
//  LoginViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/27/25.
//

import Foundation
import FirebaseAuth
import SwiftUI
import UIKit

/// View model responsible for handling user login.
///
/// Manages login form state, validates input, and performs authentication
/// through `AuthenticationService`.
///
/// - Parameters:
///   - errorStore: Used to present errors to the user.
///   - authService: Service responsible for authentication actions.
@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var resetEmail: String = ""
    @Published var loginLoading: Bool = false
    
    private let errorStore: ErrorStore
    private let authService: AuthenticationService
    
    init(
        errorStore: ErrorStore,
        authService: AuthenticationService = .shared
    ) {
        self.errorStore = errorStore
        self.authService = authService
    }

    /// Attempts to sign in the user with the provided credentials.
    ///
    /// Validates input fields and calls `AuthenticationService` to perform login.
    ///
    /// - Important: Errors are caught and presented via `ErrorStore`.
    func signIn() async {
        loginLoading = true
        defer { loginLoading = false }
        
        do {
            try emptyInputFieldCheck()
            
            try await authService.login(
                email: email,
                password: password
            )
        } catch {
            errorStore.present(error, title: "Error Signing In")
        }
    }
    
    /// Validates that email and password fields are not empty.
    ///
    /// - Throws: An error describing the validation failure.
    func emptyInputFieldCheck() throws {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AuthError.emptyEmail
        }
        guard !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AuthError.emptyPassword
        }
    }
}
