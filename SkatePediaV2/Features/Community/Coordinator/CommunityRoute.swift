//
//  CommunityRoute.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/15/26.
//

import Foundation

enum CommunityRoute: Hashable {
    case accountSearch(currentUser: User)
    case userAccount(currentUser: User, otherUser: User)
    case notifications(currentUser: User)
    case userChats
    case userChat
    
    // Upload post flow
    case selectTrick(user: User)
    case selectTrickItem(user: User, trick: Trick)
    case addPost(user: User, trick: Trick, trickItem: TrickItem)
}
