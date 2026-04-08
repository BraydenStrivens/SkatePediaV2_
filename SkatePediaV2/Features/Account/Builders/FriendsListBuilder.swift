//
//  FriendsListBuilder.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/3/26.
//

import Foundation

/// Builds and configures the `FriendsListView` along with its dependencies.
///
/// This struct is responsible for creating the `FriendsListViewModel`
/// and injecting it into the `FriendsListView`. It centralizes the
/// initialization logic to keep view construction clean and consistent.
struct FriendsListBuilder {
    
    /// Creates a fully configured `FriendsListView`.
    ///
    /// - Parameters:
    ///   - userId: The unique identifier of the user whose friends list will be displayed.
    ///   - errorStore: The shared error store used for handling and presenting errors.
    /// - Returns: A configured `FriendsListView` instance.
    static func build(userId: String, errorStore: ErrorStore) -> FriendsListView {
        let viewModel = FriendsListViewModel(errorStore: errorStore)
        return FriendsListView(userId: userId, viewModel: viewModel)
    }
}
