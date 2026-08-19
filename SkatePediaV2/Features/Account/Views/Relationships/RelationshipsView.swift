//
//  RelationshipsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/20/26.
//

import SwiftUI

struct RelationshipsView: View {
    
    // MARK: Environment
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var router: AccountRouter
    
    // MARK: Parameters
    @StateObject var viewModel: RelationshipsViewModel
    let user: User
    
    // MARK: Init
    init(
        user: User,
        viewModel: RelationshipsViewModel
    ) {
        self.user = user
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: Body
    var body: some View {
        VStack(spacing: 0) {
            filterTabBar
            
            filteredList
        }
        .customNavHeader(title: "Relationships", showDivider: false)
        .task(id: viewModel.currentFilter.id) {
            await viewModel.initialFetch(userId: user.userId)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.push(.blockedUsers(currentUser: user))
                } label: {
                    Image(systemName: "person.crop.circle.badge.xmark")
                }
            }
        }
    }
    
    // MARK: Private Functions
    
    private func emptyListTitle() -> String {
        switch viewModel.currentFilter {
        case .pending:
            return "No Pending Requests"
        case .accepted:
            return "No Friends"
        case .declined:
            return "No Declined Requests"
        }
    }
    
    // MARK: Subviews
    
    private var filterTabBar: some View {
        HStack(spacing: 10) {
            Spacer()
            
            ForEach(RelationshipStatus.allCases) { status in
                let isCurrentTab = viewModel.currentFilter == status
                
                Text(status.camalCase)
                    .id(status.id)
                    .font(.footnote)
                    .foregroundStyle(isCurrentTab
                                     ? colorScheme == .dark ? .black : .white
                                     : .primary
                    )
                    .fontWeight(isCurrentTab ? .semibold : .medium)
                    .kerning(0.2)
                    .padding(.horizontal, 26)
                    .padding(.vertical, 10)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isCurrentTab
                                  ? colorScheme == .dark ? .white : Color(.systemGray2)
                                  : Color(.tertiarySystemFill)
                            )
                    }
                    .onTapGesture {
                        if !isCurrentTab {
                            withAnimation(.easeInOut(duration: 0.18)) {
                                viewModel.currentFilter = status
                            }
                        }
                    }
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
        
    private var filteredList: some View {
        Group {
            switch viewModel.currentRequestState {
            case .idle, .loading:
                CustomProgressView(placement: .center)
                
            case .success:
                ScrollView {
                    LazyVStack(spacing: 0) {
                        if viewModel.relationships.isEmpty {
                            SPContentUnavailableView(
                                title: emptyListTitle(),
                                type: .emptyList
                            )
                            
                        } else {
                            ForEach(viewModel.relationships) { relationship in
                                RelationshipCell(
                                    relationshipsVM: viewModel,
                                    currentUser: user,
                                    relationship: relationship
                                )
                                .onAppear {
                                    if relationship == viewModel.relationships.last {
                                        Task {
                                            await viewModel.fetchMore(userId: user.userId)
                                        }
                                    }
                                }
                                
                                if viewModel.fetchingMore {
                                    CustomProgressView(placement: .center)
                                }
                            }
                        }
                    }
                }
                
            case .failure(let sPError):
                SPContentUnavailableView(
                    title: "Error Fetching Relationships",
                    description: sPError.errorDescription,
                    type: .blockingError
                )
            }
        }
    }
}
