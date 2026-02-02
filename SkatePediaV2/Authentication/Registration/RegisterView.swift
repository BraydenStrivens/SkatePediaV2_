//
//  RegisterView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import SwiftUI

///
/// Struct that displays the register account screen. Users register with a username, email, password, and skateboard stance.
///
struct RegisterView: View {
    @StateObject var viewModel = RegisterViewModel()
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State var stanceDropdownExpanded: Bool = false
    private let stanceOptions = ["Regular", "Goofy"]

    var body: some View {
        VStack(spacing: 0) {
            Image(.appLogo)
                .resizable()
                .scaledToFit()
                .frame(height: UIScreen.main.bounds.height * 0.25)
                .padding()
            
            Spacer()
            
            VStack(spacing: 20) {

                Text("Register")
                    .font(.system(size: UIScreen.screenWidth * 0.1))
                    .fontWeight(.semibold)
                    .kerning(1.2)
                
                SPTextField(
                    title: "Username",
                    borderColor: Color.accent,
                    text: $viewModel.username)
                
                SPTextField(
                    title: "Email",
                    borderColor: Color.accent,
                    text: $viewModel.email)
                
                SPSecureField(
                    title: "Password",
                    borderColor: Color.accent,
                    text: $viewModel.password)
                
                stanceSelectionDropDown
                
                Button {
                    Task {
                        await viewModel.createUser()
                    }
                } label: {
                    if viewModel.isLoading {
                        CustomProgressView(placement: .center)
                    } else {
                        Text("Register")
                    }
                }
                .font(.title3)
                .frame(maxWidth: 250, maxHeight: 50)
                .background(Color.button)
                .foregroundColor(.white)
                .cornerRadius(20)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 25)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.2),
                        radius: 10, x: 0, y: 4)
            )
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.vertical)
        // Create user error popup
        .alert("Error Creating User",
               isPresented: Binding(
                get: { viewModel.error != nil },
                set: { _ in viewModel.error = nil }
               )
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "")
        }
    }
    
    var stanceSelectionDropDown: some View {
        HStack(alignment: .top) {
            Text("Stance:")
                .offset(y: 7)
            
            Spacer()
            
            VStack {
                // Toggle
                HStack {
                    Text(viewModel.stance == "" ? "Select a stance" : viewModel.stance)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .rotationEffect(.degrees(stanceDropdownExpanded ? -180 : 0))
                    
                }
                .frame(height: 40)
                .background(Color(.systemBackground))
                
                .padding(.horizontal)
                .onTapGesture {
                    withAnimation(.snappy) {
                        stanceDropdownExpanded.toggle()
                    }
                }
                // Toggled dropdown
                if stanceDropdownExpanded {
                    VStack {
                        ForEach(stanceOptions, id: \.self) { option in
                            HStack {
                                Text(option)
                                    .foregroundStyle(viewModel.stance == option ? Color.primary : .gray)
                                
                                Spacer()
                                
                                if viewModel.stance == option {
                                    Image(systemName: "checkmark")
                                        .font(.subheadline)
                                }
                            }
                            .frame(height: 40)
                            .padding(.horizontal)
                            .onTapGesture {
                                withAnimation(.snappy) {
                                    viewModel.stance = option
                                    stanceDropdownExpanded.toggle()
                                }
                            }
                        }
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.5), radius: 4)
            .frame(width: 200)
            
            
        }
    }
}

//struct CustomDropDownView: View {
//    let title: String
//    let prompt: String
//    let options: [String]
//    
//    @State private var isExpanded: Bool = false
//    
//    @Binding var selection: String
//    
//    @Environment(\.colorScheme) var scheme
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(title)
//                .font(.footnote)
//                .foregroundStyle(.gray)
//                .opacity(0.8)
//            
//            VStack {
//                HStack {
//                    Text(selection == "" ? prompt : selection)
//                    
//                    Spacer()
//                    
//                    Image(systemName: "chevron.down")
//                        .font(.subheadline)
//                        .foregroundStyle(.gray)
//                        .rotationEffect(.degrees(isExpanded ? -180 : 0))
//                    
//                }
//                .frame(height: 40)
//                .background(scheme == .dark ? .black : .white)
//
//                .padding(.horizontal)
//                .onTapGesture {
//                    withAnimation(.snappy) {
//                        isExpanded.toggle()
//                    }
//                }
//                
//                if isExpanded {
//                    VStack {
//                        ForEach(options, id: \.self) { option in
//                            HStack {
//                                Text(option)
//                                    .foregroundStyle(selection == option ? Color.primary : .gray)
//                                
//                                Spacer()
//                                
//                                if selection == option {
//                                    Image(systemName: "checkmark")
//                                        .font(.subheadline)
//                                }
//                            }
//                            .frame(height: 40)
//                            .padding(.horizontal)
//                            .onTapGesture {
//                                withAnimation(.snappy) {
//                                    selection = option
//                                    isExpanded.toggle()
//                                }
//                            }
//                        }
//                    }
//                    .transition(.move(edge: .bottom))
//                }
//            }
//            .background(scheme == .dark ? .black : .white)
//            .clipShape(RoundedRectangle(cornerRadius: 10))
//            .shadow(color: Color.primary.opacity(0.5), radius: 4)
//            .frame(width: 200)
//        }
//    }
//}
