//
//  OverlayManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/4/26.
//

import Foundation
import SwiftUI

final class OverlayManager: ObservableObject {
    @Published private(set) var overlays: [OverlayItem] = []
    
    func present<Content: View>(
        level: OverlayLevel,
        blocksInteraction: Bool = true,
        @ViewBuilder content: @escaping (UUID) -> Content
    ) -> UUID {
        let id = UUID()
        
        let item = OverlayItem(
            id: id,
            level: level,
            blocksInteraction: blocksInteraction,
            content: AnyView(content(id))
        )
        
        overlays.append(item)
        sort()
        
        return id
    }
    
    func dismiss(id: UUID) {
        overlays.removeAll { $0.id == id }
    }
    
    func dismissAll(level: OverlayLevel? = nil) {
        if let level {
            overlays.removeAll(where: { $0.level == level })
        } else {
            overlays.removeAll()
        }
    }
    
    private func sort() {
        overlays.sort { $0.level < $1.level }
    }
}
