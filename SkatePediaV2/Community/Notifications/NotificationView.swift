//
//  NotificationView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/13/25.
//

import SwiftUI
import SlidingTabView

struct NotificationView: View {
    
    @StateObject var viewModel = NotificationsViewModel()
    @State var tabIndex: Int = 0
    @Binding var unseenNotificationsExist: Bool
    let userId: String?
    
    private let notificationTypes: [String] = ["All", "Messages", "Comments", "Replies", "Friend Requests"]
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(notificationTypes, id: \.self) { type in
                        let index = notificationTypes.firstIndex(of: type)
                        let isCurrentTab = self.tabIndex == index
                        
                        VStack {
                            Text(type)
                                .foregroundColor(.primary)
                                .font(.subheadline)
                                .fontWeight(isCurrentTab ? .semibold : .regular)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 15)
                        .background {
                            Rectangle()
                                .fill(.gray.opacity(isCurrentTab ? 0.2 : 0.0))
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 5)
                        .onTapGesture {
                            if let index { self.tabIndex = index }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            VStack {
                switch(tabIndex) {
                case 0:
                    allNotifications
                        .onFirstAppear {
                            let _ = print("FETCHING NOTIFICATIONS")
                            Task {
                                try await viewModel.fetchNotifications(userId: userId)
                            }
                        }
                case 1:
                    messageNotifications
                        .onFirstAppear {
                            
                        }
                case 2:
                    commentNotifications
                        .onFirstAppear {
                            
                        }
                case 3:
                    replyNotifications
                        .onFirstAppear {
                            
                        }
                case 4:
                    friendRequestNotifications
                        .onFirstAppear {
                            
                        }
                default:
                    Text("Couldnt get tab index, please select a tab.")
                }
            }
            .padding()
            
            Spacer()
        }
        .customNavBarItems(title: "Notifications", subtitle: "", backButtonHidden: false)
        .onAppear {
            unseenNotificationsExist = false
        }
    }
    
    var allNotifications: some View {
        LazyVStack(spacing: 10) {
            if viewModel.notifications.isEmpty {
                if viewModel.isFetching {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("No Notifications...")
                            .font(.title2)
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                ScrollView {
                    ForEach(viewModel.notifications) { notification in
                        if let user = notification.fromUser {
                            NotificationCell(
                                notifications: $viewModel.notifications,
                                notification: notification
                            )
                            .onFirstAppear {
                                Task {
                                    try await viewModel.markNotificationAsSeen(notificationId: notification.id)
                                    
                                    if notification == viewModel.notifications.last! {
                                        try await viewModel.fetchNotifications(userId: userId)
                                    }
                                }
                            }
                            Divider()
                        }
                    }
                    
                    if viewModel.isFetching {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
                .frame(height: UIScreen.screenHeight * 0.7)
            }
        }
    }
    
    var messageNotifications: some View {
        LazyVStack {
            if viewModel.notifications.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    Text("No Messages...")
                        .font(.title2)
                    Spacer()
                }
                Spacer()
                
            } else {
                ScrollView {
                    
                }
                .frame(height: UIScreen.screenHeight * 0.7)
            }
        }
    }
    
    var commentNotifications: some View {
        LazyVStack {
            if viewModel.notifications.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    Text("No Comments...")
                        .font(.title2)
                    Spacer()
                }
                Spacer()
                
            } else {
                ScrollView {
                    
                }
                .frame(height: UIScreen.screenHeight * 0.7)
            }
        }
    }
    
    var replyNotifications: some View {
        LazyVStack {
            if viewModel.notifications.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    Text("No Comment Replies...")
                        .font(.title2)
                    Spacer()
                }
                Spacer()
                
            } else {
                ScrollView {
                    
                }
                .frame(height: UIScreen.screenHeight * 0.7)
            }
        }
    }
    
    var friendRequestNotifications: some View {
        LazyVStack {
            if viewModel.notifications.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    Text("No Friend Requests...")
                        .font(.title2)
                    Spacer()
                }
                Spacer()
                
            } else {
                ScrollView {
                    
                }
                .frame(height: UIScreen.screenHeight * 0.7)
            }
        }
    }
}

//#Preview {
//    NotificationView()
//}
