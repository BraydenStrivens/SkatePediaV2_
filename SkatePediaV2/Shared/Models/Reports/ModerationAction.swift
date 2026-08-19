//
//  ModerationAction.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/24/26.
//

import Foundation

enum ModerationAction: String, Codable, Identifiable, CaseIterable {
    case ignored = "ignored"
    case warningIssued = "warning_issued"
    case itemDeleted = "item_deleted"
    case userBanned = "user_banned"
    
    var id: String { self.rawValue }
    var displayString: String {
        switch self {
        case .ignored:
            return "Ignore"
        case.warningIssued:
            return "Issue Warning"
        case .itemDeleted:
            return "Delete Item"
        case .userBanned:
            return "Ban User"
        }
    }
}
