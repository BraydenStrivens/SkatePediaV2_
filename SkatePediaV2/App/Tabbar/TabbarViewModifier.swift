//
//  TabbarViewModifier.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/2/26.
//

import Foundation
import SwiftUI

/// A view modifier that applies bottom padding equal to the app's tab bar height.
///
/// Ensures content is not obscured by a tab bar.
struct TabbarAware: ViewModifier {
    @Environment(\.tabbarHeight) var tabbarHeight
    @StateObject private var keyboard = KeyboardObserver()
    
    func body(content: Content) -> some View {
        content
//            .padding(.bottom, keyboard.height == 0 ? tabbarHeight : 0)
            .padding(.bottom, tabbarHeight)
    }
}

/// Convenience method to apply the `TabbarAware` modifier to any view.
extension View {
    func tabbarAware() -> some View {
        self.modifier(TabbarAware())
    }
}
