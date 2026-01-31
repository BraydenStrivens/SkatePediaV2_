//
//  ChatViewModel.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import PhotosUI

final class ChatMessagesViewModel: ObservableObject {
    enum ChatState {
        case initializing
        case ready(UserChat)
        case failure(SPError)
    }
    
    /// Chat state and messages variables
    @Published var chatState: ChatState = .initializing
    @Published var messages: [UserMessage] = []
    @Published var isFetchingMore: Bool = false
    @Published var error: SPError? = nil
    /// Used to automatically scroll the messages scroll view down revealing the new message each time a message is sent.
    @Published var newMessageCount: Int = 0
    
    /// New message variables
    private var fileType: FileType? = nil
    private var photoData: Data? = nil
    private let maxVideoDurationSeconds: Double = 4.0
    @Published var photoPreview: UIImage? = nil
    @Published var tempVideoUrl: URL? = nil
    @Published var newMessageContent: String = ""
    @Published var newMessageFile: PhotosPickerItem? = nil
    @Published var sendingMessage: Bool = false
    
    /// Message listening and fetch variables
    @Published var listener: ListenerRegistration? = nil
    /// Listener is added using .onAppear which tends to call its functions multiple times. This ensures it is called once.
    private var listenerAdded: Bool = false
    private var lastDocument: DocumentSnapshot? = nil
    /// Used to check if more documents are available to be fetched, if not equal to batch count, no more messages left to fetch
    private var lastFetchSize: Int = 0
    private let batchCount: Int = 20
    
    private let currentUser: User
    private let withUserData: UserData
    
    init(
        currentUser: User,
        withUserData: UserData,
        initialUserChat: UserChat? = nil
    ) {
        self.currentUser = currentUser
        self.withUserData = withUserData
        
        if let userChat = initialUserChat {
            self.chatState = .ready(userChat)
            
        } else {
            Task {
                await createUserChatDocuments(
                    currentUser: currentUser, withUserData: withUserData
                )
            }
        }
    }
    
    @MainActor
    func createUserChatDocuments(currentUser: User, withUserData: UserData) async {
        do {
            let newChat = try await MessagingManager.shared.createChatDocuments(
                currentUser: currentUser,
                withUserData: withUserData
            )
            self.chatState = .ready(newChat)
            
        } catch let error as FirestoreError {
            self.chatState = .failure(.firestore(error))
        } catch {
            self.chatState = .failure(.unknown)
        }
    }

