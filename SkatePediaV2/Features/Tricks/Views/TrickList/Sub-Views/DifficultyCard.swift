//
//  DifficultyCard.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/3/26.
//

import SwiftUI

/// View representing a collapsible card for a group of tricks by stance and difficulty.
///
/// Displays a header with difficulty information and learned trick count,
/// and optionally expands to show a list of tricks.
///
/// Expansion state is persisted using `UserDefaults`, and the card
/// automatically expands when new tricks are added.
///
/// - Parameters:
///   - userId: The ID of the current user.
///   - difficulty: The difficulty level represented by this card.
///   - stance: The stance associated with the tricks.
///   - tricks: The list of tricks belonging to this difficulty.
struct DifficultyCard: View {
    @EnvironmentObject private var errorStore: ErrorStore
    @EnvironmentObject private var trickListStore: TrickListStore
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    
    @State private var isExpanded: Bool
    /// Tracks previously displayed trick IDs to detect newly added tricks.
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
        
        // Unique key per stance + difficulty combination
        self.defaultsKey = "expanded_\(stance.rawValue)_\(difficulty.rawValue)"
        
        // Restore expansion state (default = expanded)
        _isExpanded = State(initialValue: UserDefaults.standard.object(forKey: defaultsKey) as? Bool ?? true)
        
        // Initialize previous IDs for change detection
        _previousTrickIds = State(initialValue: Set(tricks.map(\.id)))
    }

    /// Number of tricks considered "learned" (progress == 3).
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
        /// Detects newly added tricks and auto-expands the card if needed.
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
    
    /// Header displaying difficulty name, progress count, and expand/collapse indicator.
    ///
    /// - Important:
    ///   Tapping the header toggles the expansion state of the card.
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
    
    /// Body containing the list of tricks.
    ///
    /// Displays each trick using `TrickListCellBuilder` and separates them with dividers.
    ///
    /// - Important:
    ///   Content is only rendered when the card is expanded.
    var cardBody: some View {
        VStack(spacing: 0) {
            if isExpanded {
                ForEach(tricks) { trick in
                    TrickListCellBuilder.build(
                        userId: userId,
                        trick: trick,
                        errorStore: errorStore,
                        trickListStore: trickListStore
                    )
                    
                    if trick.id != tricks.last?.id {
                        Divider()
                            .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    /// Toggles the expansion state of the card with animation.
    ///
    /// Persists the updated state to `UserDefaults`.
    ///
    /// - Important:
    ///   Uses a unique key per stance and difficulty to maintain independent states.
    private func toggleCardExpansion() {
        withAnimation(.smooth) {
            isExpanded.toggle()
            UserDefaults.standard.set(isExpanded, forKey: defaultsKey)
        }
    }
}
