//
//  TrickListView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import SwiftUI

/// Main container view for displaying the user's full trick list.
///
/// Provides a multi-stance interface where tricks are grouped and browsed by stance.
/// Each stance contains grouped difficulty sections and progress tracking.
///
/// Handles:
/// - Data fetching for the user's trick list
/// - Stance-based filtering and navigation
/// - Animated transitions between stance tabs
/// - Resetting hidden tricks globally or per stance
///
/// - Important:
///   Requires `TrickListViewModel` to manage network state and refresh logic.
///
/// - Parameters:
///   - user: The user whose trick list is being displayed.
///   - viewModel: View model responsible for fetching and managing trick list state.
struct TrickListView: View {
    @EnvironmentObject private var router: TrickListRouter
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var trickListStore: TrickListStore
    
    @Environment(\.colorScheme) var colorScheme
        
    @State private var selectedStance: TrickStance = .regular
    @State private var transitionDirection: (insertion: Edge, removal: Edge) = (.trailing, .leading)
    
    @StateObject var viewModel: TrickListViewModel
    let user: User

    init(user: User, viewModel: TrickListViewModel) {
        self.user = user
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group {
            switch viewModel.requestState {
            case .idle, .loading:
                CustomProgressView(placement: .center)
                
            case .success:
                content
                
            case .failure(let sPError):
                ContentUnavailableView(
                    "Error Fetching Trick List",
                    systemImage: "exclamationmark.triangle",
                    description: Text(sPError.errorDescription ?? "Something went wrong...")
                )
            }
        }
        .task {
            await viewModel.fetchTricks(for: user.userId)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    router.push(.trickSpinner)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "shuffle.circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Spinner")
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Reset All Hidden Tricks") {
                        Task {
                            await viewModel.resetAllHiddenTricks(for: user.userId)
                        }
                    }
                } label: {
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            }
        }
    }
    
    /// Main content shown after successful data fetch.
    ///
    /// Displays:
    /// - Global trick progress summary
    /// - Stance selector tabs
    /// - Stance-filtered trick list view
    var content: some View {
        VStack {
            /// Overall progress across all stances.
            TrickListInfoView(stance: nil)
                .padding(.top, 8)
                .zIndex(2)
            
            VStack(spacing: 0) {
                tabSelector
                    .zIndex(1)
                
                TrickListViewByStance(
                    userId: user.userId,
                    stance: selectedStance,
                    resetHidden: {
                        await viewModel.resetHiddenTricksByStance(for: user.userId, stance: selectedStance)
                    }
                )
                .id(selectedStance)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: transitionDirection.insertion)
                            .combined(with: .scale(scale: 0.98)),
                        removal: .move(edge: transitionDirection.removal)
                    )
                )
                .zIndex(0)
            }
            .clipped()
        }
    }

    /// Horizontal stance selector tab bar.
    ///
    /// Allows switching between trick stances with animated transitions.
    /// Visually indicates the active tab with highlight and underline styling.
    var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(TrickStance.allCases) { stanceTab in
                let isCurrentTab = selectedStance == stanceTab
                
                VStack {
                    Text(stanceTab.camalCase)
                        .font(.headline)
                        .fontWeight(isCurrentTab ? .semibold : .regular)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background {
                            Rectangle()
                                .fill(colorScheme == .dark
                                      ? (isCurrentTab ? Color(.systemGray5) : .clear)
                                      : (isCurrentTab ? Color(.systemBackground) : .clear)
                                )
                                .shadow(color: colorScheme == .dark
                                        ? .clear
                                        : .black.opacity(0.4), radius: 4, y: 3
                                )
                                .overlay(alignment: .bottom) {
                                    Rectangle()
                                        .fill(isCurrentTab ? Color.accent : Color.clear)
                                        .frame(height: 2)
                                }
                        }
                }
                .onTapGesture {
                    selectStanceTab(newStance: stanceTab)
                }
            }
        }
        .padding(.horizontal, 6)
        .overlay(alignment: .bottom) {
            Rectangle().stroke(colorScheme == .dark ? Color.accent.opacity(0.2) : .clear)
                .frame(height: 1)
        }
        .background {
            Rectangle()
                .fill(Color(.systemBackground))
                .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.4),
                        radius: 4,
                        y: 2
                )
        }
    }
    
    /// Handles switching between stance tabs with directional animation.
    ///
    /// Determines animation direction based on tab index ordering.
    ///
    /// - Parameter newStance: The stance to switch to.
    func selectStanceTab(newStance: TrickStance) {
        guard newStance != selectedStance else { return }
        
        if newStance.index > selectedStance.index {
            transitionDirection = (.trailing, .leading)
        } else {
            transitionDirection = (.leading, .trailing)
        }
        withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
            self.selectedStance = newStance
        }
    }
}
