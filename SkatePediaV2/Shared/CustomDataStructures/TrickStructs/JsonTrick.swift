//
//  JsonTrick.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/28/25.
//

import Foundation

struct JsonTrick: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var stance: String
    var abbreviation: String
    var learnFirst: String
    var learnFirstAbbreviation: String
    var difficulty: String
    
    static func ==(lhs: JsonTrick, rhs: JsonTrick) -> Bool {
        return lhs.id == rhs.id
    }
}
