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
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = SelectTrickViewModel()
    
    @Binding var uploadPostPath: NavigationPath
    let user: User
    
    @State private var tabIndex: Int = 0
    private let tabs: [String] = [ "Regular", "Fakie", "Switch", "Nollie" ]
    
    var body: some View {
        VStack {
            // Custom Navigation Bar
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
                Spacer()
                Text("Select a Trick")
                Spacer()
            }
            .padding(10)
            .background(Color(.systemBackground))
            
            switch viewModel.fetchTrickListState {
            case .idle:
                VStack { }
                    .onAppear {
                        Task {
                            await viewModel.fetchTricksWithTrickItems(userId: user.userId)
                        }
                    }
                
            case .loading:
                CustomProgressView(placement: .center)
                
            case .success:
                if viewModel.trickList.isEmpty {
                    ContentUnavailableView(
                        "No Trick Items Found",
                        systemImage: "exclamationmark.triangle",
                        description: Text("Please upload a trick item for a trick in order to turn it into a post.")
                    )
                } else {
                    ScrollView {
                        VStack {
                            // Instructions for user
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
                            .background(RoundedRectangle(cornerRadius: 10).fill(.gray.opacity(0.2)))
                            .padding(10)
                            
                            Divider()
                            
                            // Organizes the trick list differently depending on the number of tricks fetched
                            if viewModel.trickList.count <= 10 {
                                plainTrickList
                                
                            } else if viewModel.trickList.count <= 18 {
                                semiSortedTrickList
                                
                            } else {
                                sortedTrickList
                            }
                        }
                    }
                }
                
            case .failure(let firestoreError):
                ContentUnavailableView(
                    "Error Fetching Tricks",
                    systemImage: "exclamationmark.triangle",
                    description: Text(firestoreError.errorDescription ?? "")
                )
            }
        }
    }
        
    /// Simply lists all the tricks in one vertical list. Navigates to the SelectTrickItem view for a trick when selected.
    ///
    var plainTrickList: some View {
        VStack {
            ForEach(viewModel.trickList) { trick in
                Button {
                    uploadPostPath.append(UploadPostRoutes.selectTrickItem(user: user, trick: trick))
                } label: {
                    HStack {
                        Text(trick.name)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding(.vertical, 5)
                }
                .foregroundColor(.primary)
                
                Divider()
            }
        }
        .padding()
    }
    
    /// Lists all the tricks in one vertical list and separated by stance. Navigates to the SelectTrickItem view for a trick when selected.
    ///
    var semiSortedTrickList: some View {
        VStack(alignment: .leading) {
            let sortedTrickList = viewModel.sortTrickListByStance()
            
            ForEach(sortedTrickList) { listByStance in
                Text(listByStance.stance)
                    .foregroundStyle(.gray)
                
                ForEach(listByStance.tricks) { trick in
                    Button {
                        uploadPostPath.append(UploadPostRoutes.selectTrickItem(user: user, trick: trick))
                    } label: {
                        HStack {
                            Text(trick.name)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding(.vertical, 5)
                    }
                    .foregroundColor(.primary)
                    
                    Divider()
                }
            }
        }
        .padding()
    }
    
    /// Lists all the tricks in four separate vertical lists sepearated by stance. Contains a tab selector for selecting the stance.
    ///
    var sortedTrickList: some View {
        VStack {
            stanceTabSelector
            
            Divider()

            let sortedTrickList = viewModel.sortTrickListByStance()
            
            switch(tabIndex) {
            case 0:
                trickListByStance(trickListByStance: sortedTrickList[0].tricks)
            case 1:
                trickListByStance(trickListByStance: sortedTrickList[1].tricks)
            case 2:
                trickListByStance(trickListByStance: sortedTrickList[2].tricks)
            case 3:
                trickListByStance(trickListByStance: sortedTrickList[3].tricks)
            default:
                Text("No Tricks")
            }
        }
        .padding()
    }
    
    /// Tab selector for the sorted trick list. Updates the list with animations.
    ///
    var stanceTabSelector: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                let index = tabs.firstIndex(of: tab)
                let isCurrentTab = index == tabIndex
                                    
                VStack {
                    Text(tab)
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
                        if let index = index { self.tabIndex = index }
                    }
                }
            }
        }
    }
    
    /// Displays all the trick for a specific stance. Navigates to the SelectTrickItem view for a trick when selected.
    @ViewBuilder
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
                        uploadPostPath.append(UploadPostRoutes.selectTrickItem(user: user, trick: trick))
                    } label: {
                        HStack {
                            Text(trick.name)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding(.vertical, 5)
                    }
                    .foregroundColor(.primary)
                    
                    Divider()
                }
            }
        }
    }
}
