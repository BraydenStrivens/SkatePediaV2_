//
//  TrickItemProgressCounts.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/8/26.
//

import Foundation

struct TrickItemProgressCounts: Codable, Identifiable, Hashable {
    var num0s: Int
    var num1s: Int
    var num2s: Int
    var num3s: Int
    
    var id: String { "0s:\(num0s).1s:\(num1s).2s:\(num2s).3s:\(num3s)" }
    
    var highestRating: Int? {
        [3,2,1,0].first(where: { self[$0] > 0 })
    }
    
    init() {
        self.num0s = 0
        self.num1s = 0
        self.num2s = 0
        self.num3s = 0
    }
    
    init(progressArray: [Int]) {
        self.num0s = progressArray.count(where: { $0 == 0 })
        self.num1s = progressArray.count(where: { $0 == 1 })
        self.num2s = progressArray.count(where: { $0 == 2 })
        self.num3s = progressArray.count(where: { $0 == 3 })
    }
    
    enum CodingKeys: String, CodingKey {
        case num0s = "0"
        case num1s = "1"
        case num2s = "2"
        case num3s = "3"
    }
    
    private subscript(rating: Int) -> Int {
        get {
            switch rating {
            case 0: return num0s
            case 1: return num1s
            case 2: return num2s
            case 3: return num3s
            default: return 0
            }
        }
        set {
            switch rating {
            case 0: num0s = newValue
            case 1: num1s = newValue
            case 2: num2s = newValue
            case 3: num3s = newValue
            default: break
            }
        }
    }
    
    func asPayload() -> [String : Any] {
        return [
            CodingKeys.num0s.rawValue: num0s,
            CodingKeys.num1s.rawValue: num1s,
            CodingKeys.num2s.rawValue: num2s,
            CodingKeys.num3s.rawValue: num3s
        ]
    }
    
    mutating func updateCount(for rating: Int, increment: Bool) {
        guard (0...3).contains(rating) else { return }
        let delta = increment ? 1 : -1
        self[rating] = max(0, self[rating] + delta)
    }
    
    mutating func replace(old: Int, with new: Int) {
        guard (0...3).contains(old),
              (0...3).contains(new),
              old != new else { return }
        
        updateCount(for: old, increment: false)
        updateCount(for: new, increment: true)
    }
    
//    mutating func updateCount(key: Int, increment: Bool) {
//        let value = increment ? 1 : -1
//        if key == 0 { self.num0s = max(0, num0s + value) }
//        else if key == 1 { self.num1s = max(0, num1s + value) }
//        else if key == 2 { self.num2s = max(0, num2s + value) }
//        else if key == 3 { self.num3s = max(0, num3s + value) }
//    }
//    
//    mutating func replaceCounter(key1: Int, with key2: Int) {
//        guard key1 != key2 else { return }
//        
//        if key1 == 0 { self.num0s = max(0, num0s - 1) }
//        else if key1 == 1 { self.num1s = max(0, num1s - 1) }
//        else if key1 == 2 { self.num2s = max(0, num2s - 1) }
//        else if key1 == 3 { self.num3s = max(0, num3s - 1) }
//        
//        if key2 == 0 { self.num0s += 1 }
//        else if key2 == 1 { self.num1s += 1 }
//        else if key2 == 2 { self.num2s += 1 }
//        else if key2 == 3 { self.num3s += 1 }
//    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.num0s = try container.decode(Int.self, forKey: .num0s)
        self.num1s = try container.decode(Int.self, forKey: .num1s)
        self.num2s = try container.decode(Int.self, forKey: .num2s)
        self.num3s = try container.decode(Int.self, forKey: .num3s)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.num0s, forKey: .num0s)
        try container.encode(self.num1s, forKey: .num1s)
        try container.encode(self.num2s, forKey: .num2s)
        try container.encode(self.num3s, forKey: .num3s)
    }
    
    static func ==(lhs: TrickItemProgressCounts, rhs: TrickItemProgressCounts) -> Bool {
        return lhs.id == rhs.id
    }
}
