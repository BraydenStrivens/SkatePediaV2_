//
//  TrickSpinnerPresetsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/8/26.
//

import SwiftUI

struct TrickSpinnerPresetsView: View {
    @EnvironmentObject var trickListStore: TrickListStore
    @Environment(\.colorScheme) private var colorScheme
    
    @StateObject private var viewModel = TrickSpinnerPresetsViewModel()
    
    @Binding var selectedFilter: SpinnerFilter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            optionCell("All", filter: .all)
            
            stanceFilters
            
            difficultyFilters
            
            trickItemRatingFilter
            
            customPresets
        }
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
                    
                    NavigationLink(
                        destination: CreateSpinnerPresetViewContainer(
                            allTricks: trickListStore.trickList,
                            presetCount: viewModel.presets.count
                        )
                        .environmentObject(viewModel)
                    ) {
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
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 0) {
                                ForEach(viewModel.presets) { preset in
                                    presetCell(preset: preset)
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .padding(.bottom, 6)
    }
    
    func optionCell(_ text: String, filter: SpinnerFilter) -> some View {
        Button {
            selectedFilter = filter
        } label: {
            Text(text)
                .fontWeight(selectedFilter == filter ? .semibold : .regular)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(cellBackground(for: filter))
                .contentShape(Rectangle())
                .lineLimit(1)
        }
    }
    
    func presetCell(preset: SpinnerPreset) -> some View {
        HStack(spacing: 16) {
            Text(preset.name)
            
            Spacer()
            
            NavigationLink(
                destination: CreateSpinnerPresetViewContainer(
                    allTricks: trickListStore.trickList,
                    initialPreset: preset,
                    presetCount: viewModel.presets.count
                )
                .environmentObject(viewModel)
            ) {
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
    
    @ViewBuilder
    func cellBackground(for filter: SpinnerFilter) -> some View {
        if selectedFilter == filter {
            SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).coloredProtruded(color: Color.button)

        } else {
            SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).protruded
        }
    }
}
