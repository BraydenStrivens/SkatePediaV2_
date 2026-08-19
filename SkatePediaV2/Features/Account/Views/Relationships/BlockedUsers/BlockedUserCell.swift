//
//  BlockedUserCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/23/26.
//

import SwiftUI

struct BlockedUserCell: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var router: AccountRouter
    @EnvironmentObject private var appEnv: AppEnvironment
    
    @ObservedObject var blockedUsersVM: BlockedUsersViewModel
    let currentUser: User
    let userBlock: UserBlock
    
    var body: some View {
        HStack {
            CircularProfileImageView(
                photoUrl: userBlock.blockedUserData.photoUrl,
                size: .large
            )
            
            VStack(spacing: 2) {
                HStack(alignment: .top, spacing: 8) {
                    Text(userBlock.blockedUserData.username)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(userBlock.dateCreated.timeAgoString())
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
                
                HStack(alignment: .top) {
                    Text(userBlock.blockedUserData.stance.camalCase)
                        .foregroundStyle(.gray)
                    
                    Spacer()
                    
                    unblockButton
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
                    .fetchUser(userId: userBlock.blockedUid)
                else { return }
                
                router.push(
                    .userAccount(
                        currentUser: currentUser,
                        otherUser: otherUser
                    )
                )
            }
        }
    }
    
    private var unblockButton: some View {
        Button {
            Task {
                await blockedUsersVM.unblockUser(
                    currentUid: currentUser.userId,
                    otherUid: userBlock.blockedUid
                )
            }
        } label: {
            Text("Un-block")
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.primary)
        )
    }
}
