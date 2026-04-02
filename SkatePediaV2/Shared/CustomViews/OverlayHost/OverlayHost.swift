//
//  OverlayHost.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/4/26.
//

import SwiftUI

struct OverlayHost<Content: View>: View {
    
    @StateObject private var manager = OverlayManager()
    
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content
                .ignoresSafeArea(.keyboard)
                
            overlayLayer
        }
        .environmentObject(manager)
        .environmentObject(ErrorStore(overlayManager: manager))
    }
    
    @ViewBuilder
    private var overlayLayer: some View {
        ForEach(manager.overlays) { item in
            item.content
                .zIndex(Double(item.level.rawValue))
        }
    }
}
