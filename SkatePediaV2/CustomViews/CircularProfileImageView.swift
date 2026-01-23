//
//  CircularProfileImageView.swift
//  ThreadsTutorial
//
//  Created by Brayden Strivens on 3/11/25.
//

import SwiftUI
import Kingfisher

enum ProfileImageSize {
    case xxSmall
    case xSmall
    case small
    case medium
    case large
    case xLarge
    
    var dimension: CGFloat {
        switch self {
        case .xxSmall: return 20
        case .xSmall: return 25
        case .small: return 30
        case .medium: return 35
        case .large: return 50
        case .xLarge: return 80
        }
    }
}
struct CircularProfileImageView: View {
    var photoUrl: String?
    let size: ProfileImageSize
    
    var body: some View {
        if let photoUrl = photoUrl, !photoUrl.isEmpty {
            KFImage(URL(string: photoUrl))
                .resizable()
                .scaledToFill()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: size.dimension, height: size.dimension)
                .foregroundColor(Color(.systemGray4))
        }
    }
    
}
