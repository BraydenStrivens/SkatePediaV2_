//
//  TrickListCellBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/13/26.
//

import Foundation

/// Builder responsible for constructing a Trick List cell.
///
/// Handles the creation of `TrickListCell` and its associated view model,
/// ensuring required dependencies are properly injected for each cell.
@MainActor
struct TrickListCellBuilder {
    
    /// Builds a `TrickListCell` with its required dependencies.
    ///
    /// - Parameters:
    ///   - userId: The ID of the current user.
    ///   - trick: The trick represented by this cell.
    ///   - appEnv: Class containing global stores and services.
    ///   - errorStore: Store used for presenting errors.
    ///
    /// - Returns: A fully configured `TrickListCell`.
    static func build(
        userId: String,
        trick: Trick,
        appEnv: AppEnvironment,
        errorStore: ErrorStore
    ) -> TrickListCell {
        
        let viewModel = TrickListCellViewModel(
            appEnv: appEnv,
            errorStore: errorStore
        )
        return TrickListCell(
            userId: userId,
            trick: trick,
            viewModel: viewModel
        )
    }
}
