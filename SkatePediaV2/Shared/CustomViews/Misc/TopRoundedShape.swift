//
//  TopRoundedShape.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/13/26.
//

import SwiftUI

struct TopRoundedShape: Shape {
    var radius: CGFloat = 20

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )

        return Path(path.cgPath)
    }
}
