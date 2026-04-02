//
//  SettingsInfoManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/25/26.
//

import SwiftUI

final class SettingsInfoManager: ObservableObject {
    @Published var activeID: AnyHashable?
    @Published var activeDescription: String = ""
    @Published var frames: [AnyHashable: CGRect] = [:]
    
    func show(id: AnyHashable, description: String) {
        if activeID == id {
            activeID = nil
        } else {
            activeID = id
            activeDescription = description
        }
    }
    
    func hide() {
        activeID = nil
    }
    
    func isShown(id: AnyHashable) -> Bool {
        id == activeID
    }
}

//final class SettingsInfoManager<ID: Hashable>: ObservableObject {
//    @Published var activeID: ID?
//    @Published var activeDescription: String = ""
//    @Published var frames: [AnyHashable: CGRect] = [:]
//    
//    func show(id: ID, description: String) {
//        if activeID == id {
//            activeID = nil
//        } else {
//            activeID = id
//            activeDescription = description
//        }
//    }
//    
//    func hide() {
//        activeID = nil
//    }
//    
//    func isShown(id: ID) -> Bool {
//        id == activeID
//    }
//}
