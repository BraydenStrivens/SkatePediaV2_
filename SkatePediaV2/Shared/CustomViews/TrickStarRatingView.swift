//
//  TrickStarRatingView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/15/26.
//

import SwiftUI

///
/// Displays three stars that are filled and colored according to a user's self rating of that trick.
///
/// - Parameters:
///  - rating: an integer from [0,3] representing a user's mastery of a trick.
///
struct TrickStarRatingView: View {
    let color: Color
    let rating: Int
    let size: CGFloat
    
    var body: some View {
        HStack(spacing: size / 2) {
            Image(systemName: rating > 0 ? "star.fill" : "star")
                .resizable()
                .frame(width: size, height: size)
                .foregroundColor(rating > 0 ? color : .primary)
            
            Image(systemName: rating > 1 ? "star.fill" : "star")
                .resizable()
                .frame(width: size, height: size)
                .foregroundColor(rating > 1 ? color : .primary)

            Image(systemName: rating > 2 ? "star.fill" : "star")
                .resizable()
                .frame(width: size, height: size)
                .foregroundColor(rating > 2 ? color : .primary)
        }
    }
}
