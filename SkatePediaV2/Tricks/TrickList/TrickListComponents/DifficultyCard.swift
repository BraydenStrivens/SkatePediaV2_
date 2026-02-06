//
//  DifficultyCard.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/3/26.
//

import SwiftUI

struct DifficultyCard: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    
    @ObservedObject var trickListVM: TrickListViewModel
    let difficulty: TrickDifficulty
    let stance: TrickStance
    var isExpanded: Bool {
        trickListVM.isExpanded(for: stance, with: difficulty)
    }
    var tricks: [Trick] {
        trickListVM.tricks(for: stance, and: difficulty)
    }
    var learnedCount: Int {
        tricks.filter { $0.progress.contains(3) }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card header
            HStack(spacing: 8) {
                Text(difficulty.camalCase)
                    .font(.headline)
                
                Spacer()
                
                Text("\(learnedCount)/\(tricks.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                
                Image(systemName: "chevron.down")
                    .rotationEffect(Angle(degrees: isExpanded ? 180 : 0))
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(colorScheme == .dark ? Color(.systemGray3) : Color(.systemGray4))
                    .opacity(isExpanded ? 1 : 0.4)
            }
            .onTapGesture {
                trickListVM.toggleCardExpansion(for: stance, with: difficulty)
            }
            
            if !tricks.isEmpty {
                // Card dropdown list
                VStack(spacing: 0) {
                    if isExpanded {
                        ForEach(tricks) { trick in
                            TrickListCell(trick: trick)
                                .environmentObject(trickListVM)
                            
                            if trick.id != tricks.last?.id {
                                Divider()
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .clipped()
                .transition(.move(edge: .top))
            }
        }
        .clipped()
        .padding(6)
        .background {
            RoundedRectangle(cornerRadius: 25)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                .shadow(color: colorScheme == .dark ? .clear : Color.black.opacity(0.4), radius: isExpanded ? 5 : 3,
                        y: isExpanded ? 4 : 2
                )
        }
        .padding(.horizontal, 8)
    }
}
