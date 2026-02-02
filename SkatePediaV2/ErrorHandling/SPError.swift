//
//  SPError.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/12/26.
//

import Foundation
import Firebase
import FirebaseFunctions
import FirebaseStorage

enum SPError: LocalizedError {
    case firestore(FirestoreError)
    case function(CloudFunctionError)
    case storage(StorageError)
    case auth(AuthError)
    case custom(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .firestore(let firestoreError):
            return firestoreError.errorDescription ?? "Something went wrong..."
            
        case .function(let functionError):
            return functionError.errorDescription ?? "Something went wrong..."
            
        case .storage(let storageError):
            return storageError.errorDescription ?? "Something went wrong..."
            
        case .auth(let authError):
            return authError.errorDescription ?? "Something went wrong..."
            
        case .custom(let customErrorDescription):
            return customErrorDescription
            
        case .unknown:
            return "Error: Something went wrong."
        }
    }
}

/// Helper function to map any thrown error to an SPError
///
func mapToSPError(error: Error) -> SPError {
    print(error)
    // Maps manually thrown errors of each type, cloud function errors cant be manually thrown
    if let spError = error as? SPError {
        print("MANUAL SP ERROR")
        return spError
    }
    if let authError = error as? AuthError {
        print("MANUAL AUTH ERROR")
        return .auth(authError)
    }
    if let firestoreError = error as? FirestoreError {
        print("MANUAL FIRESTORE ERROR")
        return .firestore(firestoreError)
    }
    if let storageError = error as? StorageError {
        print("MANUAL STORAGE ERROR")
        return .storage(storageError)
    }
    
    // Converts firebase returned error to ns error to check its domain
    let nsError = error as NSError

    // Maps errors returned from a firebase request
    if nsError.domain == FirestoreErrorDomain {
        print("FIRESTORE ERROR")
        return .firestore(FirestoreError.mapFirebaseError(error))
    }
    if nsError.domain == FunctionsErrorDomain {
        print("CLOUD ERROR")
        return .function(CloudFunctionError.mapFirebaseError(error))
    }
    if nsError.domain == AuthErrorDomain {
        print("AUTH ERROR")
        return .auth(AuthError.mapFirebaseError(error))
    }
    if nsError.domain == StorageErrorDomain {
        print("STORAGE ERROR")
        return .storage(StorageError.mapFirebaseError(error))
    }
    
    return .unknown
}
