//
//  StorageError.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/12/26.
//

import Foundation
import FirebaseStorage

enum StorageError: LocalizedError {
    case cancelled
    case quotaExceeded
    case unauthorized
    case objectNotFound
    case bucketNotFound
    case pathError
    case retryLimitExceeded
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Upload cancelled."
        case .quotaExceeded:
            return "You have exceeded your storage quota."
        case .unauthorized:
            return "You are not authorized to perform this operation."
        case .objectNotFound:
            return "The file could not be found."
        case .bucketNotFound:
            return "The storage bucket could not be found."
        case .pathError:
            return "Error occurred with the passed storage path."
        case .retryLimitExceeded:
            return "Upload failed after multiple attempts. Please try again."
        case .unknown:
            return "An unknown error occurred during upload."
        }
    }
    
    static func mapFirebaseError(_ error: Error) -> StorageError {
        let nsError = error as NSError
        
        guard nsError.domain == StorageErrorDomain,
                let code = StorageErrorCode(rawValue: nsError.code)
        else {
            return .unknown
        }
        
        switch code {
        case .cancelled:
            return .cancelled
        case .quotaExceeded:
            return .quotaExceeded
        case .unauthorized:
            return .unauthorized
        case .objectNotFound:
            return .objectNotFound
        case .bucketNotFound:
            return .bucketNotFound
        case .pathError:
            return .pathError
        case .retryLimitExceeded:
            return .retryLimitExceeded
        default:
            return .unknown
        }
        
        
    }
}
