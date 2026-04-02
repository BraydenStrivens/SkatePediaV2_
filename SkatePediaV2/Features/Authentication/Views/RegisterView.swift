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
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: RegisterViewModel
    
    @State var stanceDropdownExpanded: Bool = false
    
    init(viewModel: RegisterViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

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
                            .font(.title3)
                    }
                }
                .disabled(viewModel.isLoading)
                .frame(maxWidth: 250, maxHeight: 50)
                .background(Color.button)
                .foregroundColor(.white)
                .cornerRadius(20)
                .contentShape(Rectangle())
            }
            .padding()
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 25).protruded)
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.vertical)
    }
    
    var stanceSelectionDropDown: some View {
        HStack(alignment: .top) {
            Text("Stance:")
                .offset(y: 7)
            
            Spacer()
            
            VStack {
                // Toggle
                HStack {
                    if let currentStance = viewModel.stance {
                        Text(currentStance.camalCase)
                    } else {
                        Text("Select stance")
                    }
                    
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
                        ForEach(UserStance.allCases) { stance in
                            HStack {
                                Text(stance.camalCase)
                                    .foregroundStyle(viewModel.stance == stance ? Color.primary : .gray)
                                
                                Spacer()
                                
                                if viewModel.stance == stance {
                                    Image(systemName: "checkmark")
                                        .font(.subheadline)
                                }
                            }
                            .frame(height: 40)
                            .padding(.horizontal)
                            .onTapGesture {
                                withAnimation(.snappy) {
                                    viewModel.stance = stance
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
