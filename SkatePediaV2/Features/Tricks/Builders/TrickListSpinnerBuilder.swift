//
//  TrickListSpinnerBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/7/26.
//

import Foundation

/// Builder responsible for constructing the Trick List Spinner feature.
///
/// Creates and configures `TrickListSpinnerView` along with its internal view model,
/// ensuring required dependencies are properly injected.
@MainActor
struct TrickListSpinnerBuilder {
    
    /// Builds the `TrickListSpinnerView` with its required dependencies.
    ///
    /// - Parameters:
    ///   - trickListStore: Store managing trick list data used by the spinner.
    ///   - trickSpinnerPresetsVM: View model managing spinner preset configurations.
    ///
    /// - Returns: A fully configured `TrickListSpinnerView`.
    static func build(
        trickListStore: TrickListStore,
        trickSpinnerPresetsVM: TrickSpinnerPresetsViewModel
    ) -> TrickListSpinnerView {
        
        let viewModel = TrickListSpinnerViewModel(trickListStore: trickListStore)
        return TrickListSpinnerView(
            viewModel: viewModel,
            trickSpinnerPresetsVM: trickSpinnerPresetsVM
        )
    }
}
