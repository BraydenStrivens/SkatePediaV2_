//
//  AddTrickBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/13/26.
//

import Foundation


/// Builder responsible for constructing the Add Trick feature.
///
/// Encapsulates the creation of `AddTrickView` and its view model,
/// ensuring all required dependencies are properly initialized and injected.
@MainActor
struct AddTrickBuilder {
    
    /// Builds the `AddTrickView` with its required dependencies.
    ///
    /// - Parameters:
    ///   - userId: The ID of the current user creating the trick.
    ///   - stance: The stance associated with the trick being created.
    ///   - trickList: The existing list of tricks, used for validation or display.
    ///   - appEnv: Class containing global stores and services.
    ///   - errorStore: Store used for presenting errors.
    ///
    /// - Returns: A fully configured `AddTrickView`.
    static func build(
        userId: String,
        stance: TrickStance,
        trickList: [Trick],
        appEnv: AppEnvironment,
        errorStore: ErrorStore
    ) -> AddTrickView {
        
        let viewModel = AddTrickViewModel(
            appEnv: appEnv,
            errorStore: errorStore
        )
        return AddTrickView(
            userId: userId,
            stance: stance,
            trickList: trickList,
            viewModel: viewModel
        )
    }
}
