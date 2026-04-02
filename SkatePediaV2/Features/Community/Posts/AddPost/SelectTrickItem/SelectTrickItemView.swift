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
    
    @Binding var uploadPostPath: NavigationPath
    let user: User
    let trick: Trick
        
    var body: some View {
        Group {
            switch viewModel.trickItemFetchState {
            case .idle, .loading:
                CustomProgressView(placement: .center)
                
            case .success:
                if viewModel.trickItems.isEmpty {
                    ContentUnavailableView(
                        "No Trick Items",
                        systemImage: "exclamationmark.triangle",
                        description: Text("No trick items have been uploaded for \(trick.name)")
                    )
                    
                } else {
                    trickItemSelectionList
                        .zIndex(1)
                        .overlay(alignment: .bottom) {
                            continueButtonOverlay
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
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Select a Trick Item")
                        .fontWeight(.semibold)
                    
                    Group {
                        if user.settings.trickSettings.useTrickAbbreviations {
                            Text(trick.abbreviation)
                        } else {
                            Text(trick.name)
                        }
                    }
                    .font(.caption)
                }
            }
        }
        .task {
            await viewModel.fetchTrickItemsForTrick(
                userId: user.userId,
                trickId: trick.id
            )
        }
    }
    
    var trickItemSelectionList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(viewModel.trickItems) { trickItem in
                    SelectTrickItemCellToPost(user: user, trickItem: trickItem)
                        .environmentObject(viewModel)
                        .scrollTargetLayout()
                        .containerRelativeFrame(
                            .vertical,
                            count: 1,
                            span: 1,
                            spacing: 0
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if trickItem != viewModel.selectedTrickItem {
                                    viewModel.selectedTrickItem = trickItem
                                } else {
                                    viewModel.selectedTrickItem = nil
                                }
                            }
                        }
                }
            }
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
    }
    
    @ViewBuilder
    var continueButtonOverlay: some View {
        if let selectedTrickItem = viewModel.selectedTrickItem {
            HStack(alignment: .center) {
                Spacer()
                Button {
                    uploadPostPath.append(
                        UploadPostRoutes.addPost(
                            user: user,
                            trick: trick,
                            trickItem: selectedTrickItem
                        )
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
            .background(.ultraThinMaterial)
            .zIndex(2)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

