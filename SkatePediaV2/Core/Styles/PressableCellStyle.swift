//
//  PressableCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/14/26.
//

import SwiftUI

struct PressableCellStyle: ButtonStyle {
    
    var cornerRadius: CGFloat = 0
    var backgroundColor: Color = Color(.systemBackground)
    var pressedColor: Color = Color(.tertiarySystemFill)
    var pressedScale: CGFloat = 0.95
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        configuration.isPressed
                        ? pressedColor
                        : backgroundColor
                    )
            )
            .scaleEffect(
                configuration.isPressed
                ? pressedScale
                : 1
            )
            .transaction { transaction in
                if configuration.isPressed {
                    transaction.animation = nil
                } else {
                    transaction.animation = .smooth()
                }
            }
    }
}
