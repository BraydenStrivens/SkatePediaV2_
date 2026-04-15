//
//  AddTrickItemBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/11/26.
//

import Foundation

/// Builder responsible for constructing the Add Trick Item feature.
///
/// Encapsulates the creation of `AddTrickItemView` along with its required
/// dependencies, ensuring the view model is properly initialized and injected.
@MainActor
struct AddTrickItemBuilder {
    
    /// Builder responsible for constructing the Add Trick Item feature.
    ///
    /// Encapsulates the creation of `AddTrickItemView` along with its required
    /// dependencies, ensuring the view model is properly initialized and injected.
    static func build(
        userId: String,
        trick: Trick,
        trickItemStore: TrickItemStore
    ) -> AddTrickItemView {
        
        let viewModel = AddTrickItemViewModel(trickItemStore: trickItemStore)
        return AddTrickItemView(userId: userId, trick: trick, viewModel: viewModel)
    }
}
