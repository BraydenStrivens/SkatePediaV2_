//
//  RelationshipCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/21/26.
//

import SwiftUI

struct RelationshipCell: View {
    
    // MARK: Environment
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var router: AccountRouter
    @EnvironmentObject private var appEnv: AppEnvironment
    
    // MARK: State
    
    // MARK: Parameters
    @ObservedObject var relationshipsVM: RelationshipsViewModel
    let currentUser: User
    let relationship: Relationship
    
    // MARK: Derived/Private Properties
    private var otherUserData: UserData? {
        relationship.otherUserData(currentUid: currentUser.userId)
    }
    
    var body: some View {
        if let otherUserData {
            HStack {
                CircularProfileImageView(
                    photoUrl: otherUserData.photoUrl,
                    size: .large
                )
                
                VStack(spacing: 2) {
                    HStack(alignment: .top, spacing: 8) {
                        Text(otherUserData.username)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text(relationship.dateUpdated.timeAgoString())
                            .font(.caption2)
                            .foregroundStyle(.gray)
                    }
                    
                    HStack(alignment: .top) {
                        Text(otherUserData.stance.camalCase)
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        handleButtons
                    }
                }
            }
            .padding(10)
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 12).protruded)
            .padding(6)
            .contentShape(Rectangle())
            .onTapGesture {
                Task {
                    guard let otherUser = try? await appEnv.userService
                        .fetchUser(userId: otherUserData.userId)
                    else { return }
                    
                    router.push(
                        .userAccount(
                            currentUser: currentUser,
                            otherUser: otherUser
                        )
                    )
                }
            }
            
        } else {
            EmptyView()
            let _ = print("NO OTHER USER DATA FOUND")
        }
    }
    
    private var handleButtons: some View {
        Group {
            switch relationship.status {
            case .pending:
                pendingRelationshipButtons
                
            case .accepted:
                acceptedRelationshipButtons
                
            case .declined:
                declinedRelationshipButtons
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    private var pendingRelationshipButtons: some View {
        HStack {
            if currentUser.userId == relationship.initiatedByUid {
                Button {
                    Task {
                        await relationshipsVM.removeRelationship(
                            currentUid: currentUser.userId,
                            relationship
                        )
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("Awaiting Response")
                        Text("Cancel")
                            .underline()
                    }
                }
                .handleButtonStyle(color: .gray)

            } else {
                Button {
                    Task {
                        await relationshipsVM.acceptFriendRelationship(
                            currentUid: currentUser.userId,
                            relationship
                        )
                    }
                } label: {
                    Text("Accept")
                }
                .handleButtonStyle(color: Color.button)
                
                Button {
                    Task {
                        await relationshipsVM.declineFriendRelationship(
                            currentUid: currentUser.userId,
                            relationship
                        )
                    }
                } label: {
                    Text("Decline")
                }
                .handleButtonStyle()
            }
        }
    }
    
    private var acceptedRelationshipButtons: some View {
        HStack {
            Button {
                Task {
                    await relationshipsVM.removeRelationship(
                        currentUid: currentUser.userId,
                        relationship
                    )
                }
            } label: {
                Text("Remove")
            }
            .handleButtonStyle(color: .red)
        }
    }
    
    private var declinedRelationshipButtons: some View {
        HStack {
            Button {
                Task {
                    await relationshipsVM.removeRelationship(
                        currentUid: currentUser.userId,
                        relationship
                    )
                }
            } label: {
                Text("Remove")
            }
            .handleButtonStyle(color: .red)
        }
    }
}

private extension View {
    func handleButtonStyle(
        color: Color = .primary
    ) -> some View {
        self
            .font(.caption)
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color)
            )
    }
}
