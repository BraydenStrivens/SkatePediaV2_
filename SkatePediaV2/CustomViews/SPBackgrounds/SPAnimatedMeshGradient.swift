//
//  SPAnimatedMeshGradiant.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/21/25.
//

import SwiftUI

struct SPAnimatedMeshGradient: View {
    let colors: [Color]
    
    @State var appear = false
    
    private let startPoints: [[Float]] = [
        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
        [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
    ]
    private let endPoints: [[Float]] = [
        [1.0, 1.0], [0.5, 1.0], [0.0, 1.0],
        [1.0, 0.5], [0.5, 0.5], [0.0, 0.5],
        [1.0, 0.0], [0.5, 0.0], [0.0, 0.0]
    ]
    
    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0.0, 0.0],
                [0.5, 0.0],
                [1.0, 0.0],
                [0.0, 0.5],
                [0.5, 0.5],
                [1.0, 0.5],
                [0.0, 1.0],
                [0.5, 1.0],
                [1.0, 1.0]
            ],
            colors: colors
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                appear.toggle()
            }
        }
    }
}

#Preview {
    SPAnimatedMeshGradient(colors: [.blue, .purple, .indigo, .orange, .white, .blue, .yellow, .green, .mint])
        .ignoresSafeArea()
}
