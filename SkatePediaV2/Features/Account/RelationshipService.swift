//
//  RelationshipService.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/22/26.
//

import Foundation
import FirebaseFirestore
import FirebaseFunctions

final class RelationshipService {
    
    // MARK: Shared Instance
    static let shared = RelationshipService()
    private init() { }
    
    // MARK: Private Properties
    private let functions = Functions.functions()

    // MARK: Firestore References
    private let relationshipsCollection = Firestore.firestore()
        .collection("relationships")
    
    private func relationshipRef(
        _ uid1: String,
        _ uid2: String
    ) -> DocumentReference {
        let relationshipId = [uid1, uid2].sorted().joined(separator: "_")
        return relationshipsCollection.document(relationshipId)
    }
    
    private let userBlocksCollection = Firestore.firestore()
        .collection("user_blocks")
    
    
    private func blockedUsersCollection(
        _ userId: String
    ) -> CollectionReference {
        return userBlocksCollection
            .document(userId)
            .collection("blocked_users")
    }
    
    private func blockedUserRef(
        currentUid: String,
        blockedUid: String
    ) -> DocumentReference {
        return blockedUsersCollection(currentUid).document(blockedUid)
    }
    
    // MARK: Relationship Fetching
        
    func fetchRelationships(
        for userId: String,
        statusFilter: RelationshipStatus,
        count: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> (item: [Relationship], lastDocument: DocumentSnapshot?) {
        
        if statusFilter == .declined {
            return try await fetchDeclinedRelationshipRequests(
                for: userId,
                count: count,
                lastDocument: lastDocument
            )
        }
        
        return try await fetchAllRelationshipsByStatus(
            for: userId,
            statusFilter: statusFilter,
            count: count,
            lastDocument: lastDocument
        )
    }
    
    func fetchAllRelationshipsByStatus(
        for userId: String,
        statusFilter: RelationshipStatus,
        count: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> (item: [Relationship], lastDocument: DocumentSnapshot?) {
        return try await relationshipsCollection
            .whereField(Relationship.CodingKeys.userIds.rawValue, arrayContains: userId)
            .whereField(Relationship.CodingKeys.status.rawValue, isEqualTo: statusFilter.rawValue)
            .order(by: Relationship.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Relationship.self)
    }
    
    /// Declined relationships should only be viewable by the user who blocked or declined the other user.
    func fetchDeclinedRelationshipRequests(
        for userId: String,
        count: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> (item: [Relationship], lastDocument: DocumentSnapshot?) {
        return try await relationshipsCollection
            .whereField(Relationship.CodingKeys.status.rawValue, isEqualTo: RelationshipStatus.declined.rawValue)
            .whereField(Relationship.CodingKeys.lastStatusChangedByUid.rawValue, isEqualTo: userId)
            .whereField(Relationship.CodingKeys.userIds.rawValue, arrayContains: userId)
            .order(by: Relationship.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Relationship.self)
    }
    
    // MARK: Relationship Writing
    
    func createRelationship(
        otherUid: String
    ) async throws {
        let payload: [String: String] = [
            "receiver_uid": otherUid
        ]
        
        _ = try await functions
            .httpsCallable("createRelationship")
            .call(payload)
    }
    
    func updateRelationshipStatus(
        otherUid: String,
        with newStatus: RelationshipStatus
    ) async throws {
        let payload: [String: String] = [
            "other_uid": otherUid,
            "status": newStatus.rawValue
        ]
        
        _ = try await functions
            .httpsCallable("updateRelationship")
            .call(payload)
    }
    
    func removeRelationship(
        otherUid: String
    ) async throws {
        let payload: [String: String] = [
            "other_uid": otherUid
        ]
        
        _ = try await functions
            .httpsCallable("removeRelationship")
            .call(payload)
    }
        
    // MARK: Blocked User Fetching
    
    func fetchBlockedUsers(
        for userId: String,
        count: Int,
        lastDocument: DocumentSnapshot?
    ) async throws -> (item: [UserBlock], lastDocument: DocumentSnapshot?) {
        return try await blockedUsersCollection(userId)
            .limit(to: count)
            .order(by: UserBlock.CodingKeys.dateCreated.rawValue, descending: true)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: UserBlock.self)
    }
    
    // MARK: Blocked User Writing
    
    func blockUser(
        currentUid: String,
        otherUid: String
    ) async throws {
        let payload: [String: String] = [
            "to_block_uid": otherUid
        ]
        
        _ = try await functions
            .httpsCallable("blockUser")
            .call(payload)
    }
    
    func blockAndReportUser(
        currentUid: String,
        otherUid: String,
        reportReason: ReportReason,
        additionalContext: String? = nil
    ) async throws {
        try await reportUser(
            otherUid: otherUid,
            reportReason: reportReason,
            additionalContext: additionalContext
        )
        try await blockUser(currentUid: currentUid, otherUid: otherUid)
    }
    
    func unblockUser(
        currentUid: String,
        otherUid: String
    ) async throws {
        try await blockedUserRef(
            currentUid: currentUid,
            blockedUid: otherUid
        )
        .delete()
    }
    
    func reportUser(
        otherUid: String,
        reportReason: ReportReason,
        additionalContext: String? = nil
    ) async throws {
        
        let payload: [String: Any?] = [
            Report.CodingKeys.reporteeUid.rawValue: otherUid,
            Report.CodingKeys.reportReason.rawValue: reportReason.rawValue,
            Report.CodingKeys.reportType.rawValue: ReportType.profile.rawValue,
            Report.CodingKeys.additionalContext.rawValue: additionalContext
        ]
        
        _ = try await functions
            .httpsCallable("createReport")
            .call(payload)
    }
}
