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

///
/// Defines a class that contains functions for registering new users to the database.
///
@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var stance: String = ""
    @Published var error: SPError? = nil
    @Published var isLoading: Bool = false
    
    /// Sends the user input from the RegisterView to the AuthenticationService class to create the user auth
    /// and upload their doucments.
    @MainActor
    func createUser() async {
        isLoading = true
        do {
            try validateInputFields()
            
            try await AuthenticationService.shared.createUser(
                email: email.trimmingCharacters(in: .whitespaces),
                password: password.trimmingCharacters(in: .whitespacesAndNewlines),
                username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                stance: stance.trimmingCharacters(in: .whitespaces)
            )
        } catch {
            self.error = mapToSPError(error: error)
        }
        isLoading = false
    }
    
    /// Validates the input fields in the RegisterView are not empty and ensures the username is 15 characters or less.
    /// Throws appropriate error if validation fails and that error gets mapped an displayed to the user.
    ///
    /// - Throws: A custom error object specifying the error.
    ///
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
        guard !stance.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw SPError.custom("Please select a stance.")
        }
    }
}
