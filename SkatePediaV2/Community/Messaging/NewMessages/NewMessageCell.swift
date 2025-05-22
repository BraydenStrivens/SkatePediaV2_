//
//  NewMessageCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/3/25.
//

import SwiftUI

struct NewMessageCell: View {
    let user: User
    
    var body: some View {
        CustomNavLink(
            destination: ChatMessagesView(chattingWith: user)) {
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
