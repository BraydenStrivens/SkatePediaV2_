//
//  DateFormat.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 11/20/24.
//

import Foundation

/// Formats a 'Data' object to DD/MM/YYYY form.
struct DateFormat {
    static let shared = DateFormatter()
    private init() { }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
