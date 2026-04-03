//
//  Tabbar.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/2/26.
//

import Foundation
import SwiftUI



struct TabbarAware: ViewModifier {
    @Environment(\.tabbarHeight) var tabbarHeight
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, tabbarHeight)
    }
}

extension View {
    func tabbarAware() -> some View {
        self.modifier(TabbarAware())
    }
}
