//
//  SelectProVideoSheet.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/17/25.
//

import SwiftUI
import AVKit

struct SelectProVideoView: View {
    @StateObject var viewModel = SelectProVideoViewModel()
    @Environment(\.dismiss) var dismiss
    @State var selectedVideo: ProSkaterVideo? = nil
    
    @Binding var selectedProVideo: ProSkaterVideo?
    let trickId: String
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if viewModel.loading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        if viewModel.proVideos.isEmpty {
                            HStack {
                                Spacer()
                                Text("Pro Videos are not available for this trick...")
                                    .foregroundColor(.primary)
                                    .offset(y: 50)
                                Spacer()
                            }
                        } else {
                            ForEach(viewModel.proVideos) { video in
                                SelectProVideoCell(video: video, selectedVideo: $selectedVideo)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Pro Video")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.primary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        self.selectedProVideo = selectedVideo
                        dismiss()
                    } label: {
                        Text("Continue")
                            .foregroundColor(.primary.opacity(selectedVideo == nil ? 0.4 : 1))
                    }
                    .disabled(selectedVideo == nil)
                }
            }
            .onFirstAppear {
                Task {
                    if !viewModel.fetched { try await viewModel.fetchProVideosForTrick(trickId: trickId) }
                    print("FETCHED")
                    print(viewModel.proVideos.count)
                }
            }
        }
        
    }
}

