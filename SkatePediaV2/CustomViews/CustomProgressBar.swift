//
//  CustomProgressBar.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/2/25.
//

import SwiftUI

struct CustomProgressBar: View {
    
    var header: String
    var totalTricks: Int
    var learnedTricks: Int
    
    var width: CGFloat
    var height: CGFloat = 20
    
    var backgroundColor: Color = Color.gray.opacity(0.2)
    var startColor: Color = Color.blue
    var endColor: Color = Color.teal
    
    init(header: String, totalTricks: Int, learnedTricks: Int, width: CGFloat = UIScreen.screenWidth / 2) {
        self.header = header
        self.totalTricks = totalTricks
        self.learnedTricks = learnedTricks
        self.width = width
    }
    
    private func calculateBarLength() -> CGFloat {
        return CGFloat(Float(learnedTricks) / Float(totalTricks))
    }
    
    var body: some View {
        HStack {
            if !header.isEmpty {
                Text("\(header)")
                    .font(.headline)
                
                Spacer()
            }
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height, style: .continuous)
                    .frame(width: width, height: height)
                    .foregroundColor(backgroundColor)
                
                RoundedRectangle(cornerRadius: height, style: .continuous)
                    .frame(width: (width * calculateBarLength()), height: height)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [startColor, endColor]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .clipShape(RoundedRectangle(cornerRadius: height, style: .continuous))
                    )
                
                    .foregroundColor(.clear)
            }
            
            Spacer()
            
            Text("\(learnedTricks)/\(totalTricks)")
                .font(.headline)
        }
        .padding(.horizontal)
        .frame(height: height)
    }
}

#Preview {
    CustomProgressBar(header: "Switch", totalTricks: 30, learnedTricks: 20)
}
