//
//  TabRouter.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/19/26.
//

import Foundation

/// Global router responsible for controlling tab bar navigation.
///
/// `TabRouter` provides a centralized way for any view or view model
/// to programmatically switch between root application tabs.
@MainActor
final class TabRouter: ObservableObject {

    /// Currently selected root tab.
    @Published var selectedTab: Tab = .tricks

    /// Navigates to the provided tab.
    ///
    /// - Parameter tab: The destination tab.
    func navigate(to tab: Tab) {
        selectedTab = tab
    }
}
