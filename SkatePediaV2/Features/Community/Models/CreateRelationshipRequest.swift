//
//  AddFriendRequest.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/7/26.
//

import Foundation

struct CreateRelationshipRequest {
    let initiatedByUid: String
    let otherUid: String
    let userDataSnapshots: [String: UserData]
    let status: RelationshipStatus
}
