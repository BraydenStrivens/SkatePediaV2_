//
//  ReportStatus.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/24/26.
//

import Foundation

enum ReportStatus: String, Codable {
    case pending
    case reviewed
    case actioned
    case dismissed
}
