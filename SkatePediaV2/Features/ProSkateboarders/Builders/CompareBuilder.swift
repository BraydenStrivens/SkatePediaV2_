//
//  CompareBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/4/26.
//

import Foundation

/// Builds and configures the `CompareView` along with its dependencies.
///
/// This struct is responsible for creating the `CompareViewModel`
/// and injecting it into the `CompareView`. It supports optional inputs
/// such as a `TrickItem` or `ProSkaterVideo` to customize the comparison context.
struct CompareBuilder {
    
    /// Creates a fully configured `CompareView`.
    ///
    /// - Parameters:
    ///   - errorStore: The shared error store used for handling and presenting errors.
    ///   - trickData: The base trick data used for comparison.
    ///   - trickItem: An optional trick item whose video is used in the comparison
    ///   - proVideo: An optional professional skater video that is used for comparison.
    /// - Returns: A configured `CompareView` instance.
    static func build(
        errorStore: ErrorStore,
        trickData: TrickData,
        trickItem: TrickItem? = nil,
        proVideo: ProSkaterVideo? = nil
    ) -> CompareView {
        
        let viewModel = CompareViewModel(
            errorStore: errorStore,
            trickItem: trickItem,
            proVideo: proVideo
        )
        return CompareView(trickData: trickData, viewModel: viewModel)
    }
}
