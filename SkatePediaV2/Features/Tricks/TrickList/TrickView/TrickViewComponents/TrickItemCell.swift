//
//  TrickItemCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/6/25.
//

import SwiftUI

struct TrickItemCell: View {
    @EnvironmentObject var userStore: UserStore
    
    @Environment(\.colorScheme) var colorScheme
    
    let userId: String
    let trickItem: TrickItem
    let trick: Trick
    
    var trickDisplayName: String {
        trick.displayName(useAbbreviation: userStore.trickSettings?.useTrickAbbreviations == true)
    }
    
    var body: some View {
        NavigationLink(
            destination: TrickItemViewContainer(
                userId: userId,
                trickItem: trickItem,
                trick: trick
            )
        ) {
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
    }
}
