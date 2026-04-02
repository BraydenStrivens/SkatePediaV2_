//
//  DateExtension.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/14/26.
//

import Foundation

extension Date {
    func timeAgoString() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents(
            [.minute, .hour, .day, .weekOfYear, .month, .year],
            from: self,
            to: now
        )
        
        if let year = components.year, year > 0 {
            // mm/dd/yyyy
            return self.formatted(date: .numeric, time: .omitted)
        }
        if let month = components.month, month > 0 {
            // mm/dd
            return self.formatted(.dateTime.month(.twoDigits).day(.twoDigits))
        }
        if let week = components.weekOfYear, week > 0 {
            // Jan 1
            return self.formatted(.dateTime.month(.abbreviated).day())
        }
        if let day = components.day, day > 0 {
            return day == 1 ? "1 day ago" : "\(day) days ago"
        }
        if let minute = components.minute, minute > 0 {
            return minute == 1 ? "1 minute ago" : "\(minute) minutes ago"
        }
        
        return "Just now"
    }
    
    func dateFormatsPreview() -> String {
        return """
        \(self.formatted(date: .numeric, time: .omitted))
        \(self.formatted(.dateTime.month(.twoDigits).day(.twoDigits)))
        \(self.formatted(.dateTime.month(.abbreviated).day()))
        """
    }
}
