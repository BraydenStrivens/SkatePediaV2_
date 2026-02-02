//
//  FunctionError.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/31/26.
//

import Foundation
import FirebaseFunctions

enum CloudFunctionError: LocalizedError {
    case invalidArgument(message: String)
    case notFound(message: String)
    case alreadyExists(message: String)
    case internalError(message: String)
    case unknown(message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidArgument(let message): return message
        case .notFound(let message): return message
        case .alreadyExists(let message): return message
        case .internalError(let message): return message
        case .unknown(let message): return message
        }
    }
    
    static func mapFirebaseError(_ error: Error) -> CloudFunctionError {
        let nsError = error as NSError
        
        guard nsError.domain == FunctionsErrorDomain else {
            return .unknown(message: error.localizedDescription)
        }
        let code = FunctionsErrorCode(rawValue: nsError.code) ?? .unknown
        
        switch code {
        case .invalidArgument:
            return .invalidArgument(message: nsError.localizedDescription)
        case .notFound:
            return .notFound(message: nsError.localizedDescription)
        case .alreadyExists:
            return .alreadyExists(message: nsError.localizedDescription)
        case .internal:
            return .internalError(message: nsError.localizedDescription)
        default:
            return .unknown(message: "Unknown error...")
        }
    }
}
