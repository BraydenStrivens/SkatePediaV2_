//
//  TrickProgressBadge.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/13/26.
//

import SwiftUI

/// A compact visual badge representing a trick completion or mastery rating.
///
/// `TrickProgressBadge` displays a stylized circular indicator based on the
/// provided `rating` value. Higher ratings include animated effects to emphasize
/// progress and completion.
///
/// Supported rating states:
/// - `0`: Outlined circle.
/// - `1`: Outlined circle with a center dot.
/// - `2`: Filled gradient badge with animated pulsing center.
/// - `3`: Fully completed badge with animated checkmark and ripple effects.
/// - `nil` No trick items uploaded, fallback to default circle outline.
///
/// The badge automatically adapts to the current color scheme for proper contrast.
///
/// - Important: Ratings `2` and `3` trigger continuous animations when the view appears.
struct TrickProgressBadge: View {
    
    // MARK: Environment
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: State
    @State private var animate = false

    // MARK: Parameters
    let rating: Int?
    
    // MARK: Derived Properties
    private var accent: Color {
        Color.button
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    accent.opacity(0.12),
                    lineWidth: 5
                )
            
            switch rating {
            case 0:
                Circle()
                    .stroke(
                        accent,
                        lineWidth: 3
                    )
                    .scaleEffect(0.92)
                
            case 1:
                Circle()
                    .stroke(
                        accent,
                        lineWidth: 3
                    )
                
                Circle()
                    .fill(accent.opacity(0.6))
                    .frame(width: 7, height: 7)
                
            case 2:
                rating2Badge

            case 3:
                rating3Badge
                
            default:
                Circle()
                    .stroke(
                        .primary,
                        style: StrokeStyle(lineWidth: 2)
                    )
            }
        }
        .frame(width: 20, height: 20)
        .onAppear {
            if [2, 3].contains(rating) {
                animate = true
            }
        }
    }
    
    // MARK: Subviews
    
    /// Animated badge used for rating level `2`.
    ///
    /// Displays a gradient-filled circular badge with a pulsing inner circle.
    private var rating2Badge: some View {
        ZStack {
            Circle()
                .stroke(
                    accent,
                    lineWidth: 3
                )
                .fill(
                    LinearGradient(
                        colors: [
                            accent.opacity(0.6),
                            accent
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Circle()
                .fill(colorScheme == .dark
                      ? Color(.systemGray5)
                      : .white
                )
                .frame(width: 7, height: 7)
                .scaleEffect(animate ? 1.2 : 0.9)
                .animation(
                    .easeOut(duration: 2.3)
                    .repeatForever(autoreverses: true),
                    value: animate
                )
        }
    }
    
    /// Fully animated completion badge used for rating level `3`.
    ///
    /// Displays a filled gradient badge with:
    /// - A spring-animated checkmark.
    /// - Expanding ripple rings.
    /// - A subtle scaling animation.
    ///
    /// - Important: This view continuously animates while visible.
    private var rating3Badge: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            accent.opacity(0.9),
                            accent
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.35),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(2)
            
            Image(systemName: "checkmark")
                .font(.system(size: 11, weight: .black))
                .foregroundStyle(.white)
                .scaleEffect(animate ? 1 : 0.8)
                .animation(
                    .spring(
                        response: 0.45,
                        dampingFraction: 0.45
                    )
                    .delay(0.15),
                    value: animate
                )
            
            Circle()
                .stroke(
                    accent.opacity(0.45),
                    lineWidth: 5
                )
                .scaleEffect(animate ? 1.4 : 1)
                .opacity(animate ? 0 : 0.55)
                .animation(
                    .easeInOut(duration: 1.6)
                    .repeatForever(autoreverses: false),
                    value: animate
                )
            
            Circle()
                .stroke(
                    accent.opacity(0.22),
                    lineWidth: 9
                )
                .scaleEffect(animate ? 1.6 : 1)
                .opacity(animate ? 0 : 0.3)
                .animation(
                    .easeOut(duration: 2.3)
                    .repeatForever(autoreverses: false)
                    .delay(0.4),
                    value: animate
                )
        }
        .scaleEffect(animate ? 1.1 : 0.9)
        .animation(
            .spring(
                response: 0.5,
                dampingFraction: 0.5
            ),
            value: animate
        )
    }
}
