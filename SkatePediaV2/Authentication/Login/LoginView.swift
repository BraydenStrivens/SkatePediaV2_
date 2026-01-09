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
                .foregroundColor(Color("textColor"))
                .padding([.bottom], 20)
            
            VStack(spacing: 20) {
                SPTextField(
                    title: "Email",
                    borderColor: Color("accentColor"),
                    text: $viewModel.email)
                
                SPSecureField(
                    title: "Password",
                    borderColor: Color("accentColor"),
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
                .presentationDetents([.height(250)])
                .presentationBackground(Color("backgroundColor"))
        })
        // Error message popup
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
            Text(viewModel.error?.localizedDescription ?? "")
        }
    }
}

struct ResetPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Reset Password")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .kerning(1.5)
            
            SPTextField(title: "Email", borderColor: Color("accentColor"), text: $viewModel.resetEmail)
            
            HStack {
                Spacer()
                
                Button("Cancel", role: .destructive) {
                    dismiss()
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.red, lineWidth: 1)
                }
                
                Spacer()
                
                Button("Send") {
                    Task {
                        do {
                            try await viewModel.resetPassword()
                            dismiss()
                        } catch let error as AuthError {
                            viewModel.error = error
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("accentColor"), lineWidth: 1)
                }
                
                Spacer()
            }
        }
        .padding()
    }
}


