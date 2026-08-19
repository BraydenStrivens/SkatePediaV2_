//
//  SPVideoPlayerConstants.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/25/26.
//

import Foundation
import SwiftUI

class SPVideoPlayerConstants {
    let playbackSpeeds: [Float] = [0.1, 0.25, 0.5, 1.0]
    let seekIntervals: [CGFloat] = [0.03, 0.05, 0.1, 0.3]
    
    let seekerBackground = Color(red: 55/255, green: 55/255, blue: 55/255)
    let progressBackground = Color(red: 155/255, green: 155/255, blue: 155/255)
    
    let idleColor = Color.primary.opacity(0.15)
    let activeColor = Color.primary.opacity(0.05)
}
