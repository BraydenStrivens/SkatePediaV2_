//
//  NotificationView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/13/25.
//

import SwiftUI
import SlidingTabView

struct NotificationView: View {
    
    // MARK: Environment
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var notificationStore: NotificationStore
    
    // MARK: State
    @State private var openNotificationId: String?
    
    // MARK: Parameters
    @StateObject var viewModel: NotificationViewModel
    let user: User
    
    // MARK: Derived/Private Properties
    
    private var notifications: [Notification] {
        notificationStore.notifications
    }
    
    // MARK: Init
    init(
        user: User,
        viewModel: NotificationViewModel
    ) {
        self.user = user
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: Body
    var body: some View {
        VStack(spacing: 0) {
            tabSelector
                .padding(.vertical, 8)

            switch viewModel.initialFetchState {
            case .idle, .loading:
                CustomProgressView(placement: .center)
                
            case .success:
                notificationsList
                
            case .failure(let sPError):
                SPContentUnavailableView(
                    title: "Error Fetching Notifications",
                    description: sPError.errorDescription,
                    type: .blockingError
                )
            }
        }
        .customNavHeader(title: "Notifications", showDivider: true)
        .task(id: viewModel.notificationFilter.id) {
            await viewModel.initialNotificationFetch(userId: user.userId)
        }
        .task {
            await viewModel.resetUserUnseenNotifcationCount(for: user)
        }
    }
    
    private var tabSelector: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(NotificationFilter.allCases) { filter in
                        tabCell(for: filter)
                            .onTapGesture {
                                if filter != viewModel.notificationFilter {
                                    withAnimation(.easeInOut(duration: 0.18)) {
                                        viewModel.notificationFilter = filter
                                        proxy.scrollTo(filter.id, anchor: .center)
                                    }
                                }
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func tabCell(
        for filter: NotificationFilter
    ) -> some View {
        Text(filter.camalCase)
            .id(filter.id)
            .font(.footnote)
            .foregroundStyle(filter == viewModel.notificationFilter
                             ? colorScheme == .dark ? .black : .white
                             : .primary
            )
            .fontWeight(filter == viewModel.notificationFilter
                        ? .semibold
                        : .medium
            )
            .kerning(0.2)
            .padding(.horizontal, 26)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(filter == viewModel.notificationFilter
                          ? colorScheme == .dark ? .white : Color(.systemGray2)
                          : Color(.tertiarySystemFill)
                    )
            }
    }
    
    var notificationsList: some View {
        Group {
            if notifications.isEmpty {
                SPContentUnavailableView(
                    title: "No Notifications",
                    type: .emptyList
                )

            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(notifications) { notification in
                            SwipableNotificationCell(
                                notification: notification,
                                user: user,
                                openID: $openNotificationId,
                                onDelete: {
                                    Task {
                                        await viewModel.deleteNotification(notification)
                                    }
                                }
                            )
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
    }
}
