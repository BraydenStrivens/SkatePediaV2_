//
//  CommentConnectorLine.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/22/26.
//

import SwiftUI

struct CommentShowRepliesConnectorLine: Shape {
    var photoBottomY: CGFloat
    var buttonCenterX: CGFloat
    var curveRadius: CGFloat = 4
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let start = CGPoint(x: rect.minX, y: photoBottomY)
        let curveStart = CGPoint(x: rect.minX, y: photoBottomY + 3)
        
        let horizontalY = curveStart.y + curveRadius
        
        let end = CGPoint(x: buttonCenterX, y: horizontalY)
        
        path.move(to: start)
        
        path.addLine(to: curveStart)
        
        path.addCurve(
            to: CGPoint(x: rect.minX + curveRadius, y: horizontalY),
            control1: CGPoint(x: rect.minX, y: curveStart.y + 3),
            control2: CGPoint(x: rect.minX + 5, y: horizontalY)
        )
        
        path.addLine(to: end)
        
        return path
    }
}
