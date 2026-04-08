//
//  AccountRoute.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/3/26.
//

import Foundation

/// This enum defines all possible routes that can be navigated to from
/// the account section of the app.
///
/// Supported destinations include:
/// - `friendsList`: Displays the user's friends list.
/// - `userPosts`: Shows posts created by the user.
/// - `userTricks`: Displays trick progresses associated with the user for a given stance.
/// - `accountOptions`: Opens the account options screen.
/// - `profileSettings`: Opens the profile settings screen.
/// - `trickItemSettings`: Opens trick related settings screen.
/// - `aboutSkatePedia`: Displays information about the app.
/// - `termsOfService`: Shows the terms of service.
/// - `privacyPolicy`: Shows the privacy policy.
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
