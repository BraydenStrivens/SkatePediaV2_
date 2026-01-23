//
//  FilterPostsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/16/26.
//

import SwiftUI

/// Contains input fields that allow the user to filter posts in the community feed. Contains functions for displaying the stances to filter for, and the tricks to
/// filter for for each stance. Contains an EnvironmentObject of the CommunityViewModel in order to update the post filter.
///
/// - Parameters:
///  - user: A 'User' object containing information about the current user
///  - initialFilter: A 'PostFilter' object that stores the previously selected filter. If no filter was selected by the user, the default filter is all stances and all tricks.
///
struct FilterPostsView: View {
    @EnvironmentObject var communityViewModel: CommunityViewModel

    @State private var stanceExpanded: Bool = false
    @State private var trickExpanded: Bool = false
    @State private var tricks: [JsonTrick]
    @State private var tricksForStance: [JsonTrick]
    @State private var currentFilter: PostFilter
    @State private var error: Bool = false
    
    let user: User
    let initialFilter: PostFilter
    
    /// Initializes the view by storing the inputted parameters and using them to store infomormation for the trick filters dropdown menu.
    /// Decodes all the tricks contained in the TrickList.json file and stores them. It then filters these tricks by the stance selected in the
    /// initial filter to be displayed in the trick filters dropdown menu. The trick filter dropdown only contains tricks for the selected stance,
    /// so each time the user changes the stance the tricks need to be re-filtered.
    ///
    @MainActor
    init(user: User, initialFilter: PostFilter) {
        self.user = user
        self.initialFilter = initialFilter
        _currentFilter = State(initialValue: initialFilter)
                
        if let url = Bundle.main.url(forResource: "TrickList", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let jsonData = try JSONDecoder().decode([JsonTrick].self, from: data)
                _tricks = State(initialValue: jsonData)
                _tricksForStance = State(initialValue: jsonData.filter { $0.stance == initialFilter.stance.rawValue })
            } catch {
                _tricks = State(initialValue: [])
                _tricksForStance = State(initialValue: [])
                self.error = true
            }
        } else {
            _tricks = State(initialValue: [])
            _tricksForStance = State(initialValue: [])
            self.error = true
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            if error {
                VStack(alignment: .center) {
                    Text("Error Loading Filters")
                        .font(.headline)
                    Text("Please close the filter and try again")
                        .font(.body)
                }
                .frame(maxWidth: .infinity)
                
            } else {
                Grid(verticalSpacing: 10) {
                    stanceSelector
                    Divider()
                    
                    // Only show the trick filter if a stance other than "All" has been selected
                    if currentFilter.stance != .all {
                        trickSelector
                        Divider()
                    }
                    
                    applyFilterButton
                }
                .frame(maxWidth: .infinity)
                .zIndex(1)
            }
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 5)
                .fill(.gray.opacity(0.1))
        }
        .padding(12)
        .onChange(of: currentFilter.stance) { _, newValue in
            // Re-filters the tricks for the newly selected stance
            tricksForStance = tricks.filter { $0.stance == newValue.rawValue }
        }
        .overlay(alignment: .topLeading, content: {
            dropDownOverlay
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.primary)
                        .fill(Color(uiColor: .systemBackground))
                }
                .offset(x: 20)
                .offset(y: .all == currentFilter.stance ? 60 : 100)
        })
        
    }
    
    /// Contains a button to open the stance filters dropdown, a button to reset the filter to '.all', and shows the currently selected stance filter
    ///
    var stanceSelector: some View {
        GridRow {
            Text("Stance:")
                .frame(width: 70, alignment: .leading)
            
            Text(currentFilter.stance.rawValue)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: stanceExpanded ? "chevron.up" : "chevron.down")
                .frame(width: 50, alignment: .trailing)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        trickExpanded = false
                        stanceExpanded.toggle()
                    }
                }

            // Reset stance button. Resets the stance to all stances
            Button(role: .destructive) {
                currentFilter = PostFilter(stance: .all)
            } label: {
                Image(systemName: "x.circle")
            }
            .frame(width: 70, alignment: .trailing)
            .disabled(.all == currentFilter.stance)
        }
    }
    
    /// Contains a button to open the trick filters dropdown, a button to remove the filter to 'nil', and shows the currently selected trick filter
    ///
    var trickSelector: some View {
        GridRow {
            Text("Trick:")
                .frame(width: 70, alignment: .leading)
            
            Text(currentFilter.trick?.name ?? "All")

                .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: trickExpanded ? "chevron.up" : "chevron.down")
                .frame(width: 50, alignment: .trailing)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        stanceExpanded = false
                        trickExpanded.toggle()
                    }
                }
            
            // Clear trick filter button.
            Button(role: .destructive) {
                // PostFilter(stance: _) initializes the trick filter to nil and preserves the current stance
                currentFilter = PostFilter(stance: currentFilter.stance)
            } label: {
                Image(systemName: "x.circle")
            }
            .frame(width: 70, alignment: .trailing)
            .disabled(currentFilter.trick == nil)

        }
    }
    
    /// Shows the appropriate filter dropdown based on whether or not the 'open stance dropdown' or 'open trick dropdown' button was clicked.
    ///
    @ViewBuilder
    var dropDownOverlay: some View {
        if stanceExpanded {
            stanceDropdownList
            
        } else if trickExpanded {
            trickDropdownList
        }
    }
    
    /// Contains a list of all selectable stance filters. Updates the current filter when a stance is selected.
    ///
    var stanceDropdownList: some View {
        VStack(spacing: 0) {
            ForEach(FilterStances.allCases, id: \.self) { stance in
                HStack(spacing: 0) {
                    Text(stance.rawValue)
                    
                    Spacer()
                    
                    if stance == currentFilter.stance {
                        Image(systemName: "checkmark")
                    }
                }
                .padding()
                .onTapGesture {
                    currentFilter = PostFilter(stance: stance)
                    stanceExpanded = false
                }
                Divider()
            }
        }
        .frame(width: 200)
    }
    
    /// Contains a list of all selectable trick filters for the selected stance. Updates the current filter when a trick is selected.
    /// Only is available if a stance is selected because the tricks are filtered by stance.
    ///
    var trickDropdownList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(tricksForStance) { trick in
                    HStack {
                        Text(trick.name)
                        
                        Spacer()
                        
                        if let selectedTrick = currentFilter.trick {
                            if trick == selectedTrick {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .padding()
                    .onTapGesture {
                        currentFilter = PostFilter(stance: currentFilter.stance, trick: trick)
                        trickExpanded = false
                    }
                    Divider()
                }
            }
        }
        .frame(width: 250, height: 350)
    }
    
    /// Applies the currently selected stance and or trick filters then closes the view. Updates the post filter in the community view model
    /// which refetches posts with the newly applied filter.
    /// 
    var applyFilterButton: some View {
        GridRow {
            Button {
                communityViewModel.postFilter = currentFilter
                
                withAnimation(.easeInOut(duration: 0.25)) {
                    communityViewModel.showFilters = false
                }
            } label: {
                Text("Apply")
                    .foregroundColor(currentFilter == initialFilter ? .gray : Color("buttonColor"))
                    .frame(width: 70, height: 30)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(currentFilter == initialFilter ? .gray : Color("buttonColor"))
                    }
            }
            .opacity(currentFilter == initialFilter ? 0.5 : 1)
            .disabled(currentFilter == initialFilter)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .gridCellColumns(4)
        }
    }
}
