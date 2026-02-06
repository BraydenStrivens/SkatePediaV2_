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
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = LoginViewModel()
    @State var toggleForgotPassword: Bool = false

    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // App logo
                Image(.appLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: UIScreen.main.bounds.height * 0.25)
                    .padding()
                
                Spacer()
                
                // Login Box
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
                
                // Links
                VStack(spacing: 4) {
                    Button("Forgot password?") {
                        withAnimation(.spring(duration: 0.3)) {
                            toggleForgotPassword = true
                        }
                    }
                    .foregroundColor(Color.textAccent)
                    
                    NavigationLink("Don't have an account?", destination: RegisterView())
                        .foregroundColor(Color.textAccent)
                }
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
        .alert("Error",
               isPresented: Binding(
                get: { viewModel.error != nil },
                set: { _ in viewModel.error = nil }
               )
        ) {
            Button("OK") {}
        } message: {
            Text(viewModel.error?.errorDescription ?? "Error")
        }
        .alert("Reset Email Sent", isPresented: $viewModel.passwordResetSent) {
            Button("OK") { viewModel.passwordResetSent = false }
        } message: {
            Text("Please check the inputted email for the password reset link.")
        }
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
                        await viewModel.resetPassword()
                        hideResetPasswordCard()
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
        .background(RoundedRectangle(cornerRadius: 25)
            .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
            .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.2),
                    radius: 10, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
    }
    
    /// Sets the password reset cards toggle boolean to false.
    func hideResetPasswordCard() {
        withAnimation(.spring(duration: 0.2)) {
            toggleForgotPassword = false
        }
    }
}
