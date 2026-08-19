//
//  ProBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/29/26.
//

import Foundation

/// Builds and configures the `ProsView` along with its dependencies.
///
/// This struct is responsible for creating the `ProsViewModel`
/// and injecting it into the `ProsView`. 
struct ProBuilder {
    
    /// Creates a fully configured `ProsView`.
    ///
    /// - Parameters:
    ///   - appEnv: Class containing global stores and services.
    ///
    /// - Returns: A configured `ProsView` instance.
    static func build(
        appEnv: AppEnvironment
    ) -> ProsView {
        
        let viewModel = ProsViewModel(appEnv: appEnv)
        
        return ProsView(viewModel: viewModel)
    }
}
