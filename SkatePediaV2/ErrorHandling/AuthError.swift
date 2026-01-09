//
//  AuthError.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/4/26.
//

import Foundation
import FirebaseAuth

enum AuthError: LocalizedError {
    // Errors thrown locally
    case emptyEmail
    case emptyPassword
    case emptyUsername
    case invalidUsername

    // Errors thrown from firebase
    case invalidEmail
    case wrongPassword
    case invalidCredential
    case userNotFound
    case userDisabled
    case emailAlreadyInUse
    case requiresRecentLogin
    case networkError
    case tooManyRequests
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .emptyEmail:
            return "Please enter an email address."
        case .emptyPassword:
            return "Please enter a password."
        case .emptyUsername:
            return "Please enter a username."
        case .invalidUsername:
            return "Username length is limited to 15 characters."
            
        case .invalidEmail:
            return "Email is formatted incorrectly."
        case .wrongPassword:
            return "Incorrect password."
        case .invalidCredential:
            return "Incorrect email or password."
        case .userNotFound:
            return "No account found with the inputted email address."
        case .userDisabled:
            return "The account registered with the inputted email has been disabled."
        case .emailAlreadyInUse:
            return "The inputted email address is already registered with an account."
        case .requiresRecentLogin:
            return "Sensitive operations require the user to have recently logged in."
        case .networkError:
            return "No internet connection. Please try again."
        case .tooManyRequests:
            return "Too many login attempts. Please try again later."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
    
    static func mapFirebaseError(_ error: Error) -> AuthError {
        let nsError = error as NSError
        
        guard nsError.domain == AuthErrorDomain, let code = AuthErrorCode(rawValue: nsError.code) else {
            return .unknown
        }
        
        switch code {
            
        case .invalidEmail:
            return .invalidEmail
        case .wrongPassword:
            return .wrongPassword
        case .invalidCredential:
            return .invalidCredential
        case .userNotFound:
            return .userNotFound
        case .userDisabled:
            return .userDisabled
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .requiresRecentLogin:
            return .requiresRecentLogin
        case .networkError:
            return .networkError
        case .tooManyRequests:
            return .tooManyRequests
        default:
            return .unknown
        }
    }
}
