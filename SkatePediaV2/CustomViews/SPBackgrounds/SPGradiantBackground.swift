//
//  SPStaticBackground.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/21/25.
//

import SwiftUI

struct SPGradiantBackground: View {
    
    @State private var animatedGradiant: Bool = false
    let startColor: Color
    let endColor: Color
    
    var body: some View {
        VStack {
            
        }
        .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
        .background {
            LinearGradient(
                colors: [startColor, endColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            .hueRotation(.degrees(animatedGradiant ? 45 : 0))
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    animatedGradiant.toggle()
                }
            }
        }
    }
}

#Preview {
    SPGradiantBackground(startColor: Color.teal, endColor: Color.black)
}
