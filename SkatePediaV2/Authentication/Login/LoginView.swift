//
//  LoginView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import SwiftUI

struct LoginView: View {
    
    @StateObject var viewModel = LoginViewModel()
    @State var toggleForgotPassword: Bool = false
    
    var body: some View {
        VStack {
            Image(systemName: "figure.skateboarding")
                .resizable()
                .scaledToFit()
                .frame(width: 250)
            
            Text("SkatePedia")
                .font(.largeTitle)
            
            Text("Login")
                .font(.title)
                        
            Spacer()
            
            VStack(spacing: 20) {
                
                // Displays error message to user
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(Color.red)
                }
                
                SPTextField(
                    title: "Email",
                    borderColor: .green,
                    text: $viewModel.email)
                
                SPSecureField(
                    title: "Password",
                    borderColor: .green,
                    text: $viewModel.password)
                
                SPButton(
                    title: "Login",
                    rank: .primary,
                    color: .blue,
                    width: UIScreen.screenWidth * 0.5,
                    height: 50) {
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
            
            Button {
                toggleForgotPassword.toggle()
            } label: {
                Text("Forgot password?")
                    .foregroundColor(.blue)
                    .font(.body)
            }
            
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
