//
//  CMTimeExtension.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 11/30/24.
//

import SwiftUI
import AVKit

extension CMTime {
    
    /// Converts a CMTime object to a string in HH/MM/SS form
    ///
    /// - Returns: A formatted string representation of a data.
    func toTimeString() -> String {
        let roundedSeconds = seconds.rounded()
        let hours: Int = Int(roundedSeconds / 3600)
        let min: Int = Int(roundedSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let sec: Int = Int(roundedSeconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, min, sec)
        }
        
        if min > 0 {
            return String(format: "%02d:%02d", min, sec)
        }
        
        return String(format: "00:%02d", sec)
    }
}
