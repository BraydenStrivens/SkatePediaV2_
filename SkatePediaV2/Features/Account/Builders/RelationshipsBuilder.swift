//
//  FriendsListBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/3/26.
//

import Foundation

/// Builds and configures the `RelationshipsView` along with its dependencies.
///
/// This struct is responsible for creating the `RelationshipsViewModel`
/// and injecting it into the `RelationshipsView`. It centralizes the
/// initialization logic to keep view construction clean and consistent.
struct RelationshipsBuilder {
    
    /// Creates a fully configured `RelationshipsView`.
    ///
    /// - Parameters:
    ///   - userId: The unique identifier of the user whose friends list will be displayed.
    ///   - appEnv: Class containing global stores and services.
    ///   - errorStore: The shared error store used for handling and presenting errors.

    /// - Returns: A configured `RelationshipsView` instance.
    @MainActor
    static func build(
        user: User,
        appEnv: AppEnvironment,
        errorStore: ErrorStore
    ) -> RelationshipsView {
        
        let viewModel = RelationshipsViewModel(
            errorStore: errorStore,
            appEnv: appEnv
        )
        
        return RelationshipsView(
            user: user,
            viewModel: viewModel
        )
    }
}
