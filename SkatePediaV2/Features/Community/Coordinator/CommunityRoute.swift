//
//  CommunityRoute.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/15/26.
//

import Foundation

enum CommunityRoute: Hashable {
    // User account flow
    case accountSearch(currentUser: User)
    case userAccount(currentUser: User, otherUser: User)
    case userTrickList(user: User, stance: TrickStance)
    case userPosts(user: User)
    
    case notifications(currentUser: User)
    
    // Upload post flow
    case selectTrick(user: User)
    case selectTrickItem(user: User, trick: Trick)
    case addPost(user: User, trick: Trick, trickItem: TrickItem)
}
