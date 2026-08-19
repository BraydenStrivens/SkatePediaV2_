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
    
    // MARK: Environment
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var router: TrickListRouter
    @EnvironmentObject private var userStore: UserStore    
        
    // MARK: State
    @State private var selectedStance: TrickStance = .regular
    @State private var transitionDirection: (insertion: Edge, removal: Edge) = (.trailing, .leading)
    
    // MARK: Parameters
    @StateObject var viewModel: TrickListViewModel
    let user: User

    // MARK: Init
    init(user: User, viewModel: TrickListViewModel) {
        self.user = user
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: Body
    var body: some View {
        Group {
            switch viewModel.requestState {
            case .idle, .loading:
                CustomProgressView(placement: .center)
                
            case .success:
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
                        .environmentObject(viewModel)
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
                
            case .failure(let sPError):
                SPContentUnavailableView(
                    title: "Error Fetching Trick List",
                    description: sPError.errorDescription,
                    type: .blockingError
                )
            }
        }
        .task {
            await viewModel.fetchTricks(for: user.userId)
        }
        .toolbar {
            toolBarItems
        }
    }
    
    // MARK: Functions
    
    /// Handles switching between stance tabs with directional animation.
    ///
    /// Determines animation direction based on tab index ordering.
    ///
    /// - Parameter newStance: The stance to switch to.
    private func selectStanceTab(newStance: TrickStance) {
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
    
    // MARK: Subviews
    
    /// Displays a button to navigate to the `TrickListSpinnerView`, and a menu to toggle edit mode.
    ///
    /// When in edit mode, a 'Done' button is displayed as well as text to indicate the number of favorited tricks.
    @ToolbarContentBuilder
    private var toolBarItems: some ToolbarContent {
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
        
        if viewModel.toggleEdit {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                    Text("\(userStore.favoriteTricks?.count ?? 0)/3")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.toggleEdit = false
                    }
                }
            }
        } else {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Reset All Hidden Tricks") {
                        Task {
                            await viewModel.resetAllHiddenTricks(for: user.userId)
                        }
                    }
                    Button("Edit Tricks") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.toggleEdit = true
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

    /// Horizontal stance selector tab bar.
    ///
    /// Allows switching between trick stances with animated transitions.
    /// Visually indicates the active tab with highlight and underline styling.
    private var tabSelector: some View {
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
}
