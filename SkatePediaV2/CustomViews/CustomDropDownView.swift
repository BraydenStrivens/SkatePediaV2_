//
//  DropDownView.swift
//  SwiftUIPractice
//
//  Created by Brayden Strivens on 12/11/24.
//

import SwiftUI

struct CustomDropDownView: View {
    let title: String
    let prompt: String
    let options: [String]
    
    @State private var isExpanded: Bool = false
    
    @Binding var selection: String
    
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.gray)
                .opacity(0.8)
            
            VStack {
                HStack {
                    Text(selection == "" ? prompt : selection)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .rotationEffect(.degrees(isExpanded ? -180 : 0))
                    
                }
                .frame(height: 40)
                .background(scheme == .dark ? .black : .white)

                .padding(.horizontal)
                .onTapGesture {
                    withAnimation(.snappy) {
                        isExpanded.toggle()
                    }
                }
                
                if isExpanded {
                    VStack {
                        ForEach(options, id: \.self) { option in
                            HStack {
                                Text(option)
                                    .foregroundStyle(selection == option ? Color.primary : .gray)
                                
                                Spacer()
                                
                                if selection == option {
                                    Image(systemName: "checkmark")
                                        .font(.subheadline)
                                }
                            }
                            .frame(height: 40)
                            .padding(.horizontal)
                            .onTapGesture {
                                withAnimation(.snappy) {
                                    selection = option
                                    isExpanded.toggle()
                                }
                            }
                        }
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            .background(scheme == .dark ? .black : .white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: Color.primary.opacity(0.5), radius: 4)
            .frame(width: 200)
        }
    }
}

#Preview {
    CustomDropDownView(title: "Make", prompt: "Select", options: [
        "Lambo",
        "Ferrari",
        "Aston Martin"
    ], selection: .constant("Lambo"))
}
