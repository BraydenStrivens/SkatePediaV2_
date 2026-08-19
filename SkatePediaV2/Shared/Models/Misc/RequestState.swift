//
//  RequestState.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/4/26.
//

import Foundation

enum RequestState: Equatable {
    case idle
    case loading
    case success
    case failure(SPError)
    
    static func == (lhs: RequestState, rhs: RequestState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.loading, .loading): return true
        case (.success, .success): return true
        case (.failure, .failure): return true
        default: return false
        }
    }
}

extension RequestState {
    var error: SPError? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }
    
    var hasError: Bool {
        error != nil
    }
}
