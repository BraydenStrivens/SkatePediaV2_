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

///
/// Defines a class that contains functions for logging in a user to the app.
///
@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var resetEmail: String = ""
    @Published var loginLoading: Bool = false
    
    private let errorStore: ErrorStore
    
    init(errorStore: ErrorStore) {
        self.errorStore = errorStore
    }

    /// Valids the login input fields contain characters and attempts to login in the user.
    ///
    /// - Throws: An error mapped to an SPError object that specifies the error.
    ///
    func signIn() async {
        loginLoading = true
        defer { loginLoading = false }
        
        do {
            try emptyInputFieldCheck()
            try await AuthenticationService.shared.login(
                email: email,
                password: password
            )
        } catch {
            errorStore.present(error, title: "Error Signing In")
        }
    }
    
    /// Sends a reset password link to the inputted email address.
    func resetPassword() async -> Bool {
        do {
            guard !resetEmail.trimmingCharacters(in: .whitespaces).isEmpty else {
                throw AuthError.emptyEmail
            }
            
            try await AuthenticationService.shared.resetPassword(email: resetEmail)
            return true
            
        } catch {
            errorStore.present(error, title: "Error Resetting Password")
            return false
        }
    }
    
    /// Validates that the email and password textfields are not empty,
    ///
    /// - Parameters:
    ///  - checkPassword: Boolean that indicates whether to validate the password input field.
    ///
    /// - Throws: An error mapped to an SPError object that specifies the error.
    ///
    func emptyInputFieldCheck() throws {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AuthError.emptyEmail
        }
        guard !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AuthError.emptyPassword
        }
    }
}
