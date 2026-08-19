//
//  ReportType.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/24/26.
//

import Foundation

enum ReportType: Codable, Identifiable {
    case post(Post)
    case comment(Comment)
    case profile
    
    var id: String {
        switch self {
        case .post(let post):
            "post"
        case .comment(let comment):
            "comment"
        case .profile:
            "profile"
        }
    }
    
    var rawValue: String {
        switch self {
        case .post(let post):
            "post"
        case .comment(let comment):
            "comment"
        case .profile:
            "profile"
        }
    }
    
    var camalCase: String {
        return self.id.prefix(1).capitalized + self.id.dropFirst()
    }
}
