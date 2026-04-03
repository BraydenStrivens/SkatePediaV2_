//
//  LoginBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/2/26.
//

import Foundation

/// Responsible for building a `LoginView` with its dependencies injected.
///
/// Encapsulates view model creation so that views receive properly initialized dependencies.
@MainActor
struct LoginBuilder {
    /// Creates a `LoginViewModel` with injected dependencies and returns a `LoginView`.
    ///
    /// - Parameters:
    ///   - errorStore: Used to present errors to the user.
    ///
    /// - Returns: A `LoginView` initialized with a dependency-injected `LoginViewModel`.
    static func build(errorStore: ErrorStore) -> LoginView {
        let viewModel = LoginViewModel(errorStore: errorStore)
        return LoginView(viewModel: viewModel)
    }
}
