//
//  TrickBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/11/26.
//

import Foundation

/// Builder responsible for constructing the Trick feature.
///
/// Handles the creation of `TrickView` and its associated view model,
/// ensuring required dependencies are properly initialized and injected.
@MainActor
struct TrickBuilder {
    
    /// Builds the `TrickView` with its required dependencies.
    ///
    /// - Parameters:
    ///   - userId: The ID of the current user.
    ///   - trick: The trick being displayed.
    ///   - appEnv: Class containing global stores and services.
    ///
    /// - Returns: A fully configured `TrickView`.
    static func build(
        userId: String,
        trick: Trick,
        appEnv: AppEnvironment
    ) -> TrickView {
        
        let viewModel = TrickViewModel(
            appEnv: appEnv
        )
        return TrickView(
            userId: userId,
            trick: trick,
            viewModel: viewModel
        )
    }
}
