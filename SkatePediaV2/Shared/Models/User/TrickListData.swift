//
//  TrickListData.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/2/26.
//

import Foundation

struct TrickListData: Codable, Identifiable, Hashable {
    let total: Int
    let totalLearned: Int
    let regularTotal: Int
    let regularLearned: Int
    let fakieTotal: Int
    let fakieLearned: Int
    let switchTotal: Int
    let switchLearned: Int
    let nollieTotal: Int
    let nollieLearned: Int
    
    var id: String {
        UUID().uuidString
    }
    
    init() {
        self.total = 100
        self.totalLearned = 0
        self.regularTotal = 25
        self.regularLearned = 0
        self.fakieTotal = 25
        self.fakieLearned = 0
        self.switchTotal = 25
        self.switchLearned = 0
        self.nollieTotal = 25
        self.nollieLearned = 0
    }
    
    enum CodingKeys: String, CodingKey {
        case total = "total"
        case totalLearned = "total_learned"
        case regularTotal = "regular_total"
        case regularLearned = "regular_learned"
        case fakieTotal = "fakie_total"
        case fakieLearned = "fakie_learned"
        case switchTotal = "switch_total"
        case switchLearned = "switch_learned"
        case nollieTotal = "nollie_total"
        case nollieLearned = "nollie_learned"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.total = try container.decode(Int.self, forKey: .total)
        self.totalLearned = try container.decode(Int.self, forKey: .totalLearned)
        self.regularTotal = try container.decode(Int.self, forKey: .regularTotal)
        self.regularLearned = try container.decode(Int.self, forKey: .regularLearned)
        self.fakieTotal = try container.decode(Int.self, forKey: .fakieTotal)
        self.fakieLearned = try container.decode(Int.self, forKey: .fakieLearned)
        self.switchTotal = try container.decode(Int.self, forKey: .switchTotal)
        self.switchLearned = try container.decode(Int.self, forKey: .switchLearned)
        self.nollieTotal = try container.decode(Int.self, forKey: .nollieTotal)
        self.nollieLearned = try container.decode(Int.self, forKey: .nollieLearned)

    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.total, forKey: .total)
        try container.encode(self.totalLearned, forKey: .totalLearned)
        try container.encode(self.regularTotal, forKey: .regularTotal)
        try container.encode(self.regularLearned, forKey: .regularLearned)
        try container.encode(self.fakieTotal, forKey: .fakieTotal)
        try container.encode(self.fakieLearned, forKey: .fakieLearned)
        try container.encode(self.switchTotal, forKey: .switchTotal)
        try container.encode(self.switchLearned, forKey: .switchLearned)
        try container.encode(self.nollieTotal, forKey: .nollieTotal)
        try container.encode(self.nollieLearned, forKey: .nollieLearned)
    }
    
    static func ==(lhs: TrickListData, rhs: TrickListData) -> Bool {
        return (
            lhs.total == rhs.total &&
            lhs.totalLearned == rhs.totalLearned &&
            lhs.regularTotal == rhs.regularTotal &&
            lhs.regularLearned == rhs.regularLearned &&
            lhs.fakieTotal == rhs.fakieTotal &&
            lhs.fakieLearned == rhs.fakieLearned &&
            lhs.switchTotal == rhs.switchTotal &&
            lhs.switchLearned == rhs.switchLearned &&
            lhs.nollieTotal == rhs.nollieTotal &&
            lhs.nollieLearned == rhs.nollieLearned
        )
    }
}
