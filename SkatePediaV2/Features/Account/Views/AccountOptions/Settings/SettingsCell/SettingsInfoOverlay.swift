//
//  SettingsInfoOverlay.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/25/26.
//

import SwiftUI

/// Provides a reusable overlay system for displaying contextual information about settings items.
///
/// This extension and supporting types allow any SwiftUI view to present an info overlay
/// when a "question mark" button is tapped in a settings row. The overlay automatically
/// positions itself above or below the triggering button depending on available space.
///
/// Usage:
/// ```swift
/// SomeView()
///     .settingsInfoOverlay()
/// ```
///
/// Components:
/// - `View.settingsInfoOverlay()`: Convenience view modifier to apply the overlay.
/// - `SettingsInfoOverlay`: The view modifier implementing the overlay logic.
/// - `InfoButtonFramePreferenceKey`: Tracks button positions to align the overlay correctly.
///
/// Behavior:
/// - Tapping a button calls `SettingsInfoManager.show(id:description:)` to display the overlay.
/// - Tapping outside the overlay dismisses it automatically.
/// - Overlay size and position adapt to screen size and button location.
extension View {
    func settingsInfoOverlay() -> some View {
        self.modifier(SettingsInfoOverlay())
    }
}

/// PreferenceKey used to store frames of info buttons in the settings screen.
struct InfoButtonFramePreferenceKey: PreferenceKey {
    static var defaultValue: [AnyHashable: CGRect] = [:]
    
    static func reduce(
        value: inout [AnyHashable: CGRect],
        nextValue: () -> [AnyHashable: CGRect]
    ) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

/// ViewModifier that displays an overlay with contextual information
/// for settings items when an info button is tapped.
struct SettingsInfoOverlay: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var manager = SettingsInfoManager()
    
    func body(content: Content) -> some View {
        GeometryReader { rootProxy in
            
            ZStack {
                content
                    .environmentObject(manager)
                    .coordinateSpace(name: "SettingsInfoSpace")
                    .onPreferenceChange(InfoButtonFramePreferenceKey.self) {
                        manager.frames = $0
                    }
                
                if let activeID = manager.activeID,
                   let buttonFrame = manager.frames[activeID] {
                    
                    overlayView(
                        rootSize: rootProxy.size,
                        buttonFrame: buttonFrame,
                        colorScheme: colorScheme
                    )
                }
            }
        }
    }
    
    @ViewBuilder
    private func overlayView(
        rootSize: CGSize,
        buttonFrame: CGRect,
        colorScheme: ColorScheme
    ) -> some View {
        
        let overlayWidth = min(rootSize.width * 0.65, 300)
        let overlayHeight: CGFloat = 120
        let verticalSpacing: CGFloat = 0
        let horizontalPadding: CGFloat = 16
        
        let xPosition = min(
            max(buttonFrame.midX, overlayWidth/2 + horizontalPadding),
            rootSize.width - overlayWidth/2 - horizontalPadding
        )
        
        let spaceBelow = rootSize.height - buttonFrame.maxY
        let showAbove = spaceBelow < overlayHeight + 40
        
        let yPosition = showAbove
            ? buttonFrame.minY - overlayHeight/2 - verticalSpacing
            : buttonFrame.maxY + overlayHeight/2 + verticalSpacing
        
        ZStack {
            Color.black.opacity(0.01)
                .ignoresSafeArea()
                .onTapGesture {
                    manager.hide()
                }
            
            VStack(alignment: .leading) {
                Text(manager.activeDescription)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .frame(width: overlayWidth)
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).protruded)
            .position(x: xPosition, y: yPosition)
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
            .animation(.easeInOut(duration: 0.18), value: manager.activeID)
        }
    }
}
