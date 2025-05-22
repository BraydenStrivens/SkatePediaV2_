//
//  CustomProgressView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/29/25.
//

import SwiftUI

enum ProgressViewPlacement {
    case top
    case center
    case bottom
}

struct CustomProgressView: View {
    let placement: ProgressViewPlacement
    
    var body: some View {
        switch(placement) {
        case .top:
            topPlacement
            
        case .center:
            centerPlacmenet
            
        case .bottom:
            bottomPlacement
        }
    }
    
    var topPlacement: some View {
        VStack {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
    
    var centerPlacmenet: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
    
    var bottomPlacement: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
        .frame(maxHeight: .infinity)
    }
}
