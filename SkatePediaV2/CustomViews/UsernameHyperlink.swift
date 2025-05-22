//
//  UsernameHyperlink.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/21/25.
//

import SwiftUI

struct UsernameHyperlink: View {
    let user: User
    let font: Font
    
    var body: some View {
        CustomNavLink(
            destination: UserAccountView(user: user),
            label: {
                Text("@\(user.username)")
                    .font(font)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        )
    }
}

#Preview {
    UsernameHyperlink(user: PreviewObjects.user, font: .title2)
}
