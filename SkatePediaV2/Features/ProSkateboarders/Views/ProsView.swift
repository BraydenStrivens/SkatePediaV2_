//
//  ProsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import SwiftUI

/// The main view displaying all Pro Skaters.
///
/// Shows a searchable horizontal list of pros and the selected pro's videos.
/// Handles loading, success, and error states via the `ProsViewModel`.
struct ProsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject var viewModel = ProsViewModel()
    
    var body: some View {
        Group {
            switch viewModel.requestState {
            case .idle, .loading:
                CustomProgressView(placement: .center)
                
            case .success:
                if viewModel.proSkaters.isEmpty {
                    ContentUnavailableView(
                        "No Pro Skaters",
                        systemImage: "person.slash"
                    )
                    
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 10) {
                            searchBar
                            
                            proSkaterCards
                            
                            ProVideosListView(proSkater: viewModel.selectedPro)
                                .id(viewModel.selectedPro?.id)
                        }
                        .padding(8)                        
                    }
                }
                
            case .failure(let spError):
                ContentUnavailableView(
                    "Error",
                    systemImage: "exclamationmark.triangle",
                    description: Text(spError.errorDescription ?? "Something went wrong...")
                )
            }
        }
        .task {
            await viewModel.fetchProSkaters()
        }
        .customNavHeader(
            title: "Pro Skaters",
            showDivider: true
        )
    }
    
    /// Search bar allowing the user to filter the list of pros
    var searchBar: some View {
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
        .onChange(of: viewModel.proSearchText) { _, _ in
            viewModel.filterProsArray()
        }
    }
    
    /// Horizontal scrollable cards for each Pro Skater
    ///
    /// Highlights the selected pro and scrolls automatically to center them.
    var proSkaterCards: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(alignment: .center, spacing: 0) {
                    if viewModel.filteredProSkaters.isEmpty {
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
