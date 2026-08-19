//
//  ProVideosListBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/29/26.
//

import Foundation

/// Builds and configures the `ProVideosListView` along with its dependencies.
///
/// This struct is responsible for creating the `ProVideosListViewModel`
/// and injecting it into the `ProVideosListView`.
struct ProVideosListBuilder {
    
    /// Creates a fully configured `ProVideoListView`.
    ///
    /// - Parameters:
    ///   - proSkater: The pro skaters whose videos are to be displayed.
    ///   - appEnv: Class containing global stores and services.
    ///
    /// - Returns: A configured `ProVideosListView` instance.
    @MainActor
    static func build(
        proSkater: ProSkater?,
        appEnv: AppEnvironment
    ) -> ProVideosListView {
        
        let viewModel = ProVideosListViewModel(
            appEnv: appEnv
        )
        
        return ProVideosListView(
            proSkater: proSkater,
            viewModel: viewModel
        )
    }
}
