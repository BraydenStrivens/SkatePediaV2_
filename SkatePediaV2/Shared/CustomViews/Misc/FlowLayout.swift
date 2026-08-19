//
//  FlowLayout.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 5/12/26.
//

import SwiftUI

struct FlowLayout: Layout {
    enum Alignment {
        case leading
        case center
        case trailing
    }
    
    var alignment: Alignment = .leading
    var spacing: CGFloat = 8
    
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        
        let maxWidth = proposal.width ?? 0
        
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
        }
        
        return CGSize(
            width: maxWidth,
            height: currentY + rowHeight
        )
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        
        struct Row {
            var elements: [(index: Int, size: CGSize)] = []
            var width: CGFloat = 0
            var height: CGFloat = 0
        }
        
        var rows: [Row] = []
        var currentRow = Row()
        
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            
            let proposedWidth =
                currentRow.elements.isEmpty
                    ? size.width
                    : currentRow.width + spacing + size.width
            
            if proposedWidth > bounds.width && !currentRow.elements.isEmpty {
                rows.append(currentRow)
                currentRow = Row()
            }
            
            currentRow.elements.append((index, size))
            
            if currentRow.elements.count == 1 {
                currentRow.width = size.width
            } else {
                currentRow.width += spacing + size.width
            }
            
            currentRow.height = max(currentRow.height, size.height)
        }
        
        if !currentRow.elements.isEmpty {
            rows.append(currentRow)
        }
        
        var currentY = bounds.minY
        
        for row in rows {
            let startX: CGFloat
            
            switch alignment {
            case .leading:
                startX = bounds.minX
            case .center:
                startX = bounds.minX + (bounds.width - row.width) / 2
            case .trailing:
                startX = bounds.maxX - row.width
            }
            
            var currentX = startX
            
            for element in row.elements {
                subviews[element.index].place(
                    at: CGPoint(x: currentX, y: currentY),
                    proposal: ProposedViewSize(element.size)
                )
                
                currentX += element.size.width + spacing
            }
            
            currentY += row.height + spacing
        }
    }
    
//    func placeSubviews(
//        in bounds: CGRect,
//        proposal: ProposedViewSize,
//        subviews: Subviews,
//        cache: inout ()
//    ) {
//        var currentX = bounds.minX
//        var currentY = bounds.minY
//        var rowHeight: CGFloat = 0
//        
//        for subview in subviews {
//            let size = subview.sizeThatFits(.unspecified)
//            
//            if currentX + size.width > bounds.maxX {
//                currentX = bounds.minX
//                currentY += rowHeight + spacing
//                rowHeight = 0
//            }
//            
//            subview.place(
//                at: CGPoint(x: currentX, y: currentY),
//                proposal: ProposedViewSize(size)
//            )
//            
//            currentX += size.width + spacing
//            rowHeight = max(rowHeight, size.height)
//        }
//    }
}
