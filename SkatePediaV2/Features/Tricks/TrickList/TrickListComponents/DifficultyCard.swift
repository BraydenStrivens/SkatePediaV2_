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
    
    @State private var isExpanded: Bool
    @State private var previousTrickIds: Set<String> = []
    
    let userId: String
    let difficulty: TrickDifficulty
    let stance: TrickStance
    let tricks: [Trick]
    
    private let defaultsKey: String
    
    init(
        userId: String,
        difficulty: TrickDifficulty,
        stance: TrickStance,
        tricks: [Trick]
    ) {
        self.userId = userId
        self.difficulty = difficulty
        self.stance = stance
        self.tricks = tricks
        
        self.defaultsKey = "expanded_\(stance.rawValue)_\(difficulty.rawValue)"
        _isExpanded = State(initialValue: UserDefaults.standard.object(forKey: defaultsKey) as? Bool ?? true)
        _previousTrickIds = State(initialValue: Set(tricks.map(\.id)))
    }

    var learnedCount: Int {
        tricks.filter { $0.progressCounts.num3s > 0 }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            cardHeader
                .onTapGesture {
                    toggleCardExpansion()
                }
            
            if !tricks.isEmpty {
                cardBody
                    .clipped()
                    .transition(.move(edge: .top))
            }
        }
        .padding(6)
        .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 25).protruded)
        .padding(.horizontal, 8)
        .onChange(of: tricks) { _, newTricks in
            let newIds = Set(newTricks.map(\.id))
            if newIds.subtracting(previousTrickIds).isEmpty == false {
                if !isExpanded {
                    toggleCardExpansion()
                }
            }
            previousTrickIds = newIds
        }
    }
    
    var cardHeader: some View {
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
                .fill(colorScheme == .dark
                      ? Color(.systemGray6)
                      : Color(.systemBackground)
                )
                .stroke(
                    LinearGradient(
                        colors: [
                            .primary.opacity(colorScheme == .dark ? 0.2 : 0.1),
                            .black.opacity(0.4)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: colorScheme == .dark
                        ? .clear
                        : .black.opacity(isExpanded ? 0.3 : 0), radius: 2, x: 0, y: 2
                )
        }
    }
    
    var cardBody: some View {
        VStack(spacing: 0) {
            if isExpanded {
                ForEach(tricks) { trick in
                    TrickListCellContainer(
                        userId: userId,
                        trick: trick
                    )
                    
                    if trick.id != tricks.last?.id {
                        Divider()
                            .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    private func toggleCardExpansion() {
        withAnimation(.smooth) {
            isExpanded.toggle()
            UserDefaults.standard.set(isExpanded, forKey: defaultsKey)
        }
    }
}
