//
//  RegisterView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import SwiftUI

/// Registration screen for creating a new account with user details and stance selection.
struct RegisterView: View {
    
    // MARK: Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
        
    // MARK: State
    @State private var stanceDropdownExpanded: Bool = false
    @FocusState private var focusedField: Field?
    
    // MARK: Parameters
    @ObservedObject var viewModel: RegisterViewModel

    // MARK: Private Properties
    
    /// Focusable text fields within the view.
    private enum Field {
        case username
        case email
        case password
    }
    
    // MARK: Init
    init(viewModel: RegisterViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    // MARK: Body
    var body: some View {
        VStack(spacing: 0) {
            Image(.appLogo)
                .resizable()
                .scaledToFit()
                .frame(height: UIScreen.main.bounds.height * 0.22)
                .padding()
            
            Spacer()
            
            registerBox
            
            Spacer()
        }
        .customNavHeader(title: "")
        .padding(.vertical)
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
    }
    
    // MARK: Subviews
    
    var registerBox: some View {
        VStack(spacing: 20) {
            Text("Register")
                .font(.system(size: UIScreen.screenWidth * 0.1))
                .fontWeight(.semibold)
                .kerning(1.2)
            
            SPTextField(
                title: "Username",
                borderColor: Color.accent,
                text: $viewModel.username
            )
            .focused($focusedField, equals: .username)
            
            SPTextField(
                title: "Email",
                borderColor: Color.accent,
                text: $viewModel.email
            )
            .keyboardType(.emailAddress)
            .focused($focusedField, equals: .email)
            
            SPSecureField(
                title: "Password",
                borderColor: Color.accent,
                text: $viewModel.password
            )
            .focused($focusedField, equals: .password)
            
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
                        .frame(minWidth: 250, minHeight: 50)
                        .background(Color.button)
                        .foregroundColor(.white)
                        .contentShape(Rectangle())
                        .cornerRadius(20)
                }
            }
            .disabled(viewModel.isLoading)
        }
        .padding()
        .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 25).protruded)
        .padding(.horizontal, 20)
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
