//
//  TrickSpinnerPresetsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/8/26.
//

import SwiftUI

/// A view that allows users to select and manage filters for the Trick Spinner feature.
///
/// Provides a categorized interface for filtering spinner results by:
/// - All tricks
/// - Stance
/// - Difficulty
/// - Trick item rating
/// - Custom user-created presets
///
/// Also supports creating, editing, and deleting custom spinner presets.
///
/// - Important:
///   This view binds to a `SpinnerFilter` value, which directly controls
///   what set of tricks will be used in the spinner logic.
///
/// - Parameters:
///   - selectedFilter: The currently active spinner filter.
///   - viewModel: View model responsible for loading and managing custom presets.
struct TrickSpinnerPresetsView: View {
    @EnvironmentObject private var router: TrickListRouter
    @EnvironmentObject private var trickListStore: TrickListStore
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject private var viewModel: TrickSpinnerPresetsViewModel
    /// Currently selected spinner filter (two-way bound to parent view).
    @Binding var selectedFilter: SpinnerFilter
    
    init(
        selectedFilter: Binding<SpinnerFilter>,
        viewModel: TrickSpinnerPresetsViewModel
    ) {
        self._selectedFilter = selectedFilter
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                optionCell("All", filter: .all)
                
                stanceFilters
                
                difficultyFilters
                
                trickItemRatingFilter
                
                customPresets
            }
        }
        .scrollIndicators(.hidden)
    }
    
    var stanceFilters: some View {
        VStack(alignment: .leading) {
            Text("Stance:")
                .font(.caption)
                .foregroundStyle(.gray)
            
            HStack() {
                ForEach(TrickStance.allCases) { stance in
                    optionCell(stance.camalCase, filter: .stance(stance))
                }
            }
        }
    }
    
    var difficultyFilters: some View {
        VStack(alignment: .leading) {
            Text("Difficulty:")
                .font(.caption)
                .foregroundStyle(.gray)
            
            HStack() {
                ForEach(TrickDifficulty.allCases) { difficulty in
                    optionCell(difficulty.camalCase, filter: .difficulty(difficulty))
                }
            }
        }
    }
    
    var trickItemRatingFilter: some View {
        VStack(alignment: .leading) {
            Text("Highest Trick Item Rating:")
                .font(.caption)
                .foregroundStyle(.gray)
            
            HStack() {
                ForEach(0...3, id: \.self) { rating in
                    optionCell("\(rating)", filter: .rating(rating))
                }
            }
        }
    }
    
    /// Displays and manages user-created spinner presets.
    ///
    /// Allows users to:
    /// - Create new presets
    /// - Edit existing presets
    /// - Delete presets
    /// - Select a preset as the active spinner filter
    var customPresets: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Custom Presets:")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("Add")
                        .font(.caption)
                    
                    Button {
                        router.push(
                            .createTrickSpinnerPreset(
                                presetCount: viewModel.presets.count
                            )
                        )
                    } label: {
                        Image(systemName: "plus")
                            .font(.body)
                    }
                }
                .tint(Color.button)
            }
            
            ZStack {
                SPBackgrounds(colorScheme: colorScheme, cornerRadius: 20).inset
                
                Group {
                    if viewModel.presets.isEmpty {
                        ContentUnavailableView {
                            VStack {
                                Text("No Presets")
                                    .font(.title)
                                Text("Select tricks to create and save a custom spinner preset.")
                                    .font(.callout)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                    } else {
                        VStack(spacing: 0) {
                            ForEach(viewModel.presets) { preset in
                                presetCell(preset: preset)
                            }
                            
                            Spacer(minLength: 0)
                        }
                        .padding(6)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .padding(.bottom, 6)
        .frame(minHeight: 200)
    }
    
    /// Creates a selectable filter option cell.
    ///
    /// - Parameters:
    ///   - text: Display text for the filter option.
    ///   - filter: The filter value applied when selected.
    func optionCell(_ text: String, filter: SpinnerFilter) -> some View {
        Button {
            selectedFilter = filter
        } label: {
            Text(text)
                .font(.caption)
                .fontWeight(selectedFilter == filter ? .semibold : .regular)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(cellBackground(for: filter))
                .contentShape(Rectangle())
                .lineLimit(1)
        }
    }
    
    /// A row representing a saved custom spinner preset.
    ///
    /// - Parameter preset: The preset being displayed.
    func presetCell(preset: SpinnerPreset) -> some View {
        HStack(spacing: 16) {
            Text(preset.name)
            
            Spacer()
            
            Button {
                router.push(
                    .createTrickSpinnerPreset(
                        initialPreset: preset,
                        presetCount: viewModel.presets.count
                    )
                )
            } label: {
                Image(systemName: "pencil")
                    .font(.body)
            }
            
            Button(role: .destructive) {
                viewModel.deletePreset(preset)
            } label: {
                Image(systemName: "trash")
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .background(cellBackground(for: .custom(preset.trickIds)))
        .contentShape(Rectangle())
        .padding(6)
        .onTapGesture {
            selectedFilter = .custom(preset.trickIds)
        }
    }
    
    /// Returns the background style for a filter cell.
    ///
    /// - Parameter filter: The filter being evaluated.
    @ViewBuilder
    func cellBackground(for filter: SpinnerFilter) -> some View {
        if selectedFilter == filter {
            SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).coloredProtruded(color: Color.button)

        } else {
            SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).protruded
        }
    }
}
