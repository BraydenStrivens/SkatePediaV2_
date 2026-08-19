//
//  LoginView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import SwiftUI

/// Login screen that handles user sign-in, registration navigation,
/// and password reset presentation.
struct LoginView: View {
    
    // MARK: Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var router: AuthRouter
    
    // MARK: State
    @State private var toggleForgotPassword: Bool = false
    @FocusState private var focusedField: Field?
    
    // MARK: Parameters
    @ObservedObject var viewModel: LoginViewModel

    // MARK: Private Properties
    
    /// Focusable text fields within the view.
    private enum Field {
        case email
        case password
    }

    // MARK: Init
    init(viewModel: LoginViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    // MARK: Body
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Spacer()
                
                Image(.appLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: UIScreen.main.bounds.height * 0.22)
                    .padding()
                
                Spacer()
                
                loginBox
                
                Spacer()
                
                Button {
                    router.push(.register)
                } label: {
                    Text("Don't have an account?")
                    Text("Sign Up.")
                        .fontWeight(.semibold)
                }
                .foregroundColor(Color.textAccent)
            }
            .padding(.vertical)
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
        }
        .fullScreenCover(isPresented: $toggleForgotPassword) {
            PasswordResetView()
        }
    }
    
    // MARK: Subviews
    
    var loginBox: some View {
        VStack(spacing: 20) {
            Text("Login")
                .font(.system(size: UIScreen.screenWidth * 0.1))
                .fontWeight(.semibold)
                .kerning(1.2)
            
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
            
            Button("Forgot password?") {
                withAnimation(.spring(duration: 0.3)) {
                    toggleForgotPassword = true
                }
            }
            .foregroundColor(Color.textAccent)
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            // Login button
            Button {
                Task { await viewModel.signIn() }
            } label: {
                if viewModel.loginLoading {
                    CustomProgressView(placement: .center)
                } else {
                    Text("Login")
                        .font(.title3)
                        .frame(minWidth: 250, minHeight: 50)
                        .background(Color.button)
                        .foregroundColor(.white)
                        .contentShape(Rectangle())
                        .cornerRadius(20)
                }
            }
            .disabled(viewModel.loginLoading)
        }
        .padding()
        .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 25).protruded)
        .padding(.horizontal, 20)
    }
}
