//
//  SPTextField.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/27/25.
//

import SwiftUI

struct SPTextFieldDemo: View {
    
    @State var Fname = ""
    @State var Lname = ""
    
    var body: some View {
        VStack(spacing: 50) {
            SPTextField(title: "First Name", borderColor: .blue, text: $Fname)
            SPTextField(title: "Last Name", borderColor: .red, text: $Lname)
        }
        .padding()
        .background {
            Color.gray
        }
    }
}

struct SPTextField: View {
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
        .animation(.linear(duration: 0.2), value: isTyping)
    }
}

//#Preview {
//    SPTextFieldDemo()
//}
