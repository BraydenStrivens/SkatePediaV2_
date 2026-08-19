//
//  ReportReason.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/24/26.
//

import Foundation

enum ReportReason: String, Codable, CaseIterable, Identifiable {
    case spam = "spam"
    case harassment = "harassment"
    case threats = "threats"
    case explicitSexualContent = "explicit_sexual_content"
    case nudity = "nudity"
    case graphicViolence = "graphic_violence"
    case illegalContent = "illegal_content"
    case other = "other"
    
    var id: String { self.rawValue }
    
    var displayString: String {
        switch self {
        case .spam:
            return "Spam"
        case .harassment:
            return "Harassment"
        case .threats:
            return "Threats"
        case .explicitSexualContent:
            return "Explicit Sexual Content"
        case .nudity:
            return "Nudity"
        case .graphicViolence:
            return "Graphic Violence"
        case .illegalContent:
            return "Illegal Content"
        case .other:
            return "Other"
        }
    }
}
