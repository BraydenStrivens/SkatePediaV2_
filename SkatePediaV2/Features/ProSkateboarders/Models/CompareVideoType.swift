//
//  CompareVideoType.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/17/26.
//

import Foundation

/// Represents the available video source categories that can be selected
/// during comparison workflows.
///
/// `CompareVideoType` is used to organize selectable comparison content into:
/// - User-uploaded trick items
/// - Professional skater videos
enum CompareVideoType: String, CaseIterable, Identifiable {
    case trickItem = "Trick Items"
    case proVideo = "Pro Videos"
    
    var id: String { self.rawValue }
}
