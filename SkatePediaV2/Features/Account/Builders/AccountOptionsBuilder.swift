//
//  ProfileOptionsBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/3/26.
//

import Foundation

/// Builds and configures the `AccountOptionsView` along with its dependencies.
///
/// This struct is responsible for creating the `AccountOptionsViewModel`
/// and injecting it into the `AccountOptionsView`. It centralizes the
/// initialization logic to keep view construction clean and consistent.
@MainActor
struct AccountOptionsBuilder {
    
    /// Creates a fully configured `AccountOptionsView`.
    ///
    /// - Parameters:
    ///   - user: The current user whose account options will be displayed.
    ///   - errorStore: The shared error store used for handling and presenting errors.
    /// - Returns: A configured `AccountOptionsView` instance.
    static func build(user: User, errorStore: ErrorStore) -> AccountOptionsView {
        let viewModel = AccountOptionsViewModel(user: user, errorStore: errorStore)
        return AccountOptionsView(user: user, viewModel: viewModel)
    }
}
