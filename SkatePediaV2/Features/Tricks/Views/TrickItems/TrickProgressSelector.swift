//
//  TrickProgressSelector.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/8/26.
//

import SwiftUI

/// A horizontal progress selector used to represent trick consistency or mastery.
///
/// `TrickProgressSelector` displays an interactive progress bar with selectable
/// rating points ranging from `0` to `3`. Each rating level includes a descriptive
/// label explaining the user's current consistency with a trick.
///
/// The selector supports:
/// - Tap interaction on rating dots.
/// - Drag gestures for smooth rating selection.
/// - Animated progress updates.
/// - Read-only display mode.
///
/// - Parameters:
///   - rating: A binding to the currently selected rating value.
///   - isInteractive: Determines whether the selector responds to user interaction.
///     Defaults to `true`.
///
/// - Important: Expected rating values range from `0...3`.
struct TrickProgressSelector: View {
    
    // MARK: Environment
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: Parameters
    @Binding var rating: Int
    var isInteractive: Bool = true
    
    // MARK: Private Properties
    private let maxRating = 3
    private let dotSize: CGFloat = 15
    private static let labels: [Int : String] = [
        0: "Not even close",
        1: "Close but can't land",
        2: "Can land but inconsistent",
        3: "Clean & consistent"
    ]
    
    // MARK: Body
    var body: some View {
        VStack(spacing: 12) {
            Text(Self.labels[rating] ?? "")
                .foregroundStyle(.gray)
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            GeometryReader { proxy in
                let totalWidth = proxy.size.width
                let stepWidth = (totalWidth - dotSize) / CGFloat(maxRating)
                let progressWidth = stepWidth * CGFloat(rating)
                
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                        .padding(.horizontal, dotSize / 2)
                    
                    // Progress
                    LinearGradient(
                        colors: [.orange, Color.button, Color.yellow],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .mask(
                        HStack {
                            Capsule()
                                .frame(width: progressWidth, height: 8)
                            
                            Spacer(minLength: 0)
                        }
                    )
                    .frame(height: 8)
                    .padding(.horizontal, dotSize / 2)
                    
                    // Dots
                    HStack(spacing: 0) {
                        ForEach(0...maxRating, id: \.self) { index in
                            let selected = index <= rating
                            
                            Circle()
                                .fill(
                                    selected
                                    ? AnyShapeStyle(dotColor(for: index))
                                    : AnyShapeStyle(Color(colorScheme == .dark ? .systemGray4 : .systemGray6))
                                )
                                .frame(width: dotSize, height: dotSize)
                                .overlay {
                                    Circle()
                                        .stroke(
                                            selected
                                            ? Color.primary.opacity(0.1)
                                            : Color.gray.opacity(colorScheme == .dark ? 0.25 : 0.1),
                                            lineWidth: 1
                                        )
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    guard isInteractive else { return }
                                    
                                    withAnimation(.spring(duration: 0.25)) {
                                        rating = index
                                    }
                                }
                            
                            if index != maxRating {
                                Spacer()
                            }
                        }
                    }
                }
                .frame(height: dotSize)
                .gesture(
                    isInteractive
                    ? DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let x = min(
                                max(value.location.x - dotSize / 2, 0),
                                totalWidth - dotSize
                            )
                            let percentage = x / (totalWidth - dotSize)
                            
                            let newRating = Int(
                                round(percentage * CGFloat(maxRating))
                            )
                            
                            if newRating != rating {
                                withAnimation(.easeOut(duration: 0.1)) {
                                    rating = newRating
                                }
                            }
                        }
                    : nil
                )
            }
            .frame(height: dotSize)
        }
    }
    
    // MARK: Functions
    
    /// Calculates the display color for a progress dot based on its index.
    ///
    /// Colors are interpolated between orange and yellow to visually match
    /// the progress bar gradient.
    ///
    /// - Parameters:
    ///   - index: The index of the dot representing a rating value.
    ///
    /// - Returns: A color corresponding to the dot's relative position within the progress range.
    private func dotColor(for index: Int) -> Color {
        let progress = Double(index) / Double(maxRating)
        
        // Orange -> Yellow interpolation
        let start = UIColor.orange
        let end = UIColor.yellow
        
        var oR: CGFloat = 0
        var oG: CGFloat = 0
        var oB: CGFloat = 0
        var oA: CGFloat = 0
        
        var yR: CGFloat = 0
        var yG: CGFloat = 0
        var yB: CGFloat = 0
        var yA: CGFloat = 0
        
        start.getRed(&oR, green: &oG, blue: &oB, alpha: &oA)
        end.getRed(&yR, green: &yG, blue: &yB, alpha: &yA)
        
        let r = oR + (yR - oR) * progress
        let g = oG + (yG - oG) * progress
        let b = oB + (yB - oB) * progress
        
        return Color(
            red: Double(r),
            green: Double(g),
            blue: Double(b)
        )
    }
}
