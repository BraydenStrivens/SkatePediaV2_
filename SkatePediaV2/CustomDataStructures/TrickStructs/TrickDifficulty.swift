//
//  TrickDifficulty.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/4/26.
//

import Foundation

enum TrickDifficulty: String, Codable, CaseIterable, Identifiable {
    case beginner
    case intermediate
    case advanced
    
    var camalCase: String { return self.rawValue.prefix(1).capitalized + self.rawValue.dropFirst() }
    var id: String { return self.rawValue }
}
