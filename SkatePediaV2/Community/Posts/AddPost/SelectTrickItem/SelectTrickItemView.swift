//
//  SelectTrickItemView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 1/15/26.
//

import SwiftUI
import AVKit

/// Displays all the trick items for the selected trick. Navigates to the AddPostView when a trick item is selected and the continue button is pressed.
///
/// - Parameters:
///  - uploadPostPath:The current navigation path within the navigation stack for views related to uploading a post.
///  - user: A 'User' object containing information about the current user.
///  - trick: A 'Trick' object containing information about the selected trick.
///
struct SelectTrickItemView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = SelectTrickItemViewModel()
    
    @EnvironmentObject var communityViewModel: CommunityViewModel
    @Binding var uploadPostPath: NavigationPath
    
    let user: User
    let trick: Trick
        
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
                Text("Select a Trick Item")
                Spacer()
            }
            .padding(10)
            .background(Color(.systemBackground))
            
            switch viewModel.trickItemFetchState {
            case .idle:
                VStack { }
                    .onAppear {
                        Task {
                            await viewModel.fetchTrickItemsForTrick(userId: user.userId, trickId: trick.id)
                        }
                    }
                
            case .loading:
                CustomProgressView(placement: .center)
                
            case .success:
                VStack {
                    if viewModel.trickItems.isEmpty {
                        ContentUnavailableView(
                            "No Trick Items",
                            systemImage: "exclamationmark.triangle",
                            description: Text("No trick items have been uploaded for \(trick.name)")
                        )
                        
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                ForEach(viewModel.trickItems) { trickItem in
                                    SelectTrickItemCellToPost(user: user, trickItem: trickItem)
                                        .environmentObject(viewModel)
                                        .onTapGesture {
                                            withAnimation(.easeInOut(duration: 0.25)) {
                                                // Selects or de-selects trick items on tap
                                                if trickItem != viewModel.selectedTrickItem {
                                                    viewModel.selectedTrickItem = trickItem
                                                } else {
                                                    viewModel.selectedTrickItem = nil
                                                }
                                            }
                                        }
                                    Divider()
                                }
                            }
                        }
                        .zIndex(1)
                        .overlay(alignment: .bottom) {
                            // Continue button popup, appears when a trick item is selected
                            if let selectedTrickItem = viewModel.selectedTrickItem {
                                HStack(alignment: .center) {
                                    Spacer()
                                    Button {
                                        // Navigates to the AddPostView
                                        uploadPostPath.append(
                                            UploadPostRoutes.uploadPost(user: user, trick: trick, trickItem: selectedTrickItem)
                                        )
                                    } label: {
                                        HStack {
                                            Text("Continue")
                                            Image(systemName: "chevron.right")
                                        }
                                    }
                                    .frame(width: 150, height: 40)
                                    .foregroundStyle(.primary)
                                    .background {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color("buttonColor"))
                                    }
                                    .padding()
                                    .zIndex(3)
                                }
                                .background(Color(uiColor: .systemBackground).opacity(0.85))
                                .zIndex(2)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                    }
                }
                .navigationTitle("Select a Trick Item")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.primary)
                        }
                    }
                }
                
            case .failure(let firestoreError):
                ContentUnavailableView(
                    "Error Fetching Trick Items",
                    systemImage: "exclamationmark.triangle",
                    description: Text(firestoreError.errorDescription ?? "")
                )
            }
        }
    }
}

