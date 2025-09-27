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
    
    var body: some View {
        VStack {
            // Logo
            Image(.appLogo)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.screenWidth * 0.8, height: UIScreen.screenWidth * 0.8)
            
            Text("Register")
                .font(.largeTitle)
            
            Spacer()
            
            VStack(spacing: 20) {
                // Displays error message to user
                Text(viewModel.errorMessage)
                    .foregroundColor(Color.red)
                
                SPTextField(
                    title: "Username",
                    borderColor: .green,
                    text: $viewModel.username)
                
                SPTextField(
                    title: "Email",
                    borderColor: .green,
                    text: $viewModel.email)
                
                SPSecureField(
                    title: "Password",
                    borderColor: .green,
                    text: $viewModel.password)
                
                CustomDropDownView(title: "Stance:", prompt: "", options: ["Regular", "Goofy"], selection: $viewModel.stance)
                
                SPButton(
                    title: "Register",
                    rank: .primary,
                    color: .orange,
                    width: UIScreen.screenWidth * 0.5,
                    height: 50,
                    showLoadingAnimation: false){
                        // Attemp Registration
                        Task {
                            do {
                                try await viewModel.createUser()
                                return
                            } catch {
                                print("DEBUG: COULDNT SIGN UP, \(error.localizedDescription)")
                            }
                        }
                    }
            }
            
            Spacer()
        }
        .padding()
    }
}
