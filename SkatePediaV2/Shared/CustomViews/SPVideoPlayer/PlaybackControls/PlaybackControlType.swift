//
//  PlaybackControlType.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/27/26.
//

import Foundation

enum PlaybackControlType: String, Equatable {
    case none
    case simple
    case full
    
    var id: String { self.rawValue }
}
