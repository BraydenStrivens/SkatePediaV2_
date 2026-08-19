//
//  FriendState.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/20/26.
//

import Foundation

enum RelationshipStatus: String, Identifiable, CaseIterable, Codable {
    case accepted = "accepted"
    case pending = "pending"
    case declined = "declined"
    
    var id: String { self.rawValue }
    var camalCase: String {
        return self.rawValue.prefix(1).capitalized + self.rawValue.dropFirst()
    }
}
