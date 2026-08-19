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
    
    /// Builds the `AddTrickItemView` with its required dependencies.
    ///
    /// - Parameters:
    ///   - userId: The ID of the current user.
    ///   - trick: The parent trick associated with the trick item.
    ///   - appEnv: Class containing global stores and services.
    ///   - errorStore: Store used for presenting errors.
    ///
    /// - Returns: A fully configured `AddTrickItemView`.
    static func build(
        userId: String,
        trick: Trick,
        appEnv: AppEnvironment,
        errorStore: ErrorStore
    ) -> AddTrickItemView {
        
        let viewModel = AddTrickItemViewModel(
            appEnv: appEnv,
            errorStore: errorStore
        )
        return AddTrickItemView(
            userId: userId,
            trick: trick,
            viewModel: viewModel
        )
    }
}
