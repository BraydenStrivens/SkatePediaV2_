//
//  AccountViewTab.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/15/26.
//

import Foundation

enum AccountViewTab: String, Identifiable, CaseIterable {
    case Tricks
    case Posts
    var id: String { self.rawValue }
    
    static func ==(lhs: AccountViewTab, rhs: AccountViewTab) -> Bool {
        return lhs.id == rhs.id
    }
}
