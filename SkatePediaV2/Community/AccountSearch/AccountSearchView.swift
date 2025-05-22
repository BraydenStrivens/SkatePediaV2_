//
//  AccountSearchView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import SwiftUI

struct AccountSearchView: View {
    @StateObject var viewModel = AccountSearchViewModel()
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            searchBar

            Divider()
            
            searchResults
        }
        .padding()
        .onChange(of: viewModel.search) {
            viewModel.clearFoundUsers()
            Task {
                try await viewModel.searchUsers()
            }
        }
        .customNavBarItems(title: "Account Search", subtitle: "", backButtonHidden: false)
    }
    
    var searchBar: some View {
        ZStack {
            TextField(viewModel.search.isEmpty ? "Search" : viewModel.search, text: $viewModel.search)
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
                Spacer()
                Text("No users matching:")
                    .foregroundColor(.primary)
                    .font(.subheadline)
                Text("'\(viewModel.search)'")
                    .foregroundColor(.primary)
                    .font(.headline)
                Spacer()
                
            } else {
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

//#Preview {
//    AccountSearchView()
//}
