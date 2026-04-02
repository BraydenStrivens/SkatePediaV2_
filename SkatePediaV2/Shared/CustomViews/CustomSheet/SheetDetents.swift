//
//  SheetDetents.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/4/26.
//

import Foundation

enum SheetDetent {
    case small
    case half
    case large
    case full
    
    func height(for screen: CGFloat) -> CGFloat {
        switch self {
        case .small: return screen * 0.3
        case .half: return screen * 0.5
        case .large: return screen * 0.7
        case .full: return screen * 0.85
        }
    }
}
