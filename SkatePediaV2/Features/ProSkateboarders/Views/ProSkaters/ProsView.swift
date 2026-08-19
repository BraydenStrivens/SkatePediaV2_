//
//  ProsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import SwiftUI

/// The main SwiftUI view responsible for displaying and browsing all professional skaters.
///
/// `ProsView` provides a searchable, horizontally scrollable list of pro skaters
/// and a detail section showing videos for the currently selected pro. It handles
/// loading, success, and error states using `ProsViewModel`.
///
/// - Important:
/// The view depends on `ProsViewModel` for state and `ProsStore` for cached data.
struct ProsView: View {
    
    // MARK: Environment
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var appEnv: AppEnvironment
    @EnvironmentObject private var prosStore: ProsStore
    
    // MARK: Parameters
    @StateObject var viewModel: ProsViewModel
    
    // MARK: Init
    init(
        viewModel: ProsViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: Body
    var body: some View {
        Group {
            switch viewModel.requestState {
            case .idle, .loading:
                CustomProgressView(placement: .center)
                
            case .success:
                if prosStore.proSkaters.isEmpty {
                    ContentUnavailableView(
                        "No Pro Skaters",
                        systemImage: "person.slash"
                    )
                    
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 10) {
                            searchBar
                            
                            proSkaterCards
                            
                            ProVideosListBuilder.build(
                                proSkater: viewModel.selectedPro,
                                appEnv: appEnv
                            )
                            .id(viewModel.selectedPro?.id)
                        }
                        .padding(8)
                    }
                }
                
            case .failure(let sPError):
                SPContentUnavailableView(
                    title: "Error",
                    description: sPError.errorDescription,
                    type: .blockingError
                )
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .task {
            await viewModel.fetchProSkatersIfNeeded()
        }
        .customNavHeader(
            title: "Pro Skaters",
            showDivider: true
        )
    }
    
    // MARK: Subviews
    
    /// The search bar used to filter professional skaters by name.
    ///
    /// This view:
    /// - Binds to `ProsViewModel.proSearchText`
    /// - Triggers filtering on text changes
    /// - Provides a simple magnifying glass UI
    ///
    /// - Returns:
    /// A styled search input field with background decoration.
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(viewModel.proSearchText.isEmpty ? .gray : .primary)
            
            TextField("Search pros", text: $viewModel.proSearchText)
                .textFieldStyle(PlainTextFieldStyle())
                .disableAutocorrection(true)
                .textContentType(.none)
                .lineLimit(1)
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
        }
        .onChange(of: viewModel.proSearchText) { _, _ in
            viewModel.debounceFilterProsArray()
        }
    }
    
    /// A horizontally scrollable collection of professional skater cards.
    ///
    /// This view:
    /// - Displays filtered pro skaters from the view model
    /// - Highlights the currently selected pro
    /// - Supports tap-to-select interaction
    /// - Automatically scrolls to the selected pro
    ///
    /// - Returns:
    /// A horizontal `ScrollView` containing `ProSkaterCell` views.
    ///
    /// - Important:
    /// Selection state updates `ProsViewModel.selectedPro`, which drives downstream UI.
    ///
    /// - Note:
    /// Uses `ScrollViewReader` for programmatic centering of selected items.
    private var proSkaterCards: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(alignment: .center, spacing: 0) {
                    if viewModel.filteredProSkaters.isEmpty, !viewModel.proSearchText.isEmpty {
                        HStack {
                            Spacer()
                            Text("No pro skaters matching '\(viewModel.proSearchText)'")
                            Spacer()
                        }
                        .frame(width: UIScreen.screenWidth, height: 100)
                        
                    } else {
                        ForEach(viewModel.filteredProSkaters) { pro in
                            let isSelected = viewModel.selectedPro == pro
                            
                            ProSkaterCell(
                                pro: pro,
                                isSelected: isSelected
                            )
                            .id(pro.id)
                            .scaleEffect(isSelected ? 1.07 : 1)
                            .environmentObject(viewModel)
                            .onTapGesture {
                                withAnimation(.smooth) {
                                    viewModel.selectedPro = pro
                                }
                            }
                        }
                    }
                }
            }
            .onChange(of: viewModel.selectedPro) { _, newValue in
                withAnimation(.smooth) {
                    proxy.scrollTo(newValue?.id, anchor: .center)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark
                      ? Color(.systemGray6).shadow(.inner(
                        color: .white.opacity(0.2), radius: 1, x: 0, y: -1)
                      )
                      : Color(.systemBackground).shadow(.inner(
                        color: .black.opacity(0.4), radius: 2, x: 0, y: 3)
                      )
                     )
        )
        .compositingGroup()
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    LinearGradient(
                        colors: [
                            .black.opacity(0.4),
                            .primary.opacity(colorScheme == .dark ? 0.2 : 0.08)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
    }
}
