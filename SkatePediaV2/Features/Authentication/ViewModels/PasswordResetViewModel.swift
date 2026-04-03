//
//  PasswordResetViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/2/26.
//

import Foundation

/// View model responsible for handling password reset requests.
///
/// Manages email input, triggers reset actions via `AuthenticationService`,
/// and exposes success or error messages for the UI.
///
/// - Parameters:
///   - authService: Service responsible for authentication actions.
final class PasswordResetViewModel: ObservableObject {
    @Published var resetEmail: String = ""

    @Published var errorMessage: String = ""
    @Published var successMessage: String = ""
    
    let authService: AuthenticationService
    
    init(authService: AuthenticationService = .shared) {
        self.authService = authService
    }
    
    /// Attempts to send a password reset email to the provided address.
    ///
    /// Validates the email input and calls `AuthenticationService` to
    /// initiate the reset process.
    ///
    /// - Important: Errors are mapped and exposed through `errorMessage`.
    @MainActor
    func resetPassword() async {
        do {
            guard !resetEmail.trimmingCharacters(in: .whitespaces).isEmpty else {
                throw AuthError.emptyEmail
            }
            
            try await authService.resetPassword(email: resetEmail)
            successMessage = "Sent!"
            
        } catch {
            let spError = mapToSPError(error: error)
            errorMessage = spError.errorDescription ?? "Something went wrong..."
        }
    }
}
