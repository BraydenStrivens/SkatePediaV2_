//
//  SPMeshGradient.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/21/25.
//

import SwiftUI

struct SPMeshGradient: View {
    let colors: [Color]
    
    static let sampleColors: [Color] = [.blue, .purple, .indigo, .orange, .white, .blue, .yellow, .green, .mint]
    static let sampleColors2: [Color] = [.teal, .teal, .teal, .white, .white, .white, .blue, .blue, .blue]
    static let buttonColors1: [Color] = [.teal, .black, .teal, .black, .teal, .black, .teal, .black, .teal]
    
    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                .init(0, 0), .init(0.5, 0), .init(1, 0),
                .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                .init(0, 1), .init(0.5, 1), .init(1, 1)
            ],
            colors: colors
        )
    }
}

#Preview {
    SPMeshGradient(colors: [.blue, .purple, .indigo, .orange, .white, .blue, .yellow, .green, .mint])
}
