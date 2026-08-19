//
//  Report.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/6/26.
//

import Foundation

struct Report: Identifiable, Codable {
    let reportId: String
    let reporterUid: String
    let reporteeUid: String
    let reportType: ReportType
    let reportReason: ReportReason
    let reportStatus: ReportStatus
    let dateCreated: Date
    
    let additionalContext: String?
    let reportedUserData: ReportedUserData?
    let reportedPostData: ReportedPostData?
    let reportedCommentData: ReportedCommentData?
    
    let dateReviewed: Date?
    let moderationAction: ModerationAction?
    
    var id: String { self.reportId }
    
    enum CodingKeys: String, CodingKey {
        case reportId = "report_id"
        case reporterUid = "reporter_uid"
        case reporteeUid = "reportee_uid"
        case reportType = "report_type"
        case reportReason = "report_reason"
        case reportStatus = "report_status"
        case dateCreated = "date_created"
        
        case additionalContext = "additional_context"
        case reportedUserData = "reported_user_data"
        case reportedPostData = "reported_post_data"
        case reportedCommentData = "reported_comment_data"
        
        case dateReviewed = "date_reviewed"
        case moderationAction = "moderation_action"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.reportId = try container.decode(String.self, forKey: .reportId)
        self.reporterUid = try container.decode(String.self, forKey: .reporterUid)
        self.reporteeUid = try container.decode(String.self, forKey: .reporteeUid)
        self.reportType = try container.decode(ReportType.self, forKey: .reportType)
        self.reportReason = try container.decode(ReportReason.self, forKey: .reportReason)
        self.reportStatus = try container.decode(ReportStatus.self, forKey: .reportStatus)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        
        self.additionalContext = try container.decodeIfPresent(String.self, forKey: .additionalContext)
        self.reportedUserData = try container.decodeIfPresent(ReportedUserData.self, forKey: .reportedUserData)
        self.reportedPostData = try container.decodeIfPresent(ReportedPostData.self, forKey: .reportedPostData)
        self.reportedCommentData = try container.decodeIfPresent(ReportedCommentData.self, forKey: .reportedCommentData)
        
        self.dateReviewed = try container.decodeIfPresent(Date.self, forKey: .dateReviewed)
        self.moderationAction = try container.decodeIfPresent(ModerationAction.self, forKey: .moderationAction)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.reportId, forKey: .reportId)
        try container.encode(self.reporterUid, forKey: .reporterUid)
        try container.encode(self.reporteeUid, forKey: .reporteeUid)
        try container.encode(self.reportType, forKey: .reportType)
        try container.encode(self.reportReason, forKey: .reportReason)
        try container.encode(self.reportStatus, forKey: .reportStatus)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        
        try container.encodeIfPresent(self.additionalContext, forKey: .additionalContext)
        try container.encodeIfPresent(self.reportedUserData, forKey: .reportedUserData)
        try container.encodeIfPresent(self.reportedPostData, forKey: .reportedPostData)
        try container.encodeIfPresent(self.reportedCommentData, forKey: .reportedCommentData)
        
        try container.encodeIfPresent(self.dateReviewed, forKey: .dateReviewed)
        try container.encodeIfPresent(self.moderationAction, forKey: .moderationAction)
    }
}
