//
//  RegisterViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/28/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

/// View model responsible for handling user registration.
///
/// Manages form state, validates user input, and coordinates account creation
/// through `AuthenticationService`.
///
/// - Parameters:
///   - errorStore: Used to present errors to the user.
///   - authService: Service responsible for authentication actions.
@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var stance: UserStance? = nil
    @Published var isLoading: Bool = false
    
    private let errorStore: ErrorStore
    private let authService: AuthenticationService
    
    init(
        errorStore: ErrorStore,
        authService: AuthenticationService = .shared
    ) {
        self.errorStore = errorStore
        self.authService = authService
    }
    
    /// Attempts to create a new user using the provided input fields.
    ///
    /// Validates user input, ensures a stance is selected, and calls
    /// `AuthenticationService` to create the account.
    ///
    /// - Important: Errors are caught and presented via `ErrorStore`.
    func createUser() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard let stance = stance else {
                throw SPError.custom("Please select a stance.")
            }
            
            try validateInputFields()

            try await authService.createUser(
                email: email,
                password: password,
                username: username,
                stance: stance
            )
        } catch {
            errorStore.present(error, title: "Error Creating Account")
        }
    }
    
    /// Validates registration input fields and normalizes their values.
    ///
    /// Ensures all fields are non-empty, enforces username and password constraints,
    /// and trims whitespace/newlines from inputs.
    ///
    /// - Throws: An error describing the validation failure.
    private func validateInputFields() throws {
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AuthError.emptyUsername
        }
        guard username.count <= 15, username.count > 4 else {
            throw SPError.custom("Username must be between 5 and 15 characters.")
        }
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AuthError.emptyEmail
        }
        guard !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AuthError.emptyPassword
        }
        guard password.count >= 6 else {
            throw SPError.custom("Password must be at least 6 characters.")
        }
        
        email = email.trimmingCharacters(in: .whitespaces)
        password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        username = username.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