    @MainActor
    func addListenerToFirstNMessages(sharedChatId: String) async {
        guard !listenerAdded else { return }
        do {
            self.listener = try await MessagingManager.shared.sharedChatMessagesListenerQuery(
                sharedChatId: sharedChatId, count: batchCount
            )
            .addSnapshotListener({ [weak self] snapshot, error in
                if let error = error {
                    let mappedError = FirestoreError.mapFirebaseError(error)
                    self?.error = .firestore(mappedError)
                    return
                }
                guard let self = self, let snapshot = snapshot else {
                    self?.error = .unknown
                    return
                }
                
                for change in snapshot.documentChanges {
                    let result = Result {
                        try change.document.data(as: UserMessage.self)
                    }
                    
                    if case .failure = result {
                        self.error = .unknown
                        return
                    }
                    if case .success(let message) = result {
                        switch change.type {
                        case .added:
                            withAnimation(.easeInOut(duration: 0.25)) {
                                self.messages.append(message)
                            }
                            
                        case .modified:
                            if let index = messages.firstIndex(where: { $0.id == message.id }) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    self.messages[index] = message
                                }
                            }
                        case .removed:
                            withAnimation(.easeInOut(duration: 0.25)) {
                                self.messages.removeAll { $0.id == message.id }
                            }
                        }
                    }
                }
                self.lastDocument = snapshot.documents.last
                self.newMessageCount += 1
            })
        } catch let error as FirestoreError {
            self.error = .firestore(error)
        } catch {
            self.error = .unknown
        }
        self.listenerAdded = true
    }
    
    @MainActor
    func removeListenerToFirstNMessage() {
        self.listener?.remove()
        self.listenerAdded = false
    }
    
    @MainActor
    func fetchMoreMessage(sharedChatId: String) async {
        guard lastFetchSize == batchCount else { return }
        self.isFetchingMore = true
        
        do {
            let (currentBatch, lastDocument) = try await MessagingManager.shared.fetchChatMessages(sharedChatId: sharedChatId, count: batchCount, lastDocument: lastDocument)
            
            self.messages.append(contentsOf: currentBatch)
            if let lastDocument { self.lastDocument = lastDocument }
            self.lastFetchSize = currentBatch.count
            
        } catch let error as FirestoreError {
            self.error = .firestore(error)
        } catch {
            self.error = .unknown
        }
        self.isFetchingMore = false
    }
    
    @MainActor
    func sendMessage(userChat: UserChat, currentUser: User) async {
        do {
            guard !newMessageContent.isEmpty || newMessageFile != nil else {
                throw FirestoreError.custom("Please enter text or select a file before sending a message.")
            }
            self.sendingMessage = true
            
            let newMessage: UserMessage = UserMessage(
                fromUserId: currentUser.userId,
                toUserId: userChat.withUserData.userId,
                content: newMessageContent,
                fileType: fileType
            )
            try await MessagingManager.shared.sendMessage(
                sharedChatId: userChat.chatId,
                currentUser: currentUser,
                message: newMessage,
                videoUrl: tempVideoUrl,
                photoData: photoData
            )
            resetNewMessageData()
            self.newMessageCount += 1
            
        } catch let error as FirestoreError {
            self.error = .firestore(error)
        } catch {
            self.error = .unknown
        }
        self.sendingMessage = false
    }
    
    func updateUserChatUnseenMessages(userId: String, withUserId: String) async {
        do {
            try await MessagingManager.shared.updateUserChatUnseenMessages(
                userId: userId,
                withUserId: withUserId
            )
        } catch let error as FirestoreError {
            self.error = .firestore(error)
        } catch {
            self.error = .unknown
        }
    }
    
    func hideMessage(sharedChatId: String, hiderId: String, messageId: String) async {
        do {
            try await MessagingManager.shared.updateMessageHiddenByArray(
                sharedChatId: sharedChatId,
                hiderUid: hiderId,
                messageId: messageId
            )
        } catch let error as FirestoreError {
            self.error = .firestore(error)
        } catch {
            self.error = .unknown
        }
    }
    
    func deleteMessage(sharedChatId: String, message: UserMessage) async {
        do {
            try await MessagingManager.shared.deleteMessage(sharedChatId: sharedChatId, message: message)
            
        } catch let error as FirestoreError {
            self.error = .firestore(error)
        } catch {
            self.error = .unknown
        }
    }
    
    @MainActor
    func loadImage(item: PhotosPickerItem) async {
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                
                self.photoData = data
                self.photoPreview = image
                self.fileType = .photo
            } else {
                print("no image data")
            }
        } catch {
            self.error = .firestore(.custom("Error loading image. Please try again."))
        }
    }
    
    @MainActor
    func loadVideo(item: PhotosPickerItem) async {
        do {
            if let originalVideoUrl = try await item.loadTransferable(type: URL.self) {
                // Check if the video duration is less than the duration limit
                try await isVideoUnderDurationLimit(url: originalVideoUrl)
                
                // Stores the file on disk rather than ram for low memory usage
                let tempDir = FileManager.default.temporaryDirectory
                let tempVideoUrl = tempDir
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension(originalVideoUrl.pathExtension)
                try FileManager.default.copyItem(at: originalVideoUrl, to: tempDir)
                
                self.tempVideoUrl = tempVideoUrl
                self.fileType = .video
            } else {
                print("no original video url")
            }
        } catch {
            self.error = .firestore(.custom("Error loading video. Please try again."))
        }
    }
    
    func isVideoUnderDurationLimit(url: URL) async throws {
        let asset = AVURLAsset(url: url)
        let duration = try await asset.load(.duration).seconds
        if duration > maxVideoDurationSeconds {
            throw FirestoreError
                .custom("Video duration limit exceeded. Please trim the video down to a maximum of four seconds")
        }
    }
    
    func resetNewMessageData() {
        if let url = tempVideoUrl {
            try? FileManager.default.removeItem(at: url)
        }
        self.newMessageContent = ""
        self.newMessageFile = nil
        self.photoData = nil
        self.photoPreview = nil
        self.tempVideoUrl = nil
        self.fileType = nil
    }
}
