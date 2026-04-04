//
//  AccountRouter.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/3/26.
//

import Foundation
import SwiftUI

/// Manages the navigation path for the account tab flow.
///
/// Provides functions to push, pop, and reset routes within the account navigation stack.
final class AccountRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    /// Adds a route to the account navigation path.
    ///
    /// - Parameters:
    ///   - route: An `AccountRoute` representing the destination view.
    func push(_ route: AccountRoute) {
        path.append(route)
    }
    
    /// Removes the last route from the account navigation path.
    func pop() {
        path.removeLast()
    }
    
    /// Resets the navigation path to the root, typically returning to `CurrentUserAccountView`.
    func reset() {
        path = NavigationPath()
    }
}
