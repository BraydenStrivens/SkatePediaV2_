//
//  TrickItemCell.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/6/25.
//

import SwiftUI

struct TrickItemCell: View {
    
    let userId: String
    let trickItem: TrickItem
    @Binding var trickItems: [TrickItem]
    
    private let starColor = Color(red: 255.0, green: 215.0, blue: 0.0)
    
    var body: some View {
        CustomNavLink(
            destination: TrickItemView(userId: userId, trickItem: trickItem, trickItems: $trickItems)) {
                HStack(alignment: .center, spacing: 12) {
                    VStack(spacing: 5) {
                        Text("Rating:")
                            .font(.footnote)
                            .fontWeight(.bold)
                        HStack {
                            ForEach(1...3, id: \.self) { number in
                                let isFilled = trickItem.progress >= number
                                
                                Image(systemName: isFilled ? "star.fill" : "star")
                                    .foregroundColor(isFilled ? starColor : .primary)
                                    .shadow(
                                        color: isFilled ? .gray : .clear,
                                        radius: 2, x: 0, y: 2)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 5) {
                        Text("Added:")
                            .font(.footnote)
                            .fontWeight(.bold)
                        Text("\(DateFormat.dateFormatter.string(from: trickItem.dateCreated))")
                            .font(.headline)
                    }
                }
                .foregroundColor(.primary)
            }
            .padding()
            .cornerRadius(15)
            .background {
                RoundedRectangle(cornerRadius: 15)
//                    .fill(Color(uiColor: UIColor.systemBackground))
                    .fill(
                        LinearGradient(
                            colors: [Color(uiColor: UIColor.systemBackground), .blue.opacity(0.1)], startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .stroke(Color.primary.opacity(0.5))
            }
    }
}
