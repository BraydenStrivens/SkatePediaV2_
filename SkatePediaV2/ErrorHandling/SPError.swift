//
//  SPError.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/12/26.
//

import Foundation

enum SPError: LocalizedError {
    case firestore(FirestoreError)
    case storage(StorageError)
    case auth(AuthError)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .firestore(let firestoreError):
            return firestoreError.errorDescription ?? "Something went wrong..."
            
        case .storage(let storageError):
            return storageError.errorDescription ?? "Something went wrong..."
            
        case .auth(let authError):
            return authError.errorDescription ?? "Something went wrong..."
            
        case .unknown:
            return "Error: Something went wrong."
        }
    }
}
