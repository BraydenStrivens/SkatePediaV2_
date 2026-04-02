//
//  CustomNavHeaderModifier.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/12/26.
//

import SwiftUI

struct CustomNavHeaderModifier: ViewModifier {
    
    let title: String
    let background: Color?
    let backButtonHidden: Bool
    let showDivider: Bool
    
    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarRole(.editor)
            .navigationBarBackButtonHidden(backButtonHidden)
            .applyNavBackground(background)
            .applyDivider(showDivider)
    }
}

private extension View {
    @ViewBuilder
    func applyNavBackground(_ background: Color?) -> some View {
        if let background {
            self
                .toolbarBackground(background, for: .navigationBar)
                .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            
        } else {
            self
                .toolbarBackground(.automatic, for: .navigationBar)
                .toolbarBackgroundVisibility(.automatic, for: .navigationBar)
        }
    }
    
    @ViewBuilder
    func applyDivider(_ show: Bool) -> some View {
        if show {
            self.safeAreaInset(edge: .top, spacing: 0) {
                Rectangle()
                    .fill(Color(.systemGray6))
                    .frame(height: 1)
            }
        } else {
            self
        }
    }
}

extension View {
    func customNavHeader(
        title: String,
        background: Color? = nil,
        backButtonHidden: Bool = false,
        showDivider: Bool = false
    ) -> some View {
        modifier(
            CustomNavHeaderModifier(
                title: title,
                background: background,
                backButtonHidden: backButtonHidden,
                showDivider: showDivider
            )
        )
    }
}

