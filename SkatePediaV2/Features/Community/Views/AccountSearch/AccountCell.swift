//
//  AccountCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import SwiftUI

///
/// Struct that displays a preview of a user when searching for an account.
///
/// - Parameters:
///  - user: An object containing information from a user's document in the database.
///
struct AccountCell: View {
    @EnvironmentObject private var router: CommunityRouter
    @EnvironmentObject var errorStore: ErrorStore
    
    let user: User
    let currentUser: User
    
    var body: some View {
        // Navigates the user's account view when clicked
        Button {
            router.push(.userAccount(currentUser: currentUser, otherUser: user))
        } label: {
            userCell
        }
    }
    
    var userCell: some View {
        HStack(alignment: .top, spacing: 10) {
            CircularProfileImageView(photoUrl: user.profilePhoto?.photoUrl, size: .large)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("@\(user.username)")
                    .font(.title3)
                
                Text(user.stance.camalCase)
                    .font(.footnote)
            }
            .foregroundColor(.primary)
            
            Spacer()
        }
    }
}
