//
//  DateExtension.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/14/26.
//

import Foundation

extension Date {
    func timeAgoString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
