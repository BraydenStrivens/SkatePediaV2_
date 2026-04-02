//
//  LoginView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import SwiftUI

/// Struct that display the login screen. Contains functionality to log in, navigate to register view, and reset password.
///
struct LoginView: View {
    @EnvironmentObject var errorStore: ErrorStore
    @EnvironmentObject var overlayManager: OverlayManager
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: LoginViewModel

    @State var toggleForgotPassword: Bool = false
        
    init(viewModel: LoginViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Spacer()
                
                Image(.appLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: UIScreen.main.bounds.height * 0.25)
                    .padding()
                
                Spacer()
                
                loginBox
                
                Spacer()
                
                NavigationLink(
                    "Don't have an account?",
                    destination: RegisterViewBuilder(
                        errorStore: errorStore
                    )
                    .toolbarRole(.editor)
                    
                )
                .foregroundColor(Color.textAccent)
            }
            .padding(.vertical)
            
            // Reset password card overlay
            if toggleForgotPassword {
                // Dimmed background
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        hideResetPasswordCard()
                    }
                
                resetPasswordCard
                    .zIndex(1)
                    .frame(maxWidth: 350)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity))
                    )
            }
        }
    }
    
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
            
            SPSecureField(
                title: "Password",
                borderColor: Color.accent,
                text: $viewModel.password
            )
            
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
                        
                }
            }
            .disabled(viewModel.loginLoading)
            .frame(maxWidth: 250, maxHeight: 50)
            .background(Color.button)
            .foregroundColor(.white)
            .contentShape(Rectangle())
            .cornerRadius(20)
        }
        .padding()
        .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 25).protruded)
        .padding(.horizontal, 20)
    }
    
    /// Popup containing an text field and button so send a password reset link to the inputted email.
    ///
    var resetPasswordCard: some View {
        VStack(spacing: 20) {
            Text("Reset Password")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Text("Enter your registered email to reset your password.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            SPTextField(
                title: "Email",
                borderColor: Color.accent,
                text: $viewModel.resetEmail
            )
            
            HStack(spacing: 20) {
                Button("Cancel") { hideResetPasswordCard() }
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .background(RoundedRectangle(cornerRadius: 15).stroke(.primary))
                    .foregroundColor(.primary)

                Button("Send") {
                    Task {
                        let success = await viewModel.resetPassword()
                        
                        if success {
                            hideResetPasswordCard()

                            _ = overlayManager.present(level: .popup) { id in
                                ErrorPopup(
                                    error: AppError(
                                        title: "Reset Email Sent",
                                        message: "Login to the inputted email to reset your password."),
                                    style: .autoDismiss(seconds: 2),
                                    onDismiss: {
                                        overlayManager.dismiss(id: id)
                                    }
                                )
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 45)
                .background(Color.button.opacity(viewModel.resetEmail.isEmpty ? 0.5 : 1))
                .foregroundColor(.white)
                .cornerRadius(15)
                .disabled(viewModel.resetEmail.isEmpty)
            }
        }
        .padding()
        .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 20).protruded)
        .padding(.horizontal, 20)
    }
    
    /// Sets the password reset cards toggle boolean to false.
    func hideResetPasswordCard() {
        withAnimation(.spring(duration: 0.2)) {
            toggleForgotPassword = false
        }
    }
}
