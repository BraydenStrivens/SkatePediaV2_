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
struct TrickListSpinnerBuilder {
    
    /// Builds the `TrickListSpinnerView` with its required dependencies.
    ///
    /// - Parameters:
    ///   - appEnv: Class containing global stores and services.
    ///   - trickSpinnerPresetsVM: View model managing spinner preset configurations.
    ///
    /// - Returns: A fully configured `TrickListSpinnerView`.
    @MainActor
    static func build(
        appEnv: AppEnvironment,
        trickSpinnerPresetsVM: TrickSpinnerPresetsViewModel
    ) -> TrickListSpinnerView {
        
        let viewModel = TrickListSpinnerViewModel(
            appEnv: appEnv
        )
        return TrickListSpinnerView(
            viewModel: viewModel,
            trickSpinnerPresetsVM: trickSpinnerPresetsVM
        )
    }
}
