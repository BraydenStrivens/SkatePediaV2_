//
//  SpinnerPreset.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/8/26.
//

import Foundation

/// A saved configuration for the Trick Spinner feature.
///
/// Represents a reusable preset that defines:
/// - A user-defined name
/// - A fixed set of tricks included in the spinner
///
/// Presets are used to quickly generate consistent spinner experiences
/// without manually selecting tricks each time.
///
/// - Important:
///   Each preset is uniquely identified by a generated UUID string at creation time.
struct SpinnerPreset: Codable, Identifiable, Equatable, Hashable {
    let id: String
    var name: String
    var trickIds: [String]
    
    init(
        name: String,
        trickIds: [String] = []
    ) {
        self.id = UUID().uuidString
        self.name = name
        self.trickIds = trickIds
    }
}
