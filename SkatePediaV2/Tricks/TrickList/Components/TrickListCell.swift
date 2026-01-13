//
//  TrickListCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/25.
//

import SwiftUI

struct TrickListCell: View {
    let userId: String
    let trick: Trick
    let trickListInfo: TrickListInfo
    
    var body: some View {
        CustomNavLink(
            destination: TrickView(userId: userId, trick: trick)
                .customNavBarItems(title: trick.name, subtitle: "", backButtonHidden: false)
        ) {
            HStack(alignment: .center, spacing: 12) {
                Text(trick.name)
                    .foregroundColor(.primary)
                    .font(.callout)
                
                Spacer()
                
                if trick.progress.isEmpty {
                    Image(systemName: "circle")
                        .resizable()
                        .foregroundColor(Color("buttonColor"))
                        .frame(width: 20, height: 20)
                } else {
                    let maxRating = trick.progress.max()!
                    
                    if maxRating == 0 {
                        Image(systemName: "circle")
                            .resizable()
                            .foregroundColor(Color("buttonColor"))
                            .frame(width: 20, height: 20)
                    } else if maxRating == 1 {
                        Image(systemName: "circle.circle")
                            .resizable()
                            .foregroundColor(Color("buttonColor"))
                            .frame(width: 20, height: 20)
                    } else if maxRating == 2 {
                        Image(systemName: "circle.circle.fill")
                            .resizable()
                            .foregroundColor(Color("buttonColor"))
                            .frame(width: 20, height: 20)
                    } else {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .foregroundColor(Color("AccentColor"))
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .contextMenu {
                Button("Delete From List", role: .destructive) {
                    Task {
                        try await TrickListManager.shared.deleteTrick(
                            userId: userId,
                            trick: trick
                            )
                    }
                }
            }
        }
    }
}
