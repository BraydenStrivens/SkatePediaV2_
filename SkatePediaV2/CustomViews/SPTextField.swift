//
//  SPTextField.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/27/25.
//

import SwiftUI

struct SPTextField: View {
    @Environment(\.colorScheme) var colorScheme

    let title: String
    let borderColor: Color
    
    @Binding var text: String
    @FocusState var isTyping: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            TextField("", text: $text)
                .padding(.leading)
                .frame(height: 55).focused($isTyping)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .background(isTyping ? borderColor : Color.primary, in: RoundedRectangle(cornerRadius: 14).stroke(lineWidth: 2))
            
            Text(title)
                .padding(.horizontal, 5)
                .foregroundColor(isTyping ? borderColor : Color.primary)
                .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground)
                    .opacity(isTyping || !text.isEmpty ? 1 : 0))
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(isTyping ? borderColor.opacity(isTyping || !text.isEmpty ? 1 : 0) : .primary.opacity(isTyping || !text.isEmpty ? 1 : 0), lineWidth: 1.5)
                }
                .padding(.leading).offset(y: isTyping || !text.isEmpty ? -27 : 0)
                .onTapGesture {
                    isTyping.toggle()
                }
        }
        .animation(.linear(duration: 0.2), value: isTyping)
    }
}
