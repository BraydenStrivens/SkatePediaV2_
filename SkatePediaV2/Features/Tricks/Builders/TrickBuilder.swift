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
    ///   - trickItemStore: Store responsible for managing trick item data.
    ///
    /// - Returns: A fully configured `TrickView`.
    static func build(
        userId: String,
        trick: Trick,
        trickItemStore: TrickItemStore
    ) -> TrickView {
        
        let viewModel = TrickViewModel(trickItemStore: trickItemStore)
        return TrickView(userId: userId, trick: trick, viewModel: viewModel)
    }
}
