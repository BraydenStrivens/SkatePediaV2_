//
//  ChatMessagesViewContainer.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/8/26.
//

import SwiftUI

struct ChatMessagesViewContainer: View {
    
    @StateObject var viewModel: ChatMessagesViewModel
    
    let currentUser: User
    let withUserData: UserData
    
    init(
        currentUser: User,
        withUserData: UserData,
        userChat: UserChat? = nil,
        errorStore: ErrorStore
    ) {
        self.currentUser = currentUser
        self.withUserData = withUserData
        
        _viewModel = StateObject(
            wrappedValue: ChatMessagesViewModel(
                currentUser: currentUser,
                withUserData: withUserData,
                initialUserChat: userChat,
                errorStore: errorStore
            )
        )
    }
    var body: some View {
        ChatMessagesView(
            currentUser: currentUser,
            withUserData: withUserData,
            viewModel: viewModel
        )
    }
}
