//
//  TrickItemCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/6/25.
//

import SwiftUI

/// A compact card-style view that displays a single `TrickItem` entry and navigates to its detail view.
///
/// Shows a quick summary of the trick item including:
/// - Progress rating
/// - Creation date
/// - User notes (truncated to one line)
///
/// Tapping the cell navigates to the full `TrickItem` detail screen via the router.
///
/// - Parameters:
///   - userId: The ID of the current user.
///   - trickItem: The specific trick item being displayed.
///   - trick: The parent trick associated with this item.
struct TrickItemCell: View {
    
    // MARK: Environment
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var userStore: UserStore
    @EnvironmentObject private var router: TrickListRouter
    
    // MARK: Parameters
    let userId: String
    let trickItem: TrickItem
    let trick: Trick
    
    // MARK: Body
    var body: some View {
        Button {
            router.push(.trickItem(userId: userId, trick: trick, trickItem: trickItem))
        } label: {
            trickItemCell
        }
    }
    
    // MARK: Subviews
    
    /// Visual representation of a trick item summary.
    ///
    /// Contains:
    /// - Star rating indicator
    /// - Creation timestamp
    /// - Notes preview
    private var trickItemCell: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                TrickStarRatingView(
                    color: Color.yellow,
                    rating: trickItem.progress,
                    size: 15
                )
                
                Spacer()
                
                Text(trickItem.dateCreated.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            
            Text(trickItem.notes)
                .font(.subheadline)
                .lineLimit(1)
        }
        .padding()
        .background {
            cellBackground
        }
    }
    
    /// Background styling for the trick item cell.
    ///
    /// Uses a rounded rectangle with subtle stroke and shadow
    /// that adapts to light/dark mode.
    private var cellBackground: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
            .stroke(
                LinearGradient(
                    colors: [
                        .primary.opacity(colorScheme == .dark ? 0.2 : 0.05),
                        .black.opacity(0.4)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .shadow(
                color: .black.opacity(colorScheme == .dark ? 0.8 : 0.4),
                radius: 2,
                y: 2
            )
    }
}
