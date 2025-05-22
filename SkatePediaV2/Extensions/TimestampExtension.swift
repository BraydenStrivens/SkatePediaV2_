//
//  Timestamp.swift
//  ThreadsTutorial
//
//  Created by Brayden Strivens on 3/12/25.
//

import Foundation
import Firebase

extension Timestamp {
    func timeSinceUploadString() -> String {
        let formatter = DateComponentsFormatter()
        
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        
        return formatter.string(from: self.dateValue(), to: Date()) ?? ""
    }
    
    func dateString() -> String {
        let formatter = DateComponentsFormatter()
        
        formatter.allowedUnits = [.day, .month, .year]
        formatter.unitsStyle = .abbreviated
        
        return formatter.string(from: self.dateValue(), to: Date()) ?? ""
    }
    
    
}
