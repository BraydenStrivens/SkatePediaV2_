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
    ///   - errorStore: Store used for presenting errors.
    ///   - trickListStore: Store responsible for managing trick list data.
    ///
    /// - Returns: A fully configured `TrickListCell`.
    static func build(
        userId: String,
        trick: Trick,
        errorStore: ErrorStore,
        trickListStore: TrickListStore
    ) -> TrickListCell {
        
        let viewModel = TrickListCellViewModel(
            trickListStore: trickListStore,
            errorStore: errorStore
        )
        return TrickListCell(
            userId: userId,
            trick: trick,
            viewModel: viewModel
        )
    }
}
