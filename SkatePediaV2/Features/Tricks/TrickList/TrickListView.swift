//
//  TrickListView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import SwiftUI
import SlidingTabView

struct TrickListView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var trickListStore: TrickListStore
    
    @Environment(\.colorScheme) var colorScheme
        
    @State private var selectedStance: TrickStance = .regular
    @State private var transitionDirection: (insertion: Edge, removal: Edge) = (.trailing, .leading)
    
    @StateObject var viewModel: TrickListViewModel

    init(viewModel: TrickListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        if let user = userStore.user {
            Group {
                switch viewModel.requestState {
                case .idle, .loading:
                    CustomProgressView(placement: .center)
                    
                case .success:
                    content(userId: user.userId)
                    
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
                    NavigationLink(
                        destination: TrickListSpinnerViewContainer(
                            trickListStore: trickListStore
                        )
                    ) {
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
            
        } else {
            ContentUnavailableView {
                Text("Error Fetching User")
            }
        }
    }
    
    func content(userId: String) -> some View {
        VStack {
            // Displays total tricks learned bar
            TrickListInfoView(stance: nil)
                .padding(.top, 8)
                .zIndex(2)
            
            // Trick List view filtered by the selected stance
            VStack(spacing: 0) {
                tabSelector
                    .zIndex(1)
                
                TrickListViewByStance(
                    userId: userId,
                    stance: selectedStance,
                    resetHidden: {
                        await viewModel.resetHiddenTricksByStance(for: userId, stance: selectedStance)
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


//Group {
//            switch viewModel.requestState {
//            case .idle, .loading:
//                CustomProgressView(placement: .center)
//
//            case .success:
//                VStack {
//                    // Displays total tricks learned bar
//                    TrickListInfoView()
//                        .environmentObject(viewModel)
//                        .padding(.top, 8)
//                        .zIndex(2)
//
//                    // Trick List view filtered by the selected stance
//                    VStack(spacing: 0) {
//                        tabSelector
//                            .zIndex(1)
//
//                        TrickListViewByStance(
//                            stance: selectedStance
//                        )
//                        .id(selectedStance)
//                        .environmentObject(viewModel)
//                        .transition(
//                            .asymmetric(
//                                insertion: .move(edge: transitionDirection.insertion)
//                                    .combined(with: .scale(scale: 0.98)),
//                                removal: .move(edge: transitionDirection.removal)
//                            )
//                        )
//                        .zIndex(0)
//                    }
//                    .clipped()
//                }
//
//            case .failure(let spError):
//                ContentUnavailableView(
//                    "Error Fetching Trick List",
//                    systemImage: "exclamationmark.triangle",
//                    description: Text(spError.errorDescription ?? "Something went wrong...")
//                )
//            }
//        }
//        .task {
//            await viewModel.initializeTrickListView()
//        }
//        .alert("Error",
//               isPresented: Binding(
//                get: { viewModel.error != nil },
//                set: { _ in viewModel.error = nil }
//               )
//        ) {
//            Button("OK", role: .cancel) { }
//
//        } message: {
//            Text(viewModel.error?.errorDescription ?? "Something went wrong...")
//        }
