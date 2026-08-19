//
//  Friend.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/27/25.
//

import Foundation
import Firebase

struct Relationship: Codable, Identifiable, Equatable {
    let id: String
    let userIds: [String]
    let initiatedByUid: String
    let userDataSnapshots: [String: UserData]
    let dateCreated: Date
    var dateUpdated: Date
    var status: RelationshipStatus
    
    var lastStatusChangedByUid: String?
    
    init(request: CreateRelationshipRequest) {
        self.id = [request.initiatedByUid, request.otherUid]
            .sorted().joined(separator: "_")
        self.userIds = [request.initiatedByUid, request.otherUid]
            .sorted()
        self.initiatedByUid = request.initiatedByUid
        self.userDataSnapshots = request.userDataSnapshots
        self.dateCreated = Date()
        self.dateUpdated = Date()
        self.status = request.status
        self.lastStatusChangedByUid = nil
    }
    
    func otherUid(currentUid: String) -> String {
        userIds.first { $0 != currentUid }!
    }
    
    func otherUserData(currentUid: String) -> UserData? {
        userDataSnapshots.first(where: { $0.key != currentUid })?.value
    }
    
    /// Defines the naming conventions for the 'users' document's fields in the database
    enum CodingKeys: String, CodingKey {
        case id = "relationship_id"
        case userIds = "user_ids"
        case initiatedByUid = "initiated_by_uid"
        case userDataSnapshots = "user_data_snapshots"
        case dateCreated = "date_created"
        case dateUpdated = "date_updated"
        case status = "status"
        case lastStatusChangedByUid = "last_status_changed_by_uid"
    }
    
    /// Defines a decoder to decode a 'users' document into a 'DBUser' object.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.userIds = try container.decode([String].self, forKey: .userIds)
        self.initiatedByUid = try container.decode(String.self, forKey: .initiatedByUid)
        self.userDataSnapshots = try container.decode([String: UserData].self, forKey: .userDataSnapshots)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.dateUpdated = try container.decode(Date.self, forKey: .dateUpdated)
        self.status = try container.decode(RelationshipStatus.self, forKey: .status)
        
        self.lastStatusChangedByUid = try container.decodeIfPresent(String.self, forKey: .lastStatusChangedByUid)
    }
    
    /// Defines an encoder to encode a 'DBUser' object into the 'users' document in the database.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.userIds, forKey: .userIds)
        try container.encode(self.initiatedByUid, forKey: .initiatedByUid)
        try container.encode(self.userDataSnapshots, forKey: .userDataSnapshots)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.dateUpdated, forKey: .dateUpdated)
        try container.encode(self.status, forKey: .status)
        
        try container.encodeIfPresent(self.lastStatusChangedByUid, forKey: .lastStatusChangedByUid)
    }
}
