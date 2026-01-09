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
    @Published var email = ""
    @Published var password = ""
    @Published var resetEmail = ""
    @Published var error: AuthError?
    @Published var showErrorPopup = false

    ///
    /// Valids the login input fields contain characters and attempts to login in the user.
    ///
    /// - Throws: An error of type "LoginError" that specifies the error.
    func signIn() async throws {
        do {
            try emptyInputFieldCheck(email, password)
            
            try await AuthenticationService.shared.login(
                email: email,
                password: password
            )
        } catch {
            throw error
        }
    }
    
    ///
    /// Resets the users password with the email inputed into a text field
    ///
    func resetPassword() async throws {
        do {
            try emptyInputFieldCheck(resetEmail, "uselessValidPassword")
            try await AuthenticationService.shared.resetPassword(email: resetEmail)
        } catch {
            throw error
        }
    }
    
    ///
    /// Validates that the email and password textfields are not empty,
    ///
    /// - Throws: An error of type 'LoginError' that specifies the error.
    ///
    func emptyInputFieldCheck(_ email: String, _ password: String) throws {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AuthError.emptyEmail
        }
        
        guard !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw AuthError.emptyPassword
        }
    }
}
