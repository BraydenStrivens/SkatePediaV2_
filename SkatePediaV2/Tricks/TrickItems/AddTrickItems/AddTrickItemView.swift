//
//  AddTrickItemView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import SwiftUI
import PhotosUI
import AVKit
import Kingfisher

/// Defines the layout of items in the 'AddTrickItem' view.
///
/// - Parameters:
///  - userId: The id of an account in the database.
///  - trick: A 'JsonTrick' object containing data about the trick the trick item is for.
struct AddTrickItemView: View {
    let userId: String
    let trick: Trick
    @Binding var trickItems: [TrickItem]
    
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel = AddTrickItemViewModel()
    @State var fillStars = [false, false, false]
    @State private var toggleVideoPreview = false
    @State private var isUploading = false
        

    
    var body: some View {
        VStack {
            // Upload button
            uploadButton
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    
                    // Notes section
                    notesSection
                    
                    // Rate Progress Section
                    rateProgressSection
                    
                    // Add user video
                    addVideoSection
                    
                    // Input validation and trick item upload
                    VStack(alignment: .center) {
                        HStack { Spacer() }
                        
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .foregroundColor(Color.red)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .sheet(isPresented: $toggleVideoPreview, onDismiss: {
                    toggleVideoPreview = false
                }, content: {
                    videoPreviewSheet
                })
            }
        }
    }
    
    var uploadButton: some View {
        HStack {
            let validInput = viewModel.validateInput()
            
            Spacer()
            
            Button {
                for value in fillStars {
                    if value { viewModel.progress += 1 }
                }
                
                Task {
                    isUploading = true
                    let newTrickItem = try await viewModel.addTrickItem(userId: userId, trick: trick)
                    if let newItem = newTrickItem { self.trickItems.insert(newItem, at: 0) }
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
            .padding()
            .foregroundColor(validInput ? .primary : .gray.opacity(0.6))
            .disabled(!validInput || isUploading)
        }
    }
    
    var notesSection: some View {
        VStack(alignment: .leading) {
            Text("Notes:")
                .foregroundColor(.gray)
            
            VStack {
                TextField("", text: $viewModel.notes, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...5)
                    .autocorrectionDisabled()
            }
            .background(Color(uiColor: UIColor.systemBackground))
            .shadow(color: .gray.opacity(0.25), radius: 5, x: 0, y: 2)
        }
    }
    
    var rateProgressSection: some View {
        VStack(alignment: .leading) {
            Text("Progress:")
                .foregroundColor(.gray)
            
            HStack() {
                Spacer()
                
                Button {
                    fillStars[0] = fillStars[1] ? fillStars[0] : !fillStars[0]
                    fillStars[1] = false
                    fillStars[2] = false
                } label: {
                    Image(systemName: fillStars[0]  ? "star.fill" : "star")
                        .foregroundColor(fillStars[0] ? .yellow : .primary)
                }
                
                Button {
                    fillStars[0] = true
                    fillStars[1] = fillStars[2] ? fillStars[1] : !fillStars[1]
                    fillStars[2] = false
                } label: {
                    Image(systemName: fillStars[1]  ? "star.fill" : "star")
                        .foregroundColor(fillStars[1] ? .yellow : .primary)
                }
                .padding(.leading)
                .padding(.trailing)
                
                Button {
                    fillStars[0] = true
                    fillStars[1] = true
                    fillStars[2] = !fillStars[2]
                } label: {
                    Image(systemName: fillStars[2]  ? "star.fill" : "star")
                        .foregroundColor(fillStars[2] ? .yellow : .primary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(uiColor: UIColor.systemBackground))
            .shadow(color: .gray.opacity(0.25), radius: 5, x: 0, y: 2)
        }
    }
    
    var addVideoSection: some View {
        VStack(alignment: .center) {
            HStack {
                Text("Add Video: ")
                    .foregroundColor(.gray)
                
                Spacer()
                
                PhotosPicker(selection: $viewModel.selectedItem,
                             matching: .any(of: [.not(.images), .videos, .slomoVideos])) {
                    
                    if viewModel.selectedAVideo {
                        Text("Change")
                            .foregroundColor(.blue)
                    } else {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                    }
                }
            }
            .onChange(of: viewModel.selectedItem) {
                if viewModel.selectedItem != nil {
                    toggleVideoPreview = true
                    
                    Task {
                        do {
                            viewModel.loadState = .loading
                            
                            if let video = try await viewModel.selectedItem?
                                .loadTransferable(type: PreviewVideo.self) {
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

            if let image = viewModel.previewThumbnail {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: UIScreen.screenHeight * 0.4)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .onTapGesture {
                        toggleVideoPreview = true
                    }
            }
        }
    }
    
    var videoPreviewSheet: some View {
        NavigationStack {
            VStack(alignment: .center) {
                switch viewModel.loadState {
                case .unknown:
                    EmptyView()
                    
                case .loading:
                    ProgressView()
                    
                case .loaded(let video):
                    let previewVideo = AVPlayer(url: video.url)
                    let _ = viewModel.generateThumbnail(previewVideo: previewVideo)
                    
                    VideoPlayer(player: AVPlayer(url: video.url))
                        .scaledToFit()
                        .frame(width: UIScreen.screenWidth * 0.95)
                    
                case .failed:
                    Text("Failed To Load Video...")
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        toggleVideoPreview = false
                        viewModel.selectedAVideo = false
                        viewModel.selectedItem = nil
                        viewModel.previewThumbnail = nil
                    } label: {
                        Text("Cancel")
                    }
                    .foregroundColor(.primary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.selectedAVideo = true
                        toggleVideoPreview = false
                    } label: {
                        Text("Continue")
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        
    }
}

//#Preview {
//    AddTrickItemView(
//        userId: "",
//        trick: Trick(id: "00000011", name: "Backside Kickflip", stance: "Regular", abbreviation: "BS Flip", learnFirst: "Backside 180, Kickflip", learnFirstAbbreviation: "BS Flip, Kickflip", difficulty: "Intermediate", learned: false, inProgress: false
//                    )
//    )
//}
