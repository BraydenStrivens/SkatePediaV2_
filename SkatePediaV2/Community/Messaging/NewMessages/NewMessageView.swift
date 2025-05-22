//
//  NewMessageView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/3/25.
//

import SwiftUI

struct NewMessageView: View {
    @StateObject var viewModel = NewMessageViewModel()
    
    var body: some View {
        VStack {
            searchBar
            
            Divider()
            
            searchResults
            
            Spacer()
        }
        .customNavBarItems(title: "New Message", subtitle: "", backButtonHidden: false)
        .padding(.horizontal)
        .onChange(of: viewModel.search) {
            viewModel.clearFoundUsers()
            Task {
                try await viewModel.searchUsers()
            }
            
        }
    }
    
    var searchBar: some View {
        ZStack {
            TextField(viewModel.search.isEmpty ? "Search Users" : viewModel.search, text: $viewModel.search)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .lineLimit(1)
                .foregroundColor(.primary)
            
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
    
    var searchResults: some View {
        ScrollView {
            if viewModel.search.isEmpty {
                Spacer()
                Text("Enter Username")
                    .foregroundColor(.primary)
                    .font(.subheadline)
                Spacer()
                
            } else if viewModel.foundUsers.isEmpty {
                if viewModel.isSearching {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    Spacer()
                    Text("No users matching:")
                        .foregroundColor(.primary)
                        .font(.subheadline)
                    Text("'\(viewModel.search)'")
                        .foregroundColor(.primary)
                        .font(.headline)
                    Spacer()
                }
                
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.foundUsers) { user in
                        NewMessageCell(user: user)
                        Divider()
                    }
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    NewMessageView()
}
