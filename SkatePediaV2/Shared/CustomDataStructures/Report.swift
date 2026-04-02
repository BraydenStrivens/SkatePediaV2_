//
//  Report.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/6/26.
//

import Foundation

enum ReportType: String, Codable {
    case post
    case comment
    case message
}

struct Report: Identifiable, Codable {
    let reportId: String
    let fromUserUid: String
    let reportType: ReportType
    let dateCreated: Date
    
    var id: String { self.reportId }
    
    enum CodingKeys: String, CodingKey {
        case reportId = "report_id"
        case fromUserUid = "from_user_uid"
        case reportType = "report_type"
        case dateCreated = "date_created"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.reportId = try container.decode(String.self, forKey: .reportId)
        self.fromUserUid = try container.decode(String.self, forKey: .fromUserUid)
        self.reportType = try container.decode(ReportType.self, forKey: .reportType)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.reportId, forKey: .reportId)
        try container.encode(self.fromUserUid, forKey: .fromUserUid)
        try container.encode(self.reportType, forKey: .reportType)
        try container.encode(self.dateCreated, forKey: .dateCreated)
    }
}
