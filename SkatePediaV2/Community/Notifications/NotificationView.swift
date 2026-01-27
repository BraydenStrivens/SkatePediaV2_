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
    
    let user: User
        
    var body: some View {
        VStack {
            tabSelector
                .padding(.top, 8)

            switch viewModel.initialFetchState {
            case .idle:
                VStack { }
                    .onAppear {
                        Task {
                            await viewModel.initialNotificationFetch(userId: user.userId)
                        }
                    }
                
            case .loading:
                CustomProgressView(placement: .center)
                
            case .success:
                if viewModel.notifications.isEmpty {
                    ContentUnavailableView(
                        "No Notifications",
                        systemImage: "list.bullet.rectangle.portrait"
                    )
                } else {
                    notificationsList
                }
                
            case .failure(let firestoreError):
                ContentUnavailableView(
                    "Error Fetching Notifications",
                    systemImage: "exclamationmark.triangle",
                    description: Text(firestoreError.errorDescription ?? "Something went wrong...")
                )
            }
        }
    }
    
    var tabSelector: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(NotificationFilter.allCases) { filter in
                        Text(filter.rawValue)
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
                                    // Emptys current notifications array
                                    viewModel.notifications.removeAll()

                                    // Changes filter and tries to move the selected tab to the middle of the screen
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        viewModel.notificationFilter = filter
                                        proxy.scrollTo(filter.id, anchor: .center)
                                    }
                                    
                                    // Re-fetches notifications using the new filter
                                    Task {
                                        await viewModel.initialNotificationFetch(userId: user.userId)
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
                ForEach(viewModel.notifications) { notification in
                    NotificationCell(user: user, notification: notification)
                        .environmentObject(viewModel)
                }
            }
        }
    }
}
