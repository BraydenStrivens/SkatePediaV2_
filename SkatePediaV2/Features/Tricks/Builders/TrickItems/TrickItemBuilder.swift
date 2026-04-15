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
    ///   - errorStore: Store used for presenting errors.
    ///   - trickItemStore: Store managing trick item data.
    ///   - postStore: Store managing posts related to the trick item.
    ///   - trickListStore: Store managing the broader trick list state.
    ///
    /// - Returns: A fully configured `TrickItemView`.
    static func build(
        userId: String,
        trick: Trick,
        trickItem: TrickItem,
        errorStore: ErrorStore,
        trickItemStore: TrickItemStore,
        postStore: PostStore,
        trickListStore: TrickListStore
        
    ) -> TrickItemView {
        let viewModel = TrickItemViewModel(
            trickItem: trickItem,
            errorStore: errorStore,
            trickItemStore: trickItemStore,
            postStore: postStore,
            trickListStore: trickListStore
        )
        
        return TrickItemView(
            userId: userId,
            trickItem: trickItem,
            trick: trick,
            viewModel: viewModel
        )
    }
}
