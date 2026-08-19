//
//  TrickItemBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/11/26.
//

import Foundation

/// Builder responsible for constructing the Trick Item feature.
///
/// Handles the creation of `TrickItemView` and its associated view model,
/// ensuring all required dependencies are properly injected.
@MainActor
struct TrickItemBuilder {
    
    /// Builds the `TrickItemView` with its required dependencies.
    ///
    /// - Parameters:
    ///   - userId: The ID of the current user.
    ///   - trick: The parent trick associated with the trick item.
    ///   - trickItem: The specific trick item being displayed.
    ///   - appEnv: Class containing global stores and services.
    ///   - errorStore: Store used for presenting errors.
    ///
    /// - Returns: A fully configured `TrickItemView`.
    static func build(
        userId: String,
        trick: Trick,
        trickItem: TrickItem,
        appEnv: AppEnvironment,
        errorStore: ErrorStore
    ) -> TrickItemView {
        
        let viewModel = TrickItemViewModel(
            trickItem: trickItem,
            appEnv: appEnv,
            errorStore: errorStore 
        )
        return TrickItemView(
            userId: userId,
            trickItem: trickItem,
            trick: trick,
            viewModel: viewModel
        )
    }
}
