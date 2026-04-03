//
//  RegisterBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/2/26.
//

import Foundation

/// Responsible for building a `RegisterView` with its dependencies injected.
///
/// Encapsulates view model creation so that views receive properly initialized dependencies.
@MainActor
struct RegisterBuilder {
    /// Creates a `RegisterViewModel` with injected dependencies and returns a `RegisterView`.
    ///
    /// - Parameters:
    ///   - errorStore: Used to present errors to the user.
    ///
    /// - Returns: A `RegisterView` initialized with a dependency-injected `RegisterViewModel`.
    static func build(errorStore: ErrorStore) -> RegisterView {
        let viewModel = RegisterViewModel(errorStore: errorStore)
        return RegisterView(viewModel: viewModel)
    }
}
