//
//  AddPostView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/28/25.
//

import SwiftUI
import PhotosUI
import AVKit


struct AddPostView: View {
    @StateObject var viewModel = AddPostViewModel()
    @State var showSelectTrickView: Bool = false
    @State var showVideoPreview: Bool = false
    @State var isUploading: Bool = false
    @Binding var newPost: Post?
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            uploadButton
            
            contentSection
            
            Divider()
            
            selectTrickSection
            
            Divider()
            
            addVideoSection
            
            Divider()
            
            videoPreview
            
            Spacer()
        }
        .customNavBarItems(title: "Upload Post", subtitle: "", backButtonHidden: false)
        .padding()
        .sheet(isPresented: $showSelectTrickView, onDismiss: {
            showSelectTrickView = false
        }, content: {
            SelectTrickView(selectedTrick: $viewModel.selectedTrick)
        })
    }
    
    var uploadButton: some View {
        // Upload post button
        HStack {
            Spacer()
            
            Button {
                Task {
                    isUploading = true
                    self.newPost = try await viewModel.uploadPost()
                    isUploading = false
                    dismiss()
                }
            } label: {
                if isUploading {
                    ProgressView()
                } else {
                    Text("Upload")
                }
            }
            .foregroundColor(.primary.opacity(viewModel.isValidInput() ? 1.0 : 0.3))
            .disabled(!viewModel.isValidInput())
        }
    }
    
    var contentSection: some View {
        // Type content
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .top) {
                
                
                TextField("Content:", text: $viewModel.content, axis: .vertical)
                    .autocorrectionDisabled()
                    .lineLimit(3...5)
                    .foregroundColor(.primary)
            }
            .padding()
            .background {
                Rectangle()
                    .fill(.gray.opacity(0.08))
                    .stroke(.primary.opacity(0.2), lineWidth: 1)
            }
        }
    }
    
    var selectTrickSection: some View {
        // Select Trick
        HStack(spacing: 10) {
            Text("Trick:")
                .foregroundColor(.gray)
            
            Spacer()
            
            if let trick = viewModel.selectedTrick {
                Text(trick.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Button {
                    showSelectTrickView = true
                } label: {
                    Image(systemName: "pencil")
                        .foregroundColor(.primary)
                }
            } else {
                Button {
                    showSelectTrickView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    var addVideoSection: some View {
        HStack {
            Text("Video:")
                .foregroundColor(.gray)
            
            Spacer()
            
            VStack {
                PhotosPicker(selection: $viewModel.selectedItem,
                             matching: .any(of: [.not(.images), .videos, .slomoVideos])
                ) {
                    Image(systemName:
                            viewModel.selectedItem != nil ? "pencil" : "plus")
                }
                //
            }
            .onChange(of: viewModel.selectedItem) { oldValue, newValue in
                Task {
                    do {
                        viewModel.loadState = .loading
                        
                        if let video = try await viewModel.selectedItem?
                            .loadTransferable(type: PreviewVideo.self) {
                            showVideoPreview = true
                            viewModel.loadState = .loaded(video)
                        } else {
                            viewModel.loadState = .failed
                        }
                    } catch {
                        viewModel.loadState = .failed
                    }
                }
            }
        }
    }
    
    var videoPreview: some View {
        // Video Preview
        HStack {
            Spacer()
            
            switch viewModel.loadState {
            case .unknown:
                EmptyView()
            case .loading:
                ProgressView()
            case .loaded(let video):
                VideoPlayer(player: AVPlayer(url: video.url))
                    .scaledToFit()
                    .frame(width: UIScreen.screenWidth * 0.8)
            case .failed:
                Text("Import failed")
            }
            Spacer()
        }
    }
}
