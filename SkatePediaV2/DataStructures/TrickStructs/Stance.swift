//
//  Stance.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import Foundation

struct Stance: Identifiable, Codable {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case stance = "stance"
        case items = "items"
    }
    
    enum Stances: String, CaseIterable, Identifiable {
        case regular = "Regular"
        case fakie = "Fakie"
        case _switch = "Switch"
        case nollie = "Nollie"
        
        var id: String { self.rawValue }
    }
    
    let id = UUID().uuidString
    var stance: String
    var items: [JsonTrick]
}


