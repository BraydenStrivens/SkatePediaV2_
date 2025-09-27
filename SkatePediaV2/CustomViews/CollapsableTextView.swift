//
//  CollapsableTextView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/13/25.
//

import SwiftUI

struct CollapsableTextView: View {
    let lineLimit: Int
    private var text: String
    @State private var expanded: Bool = false
    @State private var showViewButton: Bool = false

    init(_ text: String, lineLimit: Int) {
        self.text = text
        self.lineLimit = lineLimit
    }
    
    private var moreLessText: String {
        if showViewButton {
            return expanded ? "Show Less" : "Show More"
        } else {
            return ""
        }
    }
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                Text(text)
                    .font(.body)
                    .lineLimit(expanded ? nil : lineLimit)
                
                ScrollView(.vertical) {
                    Text(text)
                        .font(.body)
                        .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .onAppear {
                                        showViewButton = proxy.size.height > CGFloat(22 * lineLimit)
                                    }
                                    .onChange(of: text) {
                                        showViewButton = proxy.size.height > CGFloat(22 * lineLimit)
                                    }
                            }
                        )
                        
                }
                .opacity(0.0)
                .disabled(true)
                .frame(height: 0.0)
            }
            
            Button {
                withAnimation {
                    expanded.toggle()
                }
            } label: {
                Text(moreLessText)
                    .font(.body)
                    .foregroundColor(.blue.opacity(0.8))
            }
            .opacity(showViewButton ? 1.0 : 0)
            .disabled(!showViewButton)
            .frame(height: showViewButton ? nil : 0.0)
        }
    }
}

#Preview {
    CollapsableTextView("Hello this is brayden strivens, im tryna make an app but kinda suck, we still tryin anyways so fuck it. We'll see how it goes", lineLimit: 2)
}
