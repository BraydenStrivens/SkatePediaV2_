//
//  CompareView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import SwiftUI
import AVKit
import Kingfisher

struct CompareView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @State var toggleEditNotes: Bool = false
    
    @ObservedObject var viewModel: CompareViewModel
    
    let trickData: TrickData
    let trickItem: TrickItem?
    let proVideo: ProSkaterVideo?
    
    init(
        trickData: TrickData,
        trickItem: TrickItem? = nil,
        proVideo: ProSkaterVideo? = nil,
        viewModel: CompareViewModel
    ) {
        self.trickData = trickData
        self.trickItem = trickItem
        self.proVideo = proVideo
        
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                selectVideoView
                
                if let leftVideo = viewModel.leftVideo {
                    if case .trickItem = leftVideo {
                        editTrickItemView
                    }
                }
                
                VStack {
                    Spacer()
                    
                    HStack(alignment: .bottom, spacing: 10) {
                        videoPlayer1View
                        
                        videoPlayer2View
                    }
                    
                    Spacer()
                    
                    if let _ = viewModel.leftVideo, let _ = viewModel.rightVideo {
                        DuelPlaybackControls(
                            controller: viewModel.controller,
                            frameSize: CGSize(width: UIScreen.screenWidth, height: 50)
                        )
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
        .padding(8)
        .frame(width: UIScreen.screenWidth)
        .onChange(of: viewModel.leftVideo) { (oldValue: CompareVideo?, newValue: CompareVideo?) in
            if let newValue {
                viewModel.setVideo(newValue, for: .left)
            }
        }
        .onChange(of: viewModel.rightVideo) { (oldValue: CompareVideo?, newValue: CompareVideo?) in
            if let newValue {
                viewModel.setVideo(newValue, for: .right)
            }
        }
        .fullScreenCover(item: $viewModel.activeSlot, content: { slot in
            SelectCompareVideoSheet(
                trickId: trickData.trickId,
                initialSelection: viewModel.activeSlot == .left ? viewModel.leftVideo : viewModel.rightVideo,
                defaultTabIndex: viewModel.activeSlot == .left ? 0 : 1,
                onContinue: { selectedVideo in
                    switch slot {
                    case .left:
                        viewModel.leftVideo = selectedVideo
                    case .right:
                        viewModel.rightVideo = selectedVideo
                    }
                    viewModel.activeSlot = nil
                },
                onCancel: {
                    viewModel.activeSlot = nil
                }
            )
        })
    }
    
    var selectVideoView: some View {
        HStack {
            HStack {
                Text("Video 1:")
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Button {
                    viewModel.activeSlot = .left
                } label: {
                    if viewModel.leftVideo == nil {
                        Image(systemName: "plus")
                    } else {
                        Text("Change")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 12)
                    .coloredProtruded(color: Color.button)
                )
            }
            .frame(maxWidth: .infinity)
                        
            HStack {
                Text("Video 2:")
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Button {
                    viewModel.activeSlot = .right
                } label: {
                    if viewModel.rightVideo == nil {
                        Image(systemName: "plus")
                    } else {
                        Text("Change")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 12)
                    .coloredProtruded(color: Color.button)
                )
            }
            .frame(maxWidth: .infinity)
        }
        .padding(8)
        .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 12).protruded)
    }
    
    var editTrickItemView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Update Notes:")
                    .foregroundStyle(.gray)
                
                Spacer()
                
                if toggleEditNotes {
                    Button {
                        // TODO: FINISH
                        Task {
                            await viewModel.updateTrickItemNotes(trickItemId: viewModel.leftVideo?.id ?? "")
                            withAnimation(.easeInOut(duration: 0.2)) {
                                toggleEditNotes = false
                            }
                        }

                    } label: {
                        Text("Save")
                            .foregroundStyle(viewModel.trickItem?.notes == viewModel.updatedTrickItemNotes
                                             ? Color.gray
                                             : .primary
                            )
                    }
                    .disabled(viewModel.trickItem?.notes == viewModel.updatedTrickItemNotes)
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            toggleEditNotes = false
                        }
                        viewModel.updatedTrickItemNotes = viewModel.trickItem?.notes ?? ""
                    } label: {
                        Text("Cancel")
                            .foregroundStyle(.gray)
                    }
                    
                } else {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            toggleEditNotes = true
                        }
                    } label: {
                        Text("Edit")
                            .foregroundStyle(.gray)
                    }
                }
            }
            .font(.callout)
            
            Group {
                if toggleEditNotes {
                    TextField("Update notes", text: $viewModel.updatedTrickItemNotes, axis: .vertical)
                        .lineLimit(1...4)
                        .offset(x: 10)
                    
                } else {
                    CollapsibleTextView(text: viewModel.leftVideo?.trickItem?.notes ?? "", lineLimit: 3, font: .body)
                        .offset(x: 10)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 12).protruded)
        }
    }
    
    var videoPlayer1View: some View {
        GeometryReader { proxy in
            if
                let leftVideo = viewModel.leftVideo,
                let leftPlayer = viewModel.leftPlayer,
                let leftPlayerVM = viewModel.leftPlayerVM
            {
                let size = CustomVideoPlayer.getNewAspectRatio(
                    baseWidth: leftVideo.size.width,
                    baseHeight: leftVideo.size.height,
                    maxWidth: proxy.size.width,
                    maxHeight: proxy.size.height
                )
                
                SPVideoPlayer2(
                    userPlayer: leftPlayer,
                    viewModel: leftPlayerVM,
                    controller: viewModel.controller,
                    frameSize: proxy.size,
                    videoSize: size,
                    buttonType: .simple
                )
            } else {
                noVideoSelectedView
            }
        }
        .frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.45)
    }
    
    var videoPlayer2View: some View {
        GeometryReader { proxy in
            if
                let rightVideo = viewModel.rightVideo,
                let rightPlayer = viewModel.rightPlayer,
                let rightPlayerVM = viewModel.rightPlayerVM
            {
                let size = CustomVideoPlayer.getNewAspectRatio(
                    baseWidth: rightVideo.size.width,
                    baseHeight: rightVideo.size.height,
                    maxWidth: proxy.size.width,
                    maxHeight: proxy.size.height
                )
                
                SPVideoPlayer2(
                    userPlayer: rightPlayer,
                    viewModel: rightPlayerVM,
                    controller: viewModel.controller,
                    frameSize: proxy.size,
                    videoSize: size,
                    buttonType: .simple
                )
            } else {
                noVideoSelectedView
            }
        }
        .frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenHeight * 0.45)
    }
    
    var noVideoSelectedView: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("Please select trick item or pro video")
                    .multilineTextAlignment(.center)
                Spacer()
            }
            Spacer()
        }
        .background {
            Rectangle()
                .fill(.gray.opacity(0.15))
        }
    }
}
