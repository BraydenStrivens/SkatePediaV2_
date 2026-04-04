//
//  OverlayItem.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/4/26.
//

import Foundation
import SwiftUI

struct OverlayItem: Identifiable {
    let id: UUID
    let level: OverlayLevel
    let blocksInteraction: Bool
    let content: AnyView
}
