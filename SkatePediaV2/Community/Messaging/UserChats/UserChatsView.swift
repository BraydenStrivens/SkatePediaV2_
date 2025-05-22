//
//  MessagesView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import SwiftUI

struct UserChatsView: View {
    @StateObject var viewModel = UserChatsViewModel()
    
    var body: some View {
        VStack(spacing: 10) {
            messagesHeader
                        
            Divider()
            
            messages
            
            Spacer()
        }
        .customNavBarItems(title: "Messages", subtitle: "", backButtonHidden: false)
        .padding()
    }
    
    var messagesHeader: some View {
        HStack(spacing: 10) {
            ZStack {
                TextField(viewModel.searchString.isEmpty ? "Search" : viewModel.searchString, text: $viewModel.searchString)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                HStack {
                    Spacer()
                    
                    Button {
                        viewModel.searchString = ""
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
                        
            CustomNavLink(destination: NewMessageView()) {
                Image(systemName: "plus")
                    .resizable()
                    .foregroundColor(.primary)
                    .frame(width: 20, height: 20)
            }
        }
    }
    
    var messages: some View {
        LazyVStack {
            ScrollView(showsIndicators: false) {
                if viewModel.chattingWithUsers.isEmpty {
                    if viewModel.isFetching {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        HStack {
                            Spacer()
                            Text("No Messages...")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .padding(.top, 20)
                            Spacer()
                        }
                    }
                } else {
                    ForEach(viewModel.chattingWithUsers) { user in
                        if viewModel.searchString.isEmpty {
                            NewMessageCell(user: user)
                            Divider()
                        } else {
                            if viewModel.matchesFilter(user: user) {
                                NewMessageCell(user: user)
                                Divider()
                            } else {
                                HStack {
                                    Spacer()
                                    VStack {
                                        Text("No messages from users starting with")
                                            .font(.body)
                                        Text("\"\(viewModel.searchString)\"")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.primary)

                                    Spacer()
                                }
                                .padding(.top, 20)
                            }
                        }
                    }
                }
                
            }
        }
    }
}
