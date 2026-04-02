//
//  TrickItemRatingSelector.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/9/26.
//

import SwiftUI

struct TrickItemRatingSelector: View {
    @Binding var rating: Int
    let size: CGFloat
    let color: Color
    
    init(rating: Binding<Int>, size: CGFloat = 25, color: Color = .yellow) {
        self._rating = rating
        self.size = size
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: size) {
            ForEach(1...3, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .resizable()
                    .foregroundColor(index <= rating
                                     ? color
                                     : .primary
                    )
                    .frame(width: size, height: size)
                    .onTapGesture {
                        withAnimation(.bouncy(duration: 0.2)) {
                            if rating == index {
                                rating -= 1
                            } else {
                                rating = index
                            }
                        }
                    }
            }
        }
    }
}
