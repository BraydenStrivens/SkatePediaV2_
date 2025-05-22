//
//  ChatView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import SwiftUI
import PhotosUI
import FirebaseAuth
import AVKit

struct ChatMessagesView: View {
    let chattingWith: User
    
    init(chattingWith: User) {
        self.chattingWith = chattingWith
        self.viewModel = .init(chattingWith: chattingWith)
    }
    
    @ObservedObject var viewModel: ChatMessagesViewModel

    var body: some View {
        VStack {
            messages
        }
        .onFirstAppear({
            if viewModel.listener == nil {
                print("LISTENER ADDED")
                viewModel.addListenerToMessages()
            }
        })
//        .onDisappear(perform: {
//            if viewModel.isFetched {
//                print("LISTENER REMOVED")
//                viewModel.removeListener()
//            }
//        })
        .customNavBarItems(title: chattingWith.username, subtitle: "", backButtonHidden: false)
        .onChange(of: viewModel.newMessageFile) {
            if let item = viewModel.newMessageFile {
                if (item.supportedContentTypes.contains(where: { type in type.isSubtype(of: .audiovisualContent)})) {
                    Task {
                        do {
                            viewModel.loadState = .loading
                            
                            if let video = try await item
                                .loadTransferable(type: PreviewVideo.self) {
                                viewModel.loadState = .loaded(video)
                            } else {
                                viewModel.loadState = .failed
                            }
                        } catch {
                            viewModel.loadState = .failed
                        }
                        viewModel.fileType = .video
                    }
                } else {
                    Task {
                        await viewModel.loadImage()
                        viewModel.fileType = .photo
                    }
                }
            }
        }
    }
    
    var messages: some View {
        ScrollView {
            ScrollViewReader { scrollViewProxy in
                LazyVStack {
                    if viewModel.messages.isEmpty {
                        HStack {
                            Spacer()
                            Text("No Messages...")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .padding(.bottom, 20)
                            Spacer()
                        }
                    } else {
                        ForEach(viewModel.messages) { message in
                            
                            ChatMessageCell(message: message)
                                .contextMenu {
                                    if message.fromUserId == Auth.auth().currentUser?.uid {
                                        VStack {
                                            Button(role: .destructive) {
                                                Task {
                                                    try await viewModel.deleteMessage(message: message)
                                                }
                                            } label: {
                                                Image(systemName: "trash")
                                                    .resizable()
                                                    .frame(width: 15, height: 15)
                                                Text("Delete")
                                                    .font(.body)
                                            }
                                        }
                                    }
                                }
                        }
                        HStack { Spacer() }
                            .id("bottom")
                        
                    }
                }
                .onReceive(viewModel.$count) { _ in
                    withAnimation(.easeInOut(duration: 0.5)) {
                        scrollViewProxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }
            
        }
        .padding(.horizontal, 6)
        .defaultScrollAnchor(.bottom)
        .overlay(alignment: .bottomLeading) {
            if viewModel.newMessageFile != nil {
                VStack(spacing: 0) {
                                        
                    filePreview
                        .padding(.leading, 8)
                        .overlay(alignment: .topTrailing) {
                            Button {
                                viewModel.newMessageFile = nil
                            } label: {
                                Image(systemName: "x.circle")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.blue)
                                    .brightness(0.5)
                            }
                            .padding(6)
                        }
                }
                .zIndex(100)
            }
        }
        .safeAreaInset(edge: .bottom) {
            sendMessageBox
                .background(Color(.systemBackground))
        }
    }
    
    var filePreview: some View {
        VStack() {
            if let item = viewModel.newMessageFile {
                if (item.supportedContentTypes.contains(where: { type in type.isSubtype(of: .audiovisualContent)})) {
                    videoPreview
                } else {
                    imagePreview
                }
                
            }
        }
    }
    
    var videoPreview: some View {
        VStack(alignment: .center) {
            switch viewModel.loadState {
            case .unknown:
                EmptyView()
                
            case .loading:
                ProgressView()
                
            case .loaded(let video):
                let player = AVPlayer(url: video.url)
                
                VideoPlayer(player: player)
                    .scaledToFit()
                    .frame(width: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
            case .failed:
                Text("Failed To Load Video...")
            }
        }
    }
    
    var imagePreview: some View {
        VStack {
            if let image = viewModel.imageToSend {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    var sendMessageBox: some View {
        VStack {
            HStack(spacing: 10) {
                PhotosPicker(selection: $viewModel.newMessageFile,
                             matching: .any(of: [.images, .videos, .slomoVideos])) {
                    
                    Image(systemName: "paperclip")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
                
                TextField("Message", text: $viewModel.newMessageContent, axis: .vertical)
                    .lineLimit(1...4)
                    .autocorrectionDisabled()
                
                Button {
                    Task {
                        try await viewModel.sendMessage()
                    }
                } label: {
                    if viewModel.isSending {
                        ProgressView()
                    } else {
                        Text("Send")
                    }
                }
                .padding(5)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(.systemBackground))
                        .stroke(.primary)
                }
                .padding(5)
            }
            .foregroundColor(.primary)
            .font(.headline)
            .fontWeight(.regular)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .background {
            RoundedRectangle(cornerRadius: 6)
                .fill(.gray.opacity(0.2))
        }
        .padding(.horizontal, 10)
    }
}

//#Preview {
//    ChatView()
//}
