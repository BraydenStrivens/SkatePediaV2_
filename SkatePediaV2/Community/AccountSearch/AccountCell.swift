//
//  AccountCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/15/25.
//

import SwiftUI

struct AccountCell: View {
    let user: User
    
    var body: some View {
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

#Preview {
    AccountCell(user: User(userId: "", email: "bdstrivens@gmail.com", username: "B-BizzleMonizzle", stance: "Goofy", dateCreated: Date()))
}
