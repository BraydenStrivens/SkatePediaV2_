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
    let chattingWith: User
    
    @Published var messages: [Message] = []
    @Published var newMessageContent: String = ""
    @Published var newMessageFile: PhotosPickerItem? = nil
    @Published var isFetched: Bool = false
    @Published var isSending: Bool = false
    @Published var listener: ListenerRegistration? = nil
    @Published var imageToSend: UIImage? = nil
    @Published var loadState = LoadState.unknown
    @Published var count: Int = 0
    
    var fileType: FileType = .none

    init(chattingWith: User) {
        self.chattingWith = chattingWith
    }
    
    enum LoadState {
        case unknown, loading, loaded(PreviewVideo), failed
    }
    
    @MainActor
    func addListenerToMessages() {
        guard let fromUid = Auth.auth().currentUser?.uid else { return }
        
        self.listener = MessagingManager.shared.chatMessagesCollection(fromUid: fromUid, toUid: chattingWith.userId)
            .order(by: Message.CodingKeys.dateCreated.rawValue, descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("ERROR ADDING LISTENER TO MESSAGE: \(error)")
                    return
                }

                snapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()

                        let newMessage = Message(data: data)
                        self.messages.append(newMessage)
                        
                        print(newMessage)
                    }
                    
                    if change.type == .removed {
                        let data = change.document.data()
                        self.messages.removeAll { aMessage in
                            aMessage == .init(data: data)
                        }
                    }
                })
            }
        
        self.isFetched = true
        self.count += 1
    }
    
    func removeListener() {
        self.listener?.remove()
    }
    
    @MainActor
    func sendMessage() async throws {
        guard !newMessageContent.isEmpty || newMessageFile != nil else { return }
        guard let fromUid = Auth.auth().currentUser?.uid else { return }
        
        self.isSending = true
        
        var fileData: Data? = nil
        
        let message = Message(
            messageId: "",
            fromUserId: fromUid,
            toUserId: chattingWith.userId,
            content: newMessageContent,
            dateCreated: Timestamp()
        )

        if let item = newMessageFile {
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            fileData = data
        }
        
        try await MessagingManager.shared.sendMessage(message: message, data: fileData, fileType: fileType)

        self.isSending = false
        self.fileType = .none
        self.newMessageContent = ""
        self.newMessageFile = nil
        self.count += 1
    }
    
    @MainActor
    func deleteMessage(message: Message) async throws {
        try await MessagingManager.shared.deleteMessage(message: message)
    }
    
    @MainActor
    func loadImage() async {
        guard let item = newMessageFile else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        
        self.imageToSend = uiImage
    }
}
