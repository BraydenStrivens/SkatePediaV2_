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
        VStack(spacing: 0) {
            // Logo
            Image(.appLogo)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.screenWidth * 0.8, height: UIScreen.screenWidth * 0.8)
            
            Text("Register")
                .font(.system(size: UIScreen.screenWidth * 0.12))
                .fontWeight(.semibold)
                .kerning(1.5)
                .padding([.bottom], 20)
                        
            VStack(spacing: 20) {
                SPTextField(
                    title: "Username",
                    borderColor: Color("AccentColor"),
                    text: $viewModel.username)
                
                SPTextField(
                    title: "Email",
                    borderColor: Color("AccentColor"),
                    text: $viewModel.email)
                
                SPSecureField(
                    title: "Password",
                    borderColor: Color("AccentColor"),
                    text: $viewModel.password)
                
                CustomDropDownView(title: "Stance:", prompt: "", options: ["Regular", "Goofy"], selection: $viewModel.stance)
                
                Spacer()
                
                SPButton(
                    title: "Register",
                    rank: .primary,
                    color: Color("buttonColor"),
                    width: UIScreen.screenWidth * 0.5,
                    height: 50,
                    showLoadingAnimation: false) {
                        // Attemp Registration
                        Task {
                            do {
                                try await viewModel.createUser()
                                
                            } catch let error as AuthError {
                                viewModel.createUserError = error

                            } catch let error as FirestoreError {
                                viewModel.uploadUserDocError = error
                            }
                        }
                    }
            }
            
            Spacer()
        }
        .padding()
        .background(Color("backgroundColor"))
        // Create user error popup
        .alert("Error Creating User",
               isPresented: Binding(
                get: { viewModel.createUserError != nil },
                set: { _ in viewModel.createUserError = nil }
               )
        ) {
            Button(role: .cancel) {
                
            } label: {
                Text("OK")
            }
        } message: {
            Text(viewModel.createUserError?.localizedDescription ?? "")
        }
        // Upload user document error popup
        .alert("Error Uploading User Information",
               isPresented: Binding(
                get: { viewModel.uploadUserDocError != nil },
                set: { _ in viewModel.uploadUserDocError = nil }
               )
        ) {
            Button(role: .cancel) {
                
            } label: {
                Text("OK")
            }
        } message: {
            Text(viewModel.uploadUserDocError?.localizedDescription ?? "")
            Text("Please try to recreated your account.")
        }
    }
}
