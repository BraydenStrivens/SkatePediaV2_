//
//  PlayerButtonStyle.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/9/26.
//

import Foundation
import SwiftUI

struct PlayerButtonStyle: ButtonStyle {
    let buttonSize: CGFloat
    let fontSize: CGFloat
    let idleButtonColor: Color
    let activeButtonColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
            .font(configuration.isPressed ? .system(size: fontSize * 0.9) : .system(size: fontSize))
            .fontWeight(.bold)
            .foregroundColor(configuration.isPressed ? .primary.opacity(0.8) : .primary)
            .padding(5)
            .frame(width: buttonSize, height: buttonSize)
            .background {
                Circle()
                    .fill(configuration.isPressed ? activeButtonColor : idleButtonColor)
            }
            
    }
}

extension View {
    func playerButtonStyle(buttonSize: CGFloat, fontSize: CGFloat, idleButtonColor: Color, activeButtonColor: Color) -> some View {
        buttonStyle(PlayerButtonStyle(buttonSize: buttonSize, fontSize: fontSize, idleButtonColor: idleButtonColor, activeButtonColor: activeButtonColor))
    }
}
