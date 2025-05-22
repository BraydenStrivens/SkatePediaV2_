//
//  LoginViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/27/25.
//

import Foundation

/// Defines a class that contains functions for logging in a user to the app.
@MainActor
final class LoginViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var resetEmail = ""

    /// Signs in and validates the user with the inputted email and password.
    func signIn() async throws {
        guard validate() else {
            return
        }
        
        try await AuthenticationManager.shared.login(
            withEmail: email,
            password: password
        )
    }
    
    /// Resets the users password
    ///
    /// - Parameters:
    ///     - email: The email connected to the account.
    func resetPassword() {
        AuthenticationManager.shared.resetPassword(email: resetEmail)
    }
    
    /// Validates that the email and password textfields are not empty,
    /// also verifies the email contains both '@' and '.' symbols.
    ///
    /// - Returns: whether or not both the email and password textfields contain characters.
    private func validate() -> Bool {
        errorMessage = ""
        
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
                !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            
            errorMessage = "Please fill in all fields."
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter valid email."
            return false
        }
        
        return true
    }
}
