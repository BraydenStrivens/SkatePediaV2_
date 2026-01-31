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
    @StateObject var viewModel: ChatMessagesViewModel
    
    let currentUser: User
    let withUserData: UserData
    
    init(currentUser: User, withUserData: UserData, userChat: UserChat? = nil) {
        self.currentUser = currentUser
        self.withUserData = withUserData
        _viewModel = StateObject(wrappedValue: ChatMessagesViewModel(
            currentUser: currentUser, withUserData: withUserData, initialUserChat: userChat
        ))
    }
    
    var body: some View {
        Group {
            switch viewModel.chatState {
            case .initializing:
                CustomProgressView(placement: .center)
                
            case .ready(let userChat):
                VStack {
                    messages(userChat: userChat)
                        .zIndex(0)
                        .safeAreaInset(edge: .bottom) {
                            sendMessageBox(userChat: userChat)
                                .zIndex(1)
                                .offset(y: -5)
                        }
                        .safeAreaInset(edge: .top) {
                            
                        }
                }
                .onAppear {
                    Task {
                        await viewModel.addListenerToFirstNMessages(sharedChatId: userChat.chatId)
                        
                        if userChat.unseenMessageCount > 0 {
                            print("How many times did this execute?")
                            await viewModel.updateUserChatUnseenMessages(
                                userId: currentUser.userId,
                                withUserId: withUserData.userId
                            )
                        }
                    }
                }
                .onDisappear {
                    viewModel.removeListenerToFirstNMessage()
                }
            case .failure(let firestoreError):
                ContentUnavailableView(
                    "Error Creating Message Session",
                    systemImage: "exclamationmark.triangle",
                    description: Text(firestoreError.errorDescription ?? "Something went wrong...")
                )
            }
        }
        .onChange(of: viewModel.newMessageFile) { _, newItem in
            Task {
                guard let item = newItem else { return }
                
                if item.supportedContentTypes.contains(.movie) {
                    await viewModel.loadVideo(item: item)
                    
                } else if item.supportedContentTypes.contains(.image) {
                    await viewModel.loadImage(item: item)
                }
            }
        }
        .alert("Error", isPresented: Binding(
                get: { viewModel.error != nil },
                set: { _ in viewModel.error = nil }
               )
        ) {
            Button("OK", role: .cancel) { }

        } message: {
            Text(viewModel.error?.errorDescription ?? "Something went wrong...")
        }
    }
    
    func messages(userChat: UserChat) -> some View {
        Group {
            if viewModel.messages.isEmpty {
                VStack(alignment: .center, spacing: 8) {
                    CircularProfileImageView(photoUrl: withUserData.photoUrl, size: .xLarge)
                        .padding(.top, 30)
                    Text(withUserData.username)
                        .font(.title)
                        .kerning(0.3)
                    Text(withUserData.stance)
                        .font(.title3)
                    Spacer()
                }
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.messages) { message in
                                if showMessage(message: message, userChat: userChat) {
                                    ChatMessageCell(
                                        currentUser: currentUser,
                                        userChat: userChat,
                                        message: message
                                    )
                                    .contextMenu {
                                        messageOptions(message: message, userChat: userChat)
                                    }
                                }
                            }
                            HStack { Spacer() }
                                .id("bottom")
                            
                        }
                    }
                    .onReceive(viewModel.$newMessageCount) { _ in
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
                .padding(.horizontal, 6)
                .defaultScrollAnchor(.bottom)
            }
        }
    }
    
    func messageOptions(message: UserMessage, userChat: UserChat) -> some View {
        VStack {
            Button() {
                Task {
                    await viewModel.hideMessage(
                        sharedChatId: userChat.chatId,
                        hiderId: currentUser.userId,
                        messageId: message.messageId
                    )
                }
            } label: {
                Text("Hide")
                    .font(.body)
            }
            
            if message.fromUserId == Auth.auth().currentUser?.uid {
                VStack {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.deleteMessage(sharedChatId: userChat.chatId, message: message)
                        }
                    } label: {
                        Text("Delete")
                            .font(.body)
                    }
                }
            }
        }
    }
    
    func messageViewHeader(userChat: UserChat) -> some View {
        HStack {
            HStack {
                CircularProfileImageView(photoUrl: withUserData.photoUrl, size: .medium)
                Text(withUserData.username)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            Menu {
                Button("Reset Hidden Messages") {
                    Task {
                        
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
            }

                
        }
    }
    
    func filePreview(item: PhotosPickerItem) -> some View {
        Group {
            if (item.supportedContentTypes.contains(
                where: { type in type.isSubtype(of: .audiovisualContent) }
            )) {
                let _ = print("video")
                videoPreview
            } else {
                let _ = print("image")
                imagePreview
            }
        }
    }
    
    var videoPreview: some View {
        VStack {
            if let url = viewModel.tempVideoUrl {
                let player = AVPlayer(url: url)
                
                VideoPlayer(player: player)
                    .scaledToFit()
                    .frame(width: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                let _ = print("no temp video url")
            }
        }
    }
    
    var imagePreview: some View {
        VStack {
            if let photo = viewModel.photoPreview {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                let _ = print("failed to load image")
            }
        }
    }
    
    func sendMessageBox(userChat: UserChat) -> some View {
        VStack {
            HStack(spacing: 10) {
                PhotosPicker(selection: $viewModel.newMessageFile,
                             matching: .any(of: [.images, .videos, .slomoVideos])) {
                    
                    Image(systemName: "paperclip")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                
                TextField("Message", text: $viewModel.newMessageContent, axis: .vertical)
                    .lineLimit(1...4)
                    .autocorrectionDisabled()
                
                if !viewModel.newMessageContent.isEmpty || viewModel.newMessageFile != nil {
                    Button {
                        Task {
                            await viewModel.sendMessage(userChat: userChat, currentUser: currentUser)
                        }
                    } label: {
                        if viewModel.sendingMessage {
                            CustomProgressView(placement: .center)
                        } else {
                            Text("Send")
                        }
                    }
                    .padding(8)
                    .background {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(.primary)
                    }
                }
            }
            .foregroundColor(.primary)
            .font(.headline)
            .fontWeight(.regular)
        }
        .frame(height: 40)
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
        }
        .padding(.horizontal, 5)
        .safeAreaInset(edge: .top) {
            if let file = viewModel.newMessageFile {
                filePreview(item: file)
                    .zIndex(2)
            }
        }
    }
    
    func showMessage(message: UserMessage, userChat: UserChat) -> Bool {
        // Hides any message the current user has hidden
        if message.hiddenBy.contains(currentUser.userId) {
            return false
        }
        // Hides any message the other user has hidden that belongs to the other user
        if message.fromUserId == userChat.withUserData.userId &&
            message.hiddenBy.contains(userChat.withUserData.userId) {
            return false
        }
        
        if let _ = message.pendingDeletion {
            return false
        }
        
        return true
    }
}
