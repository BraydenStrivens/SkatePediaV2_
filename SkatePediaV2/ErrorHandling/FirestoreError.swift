//
//  FirestoreError.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/4/26.
//

import Foundation
import FirebaseFirestore

enum FirestoreError: LocalizedError {
    // Errors thrown locally
    case noDocument
    case decodingFailed
    
    // Errors thrown from firebase
    case cancelled
    case invalidArgument
    case deadlineExceeded
    case notFound
    case alreadyExists
    case permissionDenied
    case resourceExhausted
    case aborted
    case outOfRange
    case unimplemented
    case internalError
    case unavailable
    case dataLoss
    case unauthenticated
    case unknown
    
    case custom(String)
    
    var errorDescription: String? {
        switch self {
        case .noDocument:
            return "Error: Failed to find a matching document."
        case .decodingFailed:
            return "Error: Failed to decode the document."
        case .cancelled:
            return "Operation has been canceled."
        case .invalidArgument:
            return "Error: Invalid field name."
        case .deadlineExceeded:
            return "Error: Operation took too long to complete."
        case .notFound:
            return "Error: Failed to find the document in the database."
        case .alreadyExists:
            return "Error: The document being uploaded already exists in the database."
        case .permissionDenied:
            return "Error: The current user does not have permission to perform this operation."
        case .resourceExhausted:
            return "Error: Some resource has been exhausted. Please try again."
        case .aborted:
            return "Error: Operation was aborted. Please try again."
        case .outOfRange:
            return "Error: Operation was attempted past the valid range. Please try again."
        case .unimplemented:
            return "Error: Operation is not supported/enabled."
        case .internalError:
            return "Internal Error: Please try again."
        case .unavailable:
            return "Error: Service is currently unavailable. Please try again shortly."
        case .dataLoss:
            return "Error: Data has been lost/corrupted. Please try again."
        case .unauthenticated:
            return "Error: The request does not have valid authentication credentials for this operation."
        case .custom(let message):
            return message
        case .unknown:
            return "Error: Something went wrong. Please try again."
        }
    }
    
    static func mapFirebaseError(_ error: Error) -> FirestoreError {
        let nsError = error as NSError
        
        print(nsError)
        
        guard nsError.domain == FirestoreErrorDomain else {
            return .unknown
        }
        
        let code = FirestoreErrorCode(_nsError: nsError).code
        
        switch code {
        case .cancelled:
            return .cancelled
        case .invalidArgument:
            return .invalidArgument
        case .deadlineExceeded:
            return .deadlineExceeded
        case .notFound:
            return .notFound
        case .alreadyExists:
            return .alreadyExists
        case .permissionDenied:
            return .permissionDenied
        case .resourceExhausted:
            return .resourceExhausted
        case .aborted:
            return .aborted
        case .outOfRange:
            return .outOfRange
        case .unimplemented:
            return .unimplemented
        case .internal:
            return .internalError
        case .unavailable:
            return .unavailable
        case .dataLoss:
            return .dataLoss
        case .unauthenticated:
            return .unauthenticated
        default:
            return .unknown
        }
        
    }
}



