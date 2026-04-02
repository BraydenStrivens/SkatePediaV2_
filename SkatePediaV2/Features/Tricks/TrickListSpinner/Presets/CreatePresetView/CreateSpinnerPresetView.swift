//
//  CreateSpinnerPresetView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/9/26.
//

import SwiftUI

struct CreateSpinnerPresetView: View {
    @EnvironmentObject var trickSpinnerPresetsVM: TrickSpinnerPresetsViewModel
    @EnvironmentObject var trickListStore: TrickListStore
    @EnvironmentObject var userStore: UserStore
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedStance: TrickStance = .regular
    @State var transitionDirection: (insertion: Edge, removal: Edge) = (.trailing, .leading)
    
    @ObservedObject var viewModel: CreateSpinnerViewModel
    @State private var currentPreset: SpinnerPreset
    @State private var selectedTricks: [Trick] = []
    private let initialPreset: SpinnerPreset?
    
    init(
        initialPreset: SpinnerPreset? = nil,
        presetCount: Int,
        viewModel: CreateSpinnerViewModel
    ) {
        self.initialPreset = initialPreset
        
        _currentPreset = State(
            initialValue: initialPreset ?? .init(name: "Preset \(presetCount + 1)")
        )
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    var currentTricks: [Trick] {
        viewModel.tricks.filter { $0.stance == selectedStance }
    }
    
    var saveDisabled: Bool {
        (
            initialPreset?.name == currentPreset.name &&
            initialPreset?.trickIds == selectedTricks.map(\.id)
        ) || selectedTricks.count < 3
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Name: ")
                TextField(text: $currentPreset.name, prompt: Text("Preset Name")) { }
                    .autocorrectionDisabled()
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4))
                    )
            }
            
            selectedTrickList
            
            tabSelector
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(currentTricks) { trick in
                        trickCell(trick)
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                        
                        if trick != currentTricks.last! {
                            Divider()
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .id(selectedStance)
            .transition(
                .asymmetric(
                    insertion: .move(edge: transitionDirection.insertion)
                        .combined(with: .scale(scale: 0.98)),
                    removal: .move(edge: transitionDirection.removal)
                )
            )
        }
        .customNavHeader(title: "Create Preset")
        .padding(.horizontal)
        .onAppear {
            selectedTricks = currentPreset.trickIds.compactMap { id in
                viewModel.tricks.first { $0.id == id }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Clear") {
                    selectedTricks = []
                }
                .disabled(selectedTricks.isEmpty)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    currentPreset.trickIds = selectedTricks.map(\.id)
                    
                    if initialPreset == nil {
                        trickSpinnerPresetsVM.addPreset(currentPreset)
                    } else {
                        trickSpinnerPresetsVM.updatePreset(currentPreset)
                    }
                    dismiss()
                } label: {
                    Text("Save")
                }
                .tint(Color.button)
                .disabled(saveDisabled)
            }
        }
    }
    
    var selectedTrickList: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Selected Tricks:")
                Spacer()
                Text("\(selectedTricks.count)")
            }
            .font(.caption)
            .foregroundStyle(.gray)
            
            Group {
                if selectedTricks.isEmpty {
                    ContentUnavailableView {
                        VStack {
                            Text("No Tricks")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Select to create a preset.")
                                .font(.callout)
                                .foregroundStyle(.gray)
                        }
                    }
                    
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 0) {
                                HStack { Spacer() }
                                ForEach(selectedTricks) { trick in
                                    trickCell(trick)
                                        .padding(.vertical, 6)
                                        .id(trick.id)
                                    
                                    if trick != selectedTricks.last! {
                                        Divider()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .scrollIndicators(.hidden)
                        .onChange(of: selectedTricks.last) { _, newValue in
                            guard let newValue else { return }
                            proxy.scrollTo(newValue.id, anchor: .bottom)
                        }
                    }
                }
            }
            .frame(height: 200)
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 12).inset)
        }
    }
    
    func trickCell(_ trick: Trick) -> some View {
        HStack {
            Text(trick.displayName(
                useAbbreviation: userStore.trickSettings?.useTrickAbbreviations == true)
            )
            .fontWeight(selectedTricks.contains(trick) ? .semibold : .regular)
            
            Spacer()
            
            if selectedTricks.contains(trick) {
                Image(systemName: "minus")
                    .font(.body)
                    .foregroundColor(Color.red)
                
            } else {
                Image(systemName: "plus")
                    .font(.body)
                    .foregroundColor(Color.button)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.smooth) {
                if selectedTricks.contains(trick) {
                    selectedTricks.removeAll(where: { $0.id == trick.id })
                } else {
                    selectedTricks.append(trick)
                }
            }
        }
    }
    
    var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(TrickStance.allCases) { stance in
                let isCurrentTab = selectedStance == stance
                
                Text(stance.camalCase)
                    .font(.body)
                    .fontWeight(isCurrentTab ? .semibold : .regular)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
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
                    .onTapGesture {
                        selectStanceTab(newStance: stance)
                    }
            }
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
