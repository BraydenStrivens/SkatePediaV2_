//
//  DateExtension.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/14/26.
//

import Foundation

extension Date {
//    func timeAgoString() -> String {
//        let formatter = RelativeDateTimeFormatter()
//        formatter.unitsStyle = .abbreviated
//        return formatter.localizedString(for: self, relativeTo: Date())
//    }
    
//    func timeAgoString() -> String {
//        let calendar = Calendar.current
//        let now = Date()
//        let components = calendar.dateComponents(
//            [.minute, .hour, .day, .weekOfYear, .month, .year],
//            from: self,
//            to: now
//        )
//        
//        if let year = components.year, year > 0 {
//            return year == 1 ? "1 year ago" : "\(year) years ago"
//        }
//        if let month = components.month, month > 0 {
//            return month == 1 ? "1 month ago" : "\(month) months ago"
//        }
//        if let week = components.weekOfYear, week > 0 {
//            return week == 1 ? "1 week ago" : "\(week) weeks ago"
//        }
//        if let day = components.day, day > 0 {
//            return day == 1 ? "1 day ago" : "\(day) days ago"
//        }
//        if let hour = components.hour, hour > 0 {
//            return hour == 1 ? "1 hour ago" : "\(hour) hours ago"
//        }
//        if let minute = components.minute, minute > 0 {
//            return minute == 1 ? "1 minute ago" : "\(minute) minutes ago"
//        }
//        
//        return "Just now"
//    }
    
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
