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
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var stance = "Regular"
    @Published var createUserError: AuthError?
    @Published var uploadUserDocError: FirestoreError?
    
    ///
    /// Creates a new user in Firebase's Authentication. Creates a new user document in the database, and generates a trick list for the user.
    ///
    @MainActor
    func createUser() async throws {
        do {
            try validateInputFields()
            
            try await AuthenticationService.shared.createUser(
                email: email,
                password: password,
                username: username,
                stance: stance
            )
        } catch {
            throw error
        }
    }
    
    ///
    /// Validates the register view text fields aren't empty,
    /// also verifies the email contains '@' and '.' characters,
    /// also verifies the password is at least 6 characters long.
    ///
    /// - Returns: whether or not the inputted account information meets the required critera
    /// 
    private func validateInputFields() throws {
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AuthError.emptyUsername
        }
        
        guard username.count <= 15 else {
            throw AuthError.invalidUsername
        }
        
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AuthError.emptyEmail
        }
        
        guard !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AuthError.emptyPassword
        }
    }
}
