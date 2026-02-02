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
    @Published var passwordResetSent: Bool = false
    @Published var loginLoading: Bool = false
    @Published var error: SPError? = nil

    /// Valids the login input fields contain characters and attempts to login in the user.
    ///
    /// - Throws: An error mapped to an SPError object that specifies the error.
    ///
    func signIn() async {
        loginLoading = true
        do {
            try emptyInputFieldCheck(checkPassword: true)
            try await AuthenticationService.shared.login(
                email: email,
                password: password
            )
        } catch {
            self.error = mapToSPError(error: error)
        }
        loginLoading = false
    }
    
    /// Sends a reset password link to the inputted email address.
    func resetPassword() async {
        do {
            try emptyInputFieldCheck(checkPassword: false)
            try await AuthenticationService.shared.resetPassword(email: resetEmail)
            passwordResetSent = true
        } catch {
            self.error = mapToSPError(error: error)
        }
    }
    
    /// Validates that the email and password textfields are not empty,
    ///
    /// - Parameters:
    ///  - checkPassword: Boolean that indicates whether to validate the password input field.
    ///
    /// - Throws: An error mapped to an SPError object that specifies the error.
    ///
    func emptyInputFieldCheck(checkPassword: Bool) throws {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AuthError.emptyEmail
        }
        
        if checkPassword {
            guard !password.trimmingCharacters(in: .whitespaces).isEmpty else {
                throw AuthError.emptyPassword
            }
        }
    }
}
