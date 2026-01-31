//
//  AccountSearchView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import SwiftUI

///
/// Struct that displays the account searching feature to the user.
///
struct AccountSearchView: View {
    @StateObject var viewModel = AccountSearchViewModel()
    @State private var delayedWorkItem: DispatchWorkItem?
    
    // Dismisses the current view when called
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            searchBar

            Divider()
            
            searchResults
            
            Spacer()
        }
        .padding()
        .onChange(of: viewModel.search) { oldValue, newValue in
            // Minimum string length to query users with is 2
            guard newValue.count >= 2 else { return }
            viewModel.isSearching = true
            // Cancles the previous fetch if it was in progress or scheduled during the 0.3 second delay window
            delayedWorkItem?.cancel()
            
            // Adds a slightly higher delay for backspacing because users type faster then they can backspace
            let delay = newValue.count > oldValue.count ? 0.3 : 0.6
            let workItem = DispatchWorkItem {
                Task {
                    viewModel.resetSearch()
                    await viewModel.searchAfterDelay(usernamePrefix: newValue)
                    let _ = print(newValue)
                }
            }
            delayedWorkItem = workItem
            // Executes search function after 0.3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
        }
        .customNavBarItems(title: "Account Search", subtitle: "", backButtonHidden: false)
    }
    
    var searchBar: some View {
        ZStack {
            // Search bar
            TextField(viewModel.search, text: $viewModel.search, prompt: Text("Username"))
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .lineLimit(1)
                .foregroundColor(.primary)
            
            // Clear search bar button
            HStack {
                Spacer()
                
                Button {
                    viewModel.search = ""
                } label: {
                    Image(systemName: "x.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(.gray.opacity(0.2))
                .stroke(.gray.opacity(0.5))
        }
        .cornerRadius(10)
        .padding(8)
    }
    
    @ViewBuilder
    var searchResults: some View {
        if viewModel.isSearching {
            CustomProgressView(placement: .center)
            
        } else if viewModel.search.count < 2 {
            VStack {
                Text("Enter Username")
                    .font(.subheadline)
                Text("A mimimum of 2 characters is required to search.")
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
            
        } else if viewModel.foundUsers.isEmpty {
            VStack {
                Text("No users matching:")
                    .font(.subheadline)
                Text("'\(viewModel.search)'")
                    .font(.title3)
                    .fontWeight(.medium)
            }
                        
        } else {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.foundUsers) { user in
                        AccountCell(user: user)
                        
                        Divider()
                    }
                    Spacer()
                }
            }
        }
    }
}
