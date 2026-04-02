//
//  NotificationView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/13/25.
//

import SwiftUI
import SlidingTabView

struct NotificationView: View {
    @EnvironmentObject var notificationStore: NotificationStore
    
    @ObservedObject var viewModel: NotificationViewModel
    
    let user: User
    
    init(
        user: User,
        viewModel: NotificationViewModel
    ) {
        self.user = user
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    var notifications: [Notification] {
        notificationStore.notifications
    }
        
    var body: some View {
        VStack(spacing: 0) {
            tabSelector
                .padding(.top, 8)

            switch viewModel.initialFetchState {
            case .idle, .loading:
                CustomProgressView(placement: .center)
                
            case .success:
                if notifications.isEmpty {
                    ContentUnavailableView(
                        "No Notifications",
                        systemImage: "list.bullet.rectangle.portrait"
                    )
                } else {
                    notificationsList
                }
                
            case .failure(let sPError):
                ContentUnavailableView(
                    "Error Fetching Notifications",
                    systemImage: "exclamationmark.triangle",
                    description: Text(sPError.errorDescription ?? "Something went wrong...")
                )
            }
        }
        .task {
            await viewModel.initialNotificationFetch(userId: user.userId)
            await viewModel.resetUserUnseenNotifcationCount(for: user)
        }
    }
    
    var tabSelector: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(NotificationFilter.allCases) { filter in
                        Text(filter.camalCase)
                            .font(.footnote)
                            .kerning(0.2)
                            .id(filter.id)
                            .fontWeight(filter == viewModel.notificationFilter ? .semibold : .light)
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background {
                                Rectangle()
                                    .fill(filter == viewModel.notificationFilter ? .gray.opacity(0.2) : Color(.systemBackground))
                                    .overlay(alignment: .bottom) {
                                        Rectangle()
                                            .fill(Color("AccentColor"))
                                            .frame(height: filter == viewModel.notificationFilter ? 1 : 0)
                                    }
                            }
                            .onTapGesture {
                                if filter != viewModel.notificationFilter {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        // Changes filter and tries to move the selected tab to the middle of the screen
                                        viewModel.notificationFilter = filter
                                        proxy.scrollTo(filter.id, anchor: .center)
                                    }
                                    
                                    // Re-fetches notifications using the new filter
                                    Task {
                                        await viewModel.initialNotificationFetch(
                                            userId: user.userId
                                        )
                                    }
                                }
                            }
                    }
                }
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(.gray.opacity(0.2))
                        .frame(height: 1)
                }
                .padding(.horizontal)
            }
        }
    }
    
    var notificationsList: some View {
        ScrollView {
            LazyVStack {
                ForEach(notifications) { notification in
                    NotificationCell(user: user, notification: notification)
                        .environmentObject(viewModel)
                        .task {
                            if notification == notifications.last {
                                await viewModel.fetchMoreNotifications(userId: user.userId)
                            }
                        }
                }
                
                if viewModel.isFetchingMore {
                    CustomProgressView(placement: .center)
                }
            }
        }
    }
}
