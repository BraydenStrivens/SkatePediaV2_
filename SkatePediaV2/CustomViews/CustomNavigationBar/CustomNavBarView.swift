//
//  CustomNavBarView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/25.
//

import SwiftUI

struct CustomNavBarView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let showBackButton: Bool
    let title: String
    let subtitle: String?
    
    var body: some View {
        if title.isEmpty {
            EmptyView()
        } else {
            HStack {
                if showBackButton {
                    backButton
                }
                
                Spacer()
                
                titleSection
                
                Spacer()
                
                if showBackButton {
                    backButton
                        .opacity(0)
                }
            }
            .padding(.horizontal)
            .accentColor(.white)
            .foregroundColor(.primary)
            .font(.headline)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.clear]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea(edges: .top)
                //            Color.blue.ignoresSafeArea(edges: .top)
            )
        }
    }
    
}

#Preview {
    CustomNavBarView(showBackButton: true, title: "Title Here", subtitle: "Subtitle Here")
    Spacer()
}

extension CustomNavBarView {
    private var backButton: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Image(systemName: "chevron.left")
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            if let subtitle = subtitle {
                Text(subtitle)
            }
        }
    }
}
