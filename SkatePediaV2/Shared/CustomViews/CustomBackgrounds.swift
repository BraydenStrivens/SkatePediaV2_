//
//  CustomBackgrounds.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/6/26.
//

import SwiftUI

struct SPBackgrounds {
//    @Environment(\.colorScheme) private var colorScheme
    let colorScheme: ColorScheme
    let cornerRadius: CGFloat
    
    var outlined: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(colorScheme == .dark ? Color(.systemGray3) : Color(.systemGray4))
    }
    
    var inset: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(colorScheme == .dark
                  ? Color(.systemGray6).shadow(.inner(
                    color: .white.opacity(0.2), radius: 1, x: 0, y: -1)
                  )
                  : Color(.systemBackground).shadow(.inner(
                    color: .black.opacity(0.4), radius: 2, x: 0, y: 3)
                  )
            )
            .stroke(
                LinearGradient(
                    colors: [
                        .black.opacity(0.4),
                        .primary.opacity(colorScheme == .dark ? 0.2 : 0.08)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
    
    var protruded: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
            .stroke(
                LinearGradient(
                    colors: [
                        .primary.opacity(colorScheme == .dark ? 0.2 : 0),
                        .black.opacity(0.4)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .shadow(color: colorScheme == .dark
                    ? .clear
                    : .black.opacity(0.4), radius: 3, x: 0, y: 2
            )
    }
    
    func coloredProtruded(color: Color) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(color)
            .stroke(
                LinearGradient(
                    colors: [.white.opacity(0.4), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                ), lineWidth: 2
            )
            .shadow(color: colorScheme == .dark
                    ? .clear
                    : .black.opacity(0.4), radius: 3, y: 3
            )
    }
}

