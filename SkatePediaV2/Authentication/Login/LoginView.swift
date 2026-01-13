//
//  LoginView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import SwiftUI
import Kingfisher
///
/// Struct that display the login screen. Contains functionality to log in, register, and reset password.
///
struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel = LoginViewModel()
    @State var toggleForgotPassword: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Logo
            Image(.appLogo)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.screenWidth * 0.85, height: UIScreen.screenWidth * 0.85)
            
            Text("Login")
                .font(.system(size: UIScreen.screenWidth * 0.12))
                .fontWeight(.semibold)
                .kerning(1.5)
                .padding([.bottom], 20)
            
            VStack(spacing: 20) {
                SPTextField(
                    title: "Email",
                    borderColor: Color("AccentColor"),
                    text: $viewModel.email)
                
                SPSecureField(
                    title: "Password",
                    borderColor: Color("AccentColor"),
                    text: $viewModel.password)
                
                SPButton(
                    title: "Login",
                    rank: .primary,
                    color: Color("buttonColor"),
                    width: UIScreen.screenWidth * 0.5,
                    height: 50,
                    showLoadingAnimation: false) {
                        // Attempt Login
                        Task {
                            do {
                                try await viewModel.signIn()
                                
                            } catch let error as AuthError {
                                viewModel.error = error
                            }
                        }
                    }
            }
            
            Spacer()
            
            // Open forgot password popup button
            Button {
                toggleForgotPassword.toggle()
            } label: {
                Text("Forgot password?")
                    .foregroundColor(Color("textAccentColor"))
                    .font(.body)
            }
            .padding(.vertical, 5)
            
            // Nagivation to register view
            NavigationLink(
                destination: RegisterView(),
                label: {
                    Text("Don't have an account?")
                        .foregroundColor(Color("textAccentColor"))
                }
            )
        }
        .padding()
        .background(Color("backgroundColor"))
        // Reset password sheet
        .sheet(isPresented: $toggleForgotPassword, content: {
            ResetPasswordView(viewModel: viewModel)
                .presentationDetents([.height(300)])
        })
        .alert("Error",
               isPresented: Binding(
                get: { viewModel.error != nil },
                set: { _ in viewModel.error = nil }
               )
        ) {
            Button(role: .cancel) {
                
            } label: {
                Text("OK")
            }
        } message: {
            Text(viewModel.error?.errorDescription ?? "Error")
        }
        .alert("Reset Email Sent", isPresented: $viewModel.passwordResetSent) {
            Button(role: .cancel) {
                
            } label: {
                Text("OK")
            }
        } message: {
            Text("Please check the inputted email address for the password reset link.")
        }
    }
}

struct ResetPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Reset Password")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .kerning(1.5)
            
            Text("Enter the email registered with your account to change your password.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Divider()
            
            SPTextField(
                title: "Email",
                borderColor: Color("AccentColor"),
                text: $viewModel.resetEmail
            )
            .padding(.vertical, 10)
            
            HStack() {
                Spacer()
                
                SPButton(
                    title: "Cancel",
                    rank: .secondary,
                    color: .primary,
                    width: 100,
                    height: 40
                ) {
                    dismiss()
                }
                
                Spacer()
                
                SPButton(
                    title: "Send",
                    rank: .primary,
                    color: Color("buttonColor")
                        .opacity(viewModel.resetEmail.isEmpty ? 0.5 : 1),
                    width: 100,
                    height: 40
                ) {
                    Task {
                        await viewModel.resetPassword()
                        dismiss()
                    }
                }
                .disabled(viewModel.resetEmail.isEmpty)
                
                Spacer()
            }
            .padding(.vertical, 10)
        }
        .padding()
    }
}


