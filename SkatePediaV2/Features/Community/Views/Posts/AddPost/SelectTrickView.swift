//
//  SelectTrickView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/15/26.
//

import SwiftUI

/// Displays all the tricks from the user's trick list for which trick items have been uploaded. Nagivates to the SelectTrickItemView for a trick when the
/// user selects a trick.
///
/// - Parameters:
///  - uploadPostPath:The current navigation path within the navigation stack for views related to uploading a post.
///  - user: A 'User' object containing information about the current user.
///  
struct SelectTrickView: View {
    @EnvironmentObject private var router: CommunityRouter
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject var viewModel = SelectTrickViewModel()
    
    @State private var currentTab: TrickStance = .regular
    
    let user: User
    
    private func trickDisplayName(_ trick: Trick) -> String {
        if user.settings.trickSettings.useTrickAbbreviations {
            trick.abbreviation
        } else {
            trick.name
        }
    }
    
    var body: some View {
        Group {
            switch viewModel.fetchTrickListState {
            case .idle, .loading:
                CustomProgressView(placement: .center)
                
            case .success:
                if viewModel.trickList.isEmpty {
                    ContentUnavailableView(
                        "No Tricks with Trick Items",
                        systemImage: "list.bullet.rectangle.portrait",
                        description: Text("Please upload a trick item for a trick in order to turn it into a post.")
                    )
                } else {
                    VStack {
                        header
                        
                        ScrollView {
                            Group {
                                // Organizes the trick list differently depending on the number of tricks fetched
                                if viewModel.trickList.count <= 10 {
                                    plainTrickList
                                    
                                } else if viewModel.trickList.count <= 18 {
                                    semiSortedTrickList
                                    
                                } else {
                                    TrickStanceTabView { stance in
                                        let sortedTrickList = viewModel.tricks(for: stance)
                                        trickListByStance(trickListByStance: sortedTrickList)
                                    }
                                }
                            }
                            .padding()
                        }
                        .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).inset)
                        .padding()
                    }
                    .frame(maxHeight: .infinity)
                }
            case .failure(let firestoreError):
                ContentUnavailableView(
                    "Error Fetching Tricks",
                    systemImage: "exclamationmark.triangle",
                    description: Text(firestoreError.errorDescription ?? "")
                )
            }
        }
        .customNavHeader(
            title: "Select a Trick",
            showDivider: true
        )
        .task {
            await viewModel.fetchTricksWithTrickItems(userId: user.userId)
        }
    }
    
    var header: some View {
        VStack(alignment: .center) {
            Text("Select a ")
            + Text("Trick")
                .fontWeight(.semibold)
            + Text(", then select a ")
            + Text("Trick Item")
                .fontWeight(.semibold)
            + Text(" to post.")
            
            Text("\(viewModel.trickList.count)")
                .fontWeight(.semibold)
                .font(.subheadline)
            + Text(" tricks have ")
                .font(.subheadline)
            + Text("Trick Items")
                .fontWeight(.semibold)
                .font(.subheadline)
        }
        .multilineTextAlignment(.center)
        .padding()
        .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).protruded)
        .padding(10)
    }
        
    /// Simply lists all the tricks in one vertical list. Navigates to the SelectTrickItem view for a trick when selected.
    ///
    var plainTrickList: some View {
        VStack {
            ForEach(viewModel.trickList) { trick in
                Button {
                    router.push(.selectTrickItem(user: user, trick: trick))
                } label: {
                    HStack {
                        Text(trickDisplayName(trick))
                        
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding(.vertical, 5)
                }
                .foregroundColor(.primary)
                
                if trick != viewModel.trickList.last! {
                    Divider()
                }
            }
        }
    }
    
    /// Lists all the tricks in one vertical list and separated by stance. Navigates to the SelectTrickItem view for a trick
    /// when selected.
    var semiSortedTrickList: some View {
        VStack(alignment: .leading) {
            ForEach(TrickStance.allCases) { stance in
                let filteredList = viewModel.tricks(for: stance)
                
                if !filteredList.isEmpty {
                    Text(stance.camalCase)
                        .foregroundStyle(.gray)
                        .font(.caption)
                    
                    VStack(alignment: .leading) {
                        ForEach(filteredList) { trick in
                            Button {
                                router.push(.selectTrickItem(user: user, trick: trick))
                            } label: {
                                HStack {
                                    Text(trickDisplayName(trick))
                                    
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.vertical, 5)
                            }
                            
                            if trick != filteredList.last! {
                                Divider()
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// Tab selector for the sorted trick list. Updates the list with animations.
    var stanceTabSelector: some View {
        HStack(spacing: 0) {
            ForEach(TrickStance.allCases) { stance in
                let isCurrentTab = stance == currentTab
                                    
                VStack {
                    Text(stance.camalCase)
                        .font(.subheadline)
                        .fontWeight(isCurrentTab ? .semibold : .regular)
                        .frame(width: UIScreen.screenWidth * 0.2, height: 40)
                        .background {
                            Rectangle()
                                .fill(.gray.opacity(isCurrentTab ? 0.2 : 0.0))
                                .overlay(alignment: .bottom) {
                                    Rectangle()
                                        .fill(isCurrentTab ? Color("buttonColor") : Color.clear)
                                        .frame(height: 1)
                                }
                        }
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentTab = stance
                    }
                }
            }
        }
    }
    
    func trickListByStance(trickListByStance: [Trick]) -> some View {
        VStack {
            if trickListByStance.isEmpty {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("No tricks available...")
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                ForEach(trickListByStance) { trick in
                    Button {
                        router.push(.selectTrickItem(user: user, trick: trick))
                    } label: {
                        HStack {
                            Text(trickDisplayName(trick))
                            
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding(.vertical, 5)
                    }
                    
                    if trick != trickListByStance.last! {
                        Divider()
                    }
                }
            }
        }
    }
}
