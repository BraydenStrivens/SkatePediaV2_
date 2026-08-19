//
//  NoTrickItemsCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/12/26.
//

import SwiftUI

/// A placeholder cell displayed when a trick has no associated trick items.
///
/// Tapping the cell navigates to the add trick item screen for the
/// associated trick.
///
/// - Parameters:
///   - userId: The identifier of the user who owns the trick list.
///   - trick: The trick associated with this placeholder cell.
struct NoTrickItemsCell: View {
    
    // MARK: Environment
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var router: TrickListRouter
    
    // MARK: Parameters
    let userId: String
    let trick: Trick
    
    // MARK: Body
    var body: some View {
        Button {
            router.push(.addTrickItem(userId: userId, trick: trick))
        } label: {
            VStack(spacing: 8) {
                Text("No Trick Items")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("Upload")
                    .foregroundStyle(Color.button)
                    .font(.subheadline)
                    .underline()
                + Text(" a trick item and start analyzing your skateboarding!")
                    .foregroundStyle(.gray)
                    .font(.subheadline)

            }
            .padding()
            .padding(.horizontal, 35)
            .background {
                cellBackground
            }
        }
    }
    
    // MARK: Subviews
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
