//
//  OnFirstAppearViewModifier.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 11/29/24.
//

import Foundation
import SwiftUI

struct OnFirstAppearViewModifier: ViewModifier {
    let perform: () -> Void
    @State private var hasAppeared: Bool = false

    func body(content: Content) -> some View {
        content
            .onAppear {
                if !self.hasAppeared {
                    self.hasAppeared = true
                    self.perform()
                }
            }
    }
}

extension View {
    func onFirstAppear(_ perform: @escaping () -> Void ) -> some View {
        return self.modifier(OnFirstAppearViewModifier(perform: perform))
    }
}
