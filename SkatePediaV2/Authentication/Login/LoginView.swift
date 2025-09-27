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
    
    @StateObject var viewModel = LoginViewModel()
    @State var toggleForgotPassword: Bool = false
    
    var body: some View {
        VStack {
            // Logo
            Image(.appLogo)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.screenWidth * 0.85, height: UIScreen.screenWidth * 0.85)

            Text("Login")
                .font(.largeTitle)
                        
            Spacer()
            
            VStack(spacing: 20) {
                
                Text(viewModel.errorMessage)
                    .foregroundColor(Color.red)
                
                SPTextField(
                    title: "Email",
                    borderColor: .blue,
                    text: $viewModel.email)
                
                SPSecureField(
                    title: "Password",
                    borderColor: .blue,
                    text: $viewModel.password)
                
                SPButton(
                    title: "Login",
                    rank: .primary,
                    color: .orange,
                    width: UIScreen.screenWidth * 0.5,
                    height: 50,
                    showLoadingAnimation: false) {
                        // Attempt Login
                        Task {
                            do {
                                try await viewModel.signIn()
                                return
                            } catch {
                                viewModel.errorMessage = "Invalid Credentials"
                                print("DEBUG: Couldn't sign in ,\(error)")
                            }
                        }
                    }
            }
            
            Spacer()
            
            // Forgot password popup
            Button {
                toggleForgotPassword.toggle()
            } label: {
                Text("Forgot password?")
                    .foregroundColor(.blue)
                    .font(.body)
            }
            
            // Nagivation to register view
            NavigationLink(
                destination: RegisterView(),
                label: {
                    Text("Don't have an account?")
                        .foregroundColor(.blue)
                }
            )
        }
        .padding()
        .alert("Reset Password", isPresented: $toggleForgotPassword) {
            TextField("Email", text: $viewModel.resetEmail)
                .autocorrectionDisabled()
                .autocapitalization(.none)
            
            Button("Cancel") {
                toggleForgotPassword.toggle()
            }
            
            Button("Send") {
                viewModel.resetPassword()
            }
        } message: {
            Text("Enter email address.")
        }
    }
}
