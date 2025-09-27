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
    let user: User
    
    var body: some View {
        // Navigates the user's account view when clicked
        CustomNavLink(
            destination: UserAccountView(user: user)) {
                HStack(alignment: .top, spacing: 10) {
                    CircularProfileImageView(user: user, size: .large)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("@\(user.username)")
                            .font(.title3)
                        
                        Text(user.stance)
                            .font(.footnote)
                    }
                    .foregroundColor(.primary)
                    
                    Spacer()
                }
            }
    }
}
