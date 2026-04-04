//
//  AccountRoute.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/3/26.
//

import Foundation

/// Represents the navigation destinations from the account tab's flow.
///
/// Currently supports:
/// - `friendsList`: Navigates to the friends list screen.enum AccountRoute: Hashable
/// - `profileOptions`: Navigates to the profile options screen.enum AccountRoute: Hashable
/// - `profileSettings`: Navigates to the profile settings screen.enum AccountRoute: Hashable
/// - `trickListSettings`: Navigates to the trick list settings screen.enum AccountRoute: Hashable

enum AccountRoute: Hashable {
    case friendsList
    case userPosts
    case userTricks(TrickStance)
    case accountOptions
    case profileSettings
    case trickItemSettings
    case aboutSkatePedia
    case termsOfService
    case privacyPolicy
}
