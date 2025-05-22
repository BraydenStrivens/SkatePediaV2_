//
//  RegisterViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/28/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

/// Defines a class that contains functions for registering new users to the database.
@MainActor
final class RegisterViewModel: ObservableObject {
    
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var stance = "Regular"
    @Published var errorMessage = ""
    
    @MainActor
    func createUser() async throws {
        try await AuthenticationManager.shared.createUser(
            withEmail: email,
            password: password,
            username: username,
            stance: stance
        )
    }
    
    /// Validates the register view text fields aren't empty,
    /// also verifies the email contains '@' and '.' characters,
    /// also verifies the password is at least 6 characters long.
    ///
    /// - Returns: whether or not the inputted account information meets the required critera
    private func validate() -> Bool {
        errorMessage = ""
        
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please fill in all fields."
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Not a valid email address."
            return false
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least six characters."
            return false
        }
        
        return true
    }
}
