//
//  RequestState.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/4/26.
//

import Foundation

enum RequestState {
    case idle
    case loading
    case success
    case failure(SPError)
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
