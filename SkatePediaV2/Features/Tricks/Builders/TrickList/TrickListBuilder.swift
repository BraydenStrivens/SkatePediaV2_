//
//  TrickListViewBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/7/26.
//

import Foundation

/// Builder responsible for constructing the Trick List feature.
///
/// Handles the creation of `TrickListView` and its associated view model,
/// ensuring required dependencies are properly injected.
@MainActor
struct TrickListBuilder {
    
    /// Builds the `TrickListView` with its required dependencies.
    ///
    /// - Parameters:
    ///   - user: The current authenticated user.
    ///   - appEnv: Class containing global stores and services.
    ///   - errorStore: Store used for presenting errors.
    ///
    /// - Returns: A fully configured `TrickListView`.
    static func build(
        user: User,
        appEnv: AppEnvironment,
        errorStore: ErrorStore
    ) -> TrickListView {
        
        let viewModel = TrickListViewModel(
            appEnv: appEnv,
            errorStore: errorStore
        )
        return TrickListView(
            user: user,
            viewModel: viewModel
        )
    }
}
