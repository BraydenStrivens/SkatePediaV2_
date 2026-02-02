//
//  StorageError.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/12/26.
//

import Foundation

enum StorageError: LocalizedError {
    case unknown
    
    var errorDescription: String? {
        return ""
    }
    
    static func mapFirebaseError(_ error: Error) -> StorageError {
        return .unknown
    }
}
