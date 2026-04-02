//
//  CommentSwipeAction.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/23/26.
//

import Foundation
import SwiftUI

enum CommentSwipeAction: Hashable {
    case delete
    case report
    
    var color: Color {
        switch self {
        case .delete: return .red
        case .report: return Color.button
        }
    }
    var text: String {
        switch self {
        case .delete: return "Delete"
        case .report: return "Report"
        }
    }
    var systemImage: String {
        switch self {
        case .delete: return "trash"
        case .report: return "exclamationmark.square"
        }
    }
}
