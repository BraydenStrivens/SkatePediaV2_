//
//  SPSecureField.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/28/25.
//

import SwiftUI

struct SPSecureField: View {
    let title: String
    let borderColor: Color
    
    @Binding var text: String
    @FocusState var isTyping: Bool
    @State private var isSecured: Bool = true
    
    var body: some View {
        HStack {
            ZStack(alignment: .leading) {
                Group {
                    if isSecured {
                        SecureField("", text: $text)
                            .padding(.leading)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()

                    } else {
                        TextField("", text: $text)
                            .padding(.leading)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }
                    
                    Text(title)
                        .padding(.horizontal, 5)
                        .foregroundColor(isTyping ? borderColor : Color.primary)
                        .background(Color("backgroundColor").opacity(isTyping || !text.isEmpty ? 1 : 0))
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(isTyping ? borderColor.opacity(isTyping || !text.isEmpty ? 1 : 0) : .primary.opacity(isTyping || !text.isEmpty ? 1 : 0), lineWidth: 1.0)
                        }
                        .padding(.leading).offset(y: isTyping || !text.isEmpty ? -27 : 0)
                        .onTapGesture {
                            isTyping.toggle()
                        }
                }
            }
            .animation(.linear(duration: 0.2), value: isTyping)
            
            Spacer()
            
            Button {
                isSecured.toggle()
            } label: {
                Image(systemName: self.isSecured ? "eye.slash" : "eye")
                    .tint(.primary)
            }
            .padding()
        }
        .frame(height: 55).focused($isTyping)
        .background(isTyping ? borderColor : Color.primary, in: RoundedRectangle(cornerRadius: 14).stroke(lineWidth: 2))
    }
}
//
//#Preview {
//    SPSecureField()
//}
