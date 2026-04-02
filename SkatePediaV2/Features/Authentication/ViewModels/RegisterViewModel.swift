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
    @Published var stance: UserStance? = nil
    @Published var isLoading: Bool = false
    
    private let errorStore: ErrorStore
    
    init(errorStore: ErrorStore) {
        self.errorStore = errorStore
    }
    
    /// Sends the user input from the RegisterView to the AuthenticationService class to create the user auth
    /// and upload their doucments.
    @MainActor
    func createUser() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try validateInputFields()
            
            guard let stance = stance else {
                throw SPError.custom("Please select a stance.")
            }
            
            try await AuthenticationService.shared.createUser(
                email: email.trimmingCharacters(in: .whitespaces),
                password: password.trimmingCharacters(in: .whitespacesAndNewlines),
                username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                stance: stance
            )
        } catch {
            errorStore.present(error, title: "Error Creating Account")
        }
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
    }
}
