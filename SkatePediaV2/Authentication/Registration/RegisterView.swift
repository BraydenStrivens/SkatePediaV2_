//
//  RegisterView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import SwiftUI

struct RegisterView: View {
    
    @StateObject var viewModel = RegisterViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            
            Text("Register")
                .font(.largeTitle)
            
            Spacer()
            
            Spacer()
            
            VStack(spacing: 20) {
                // Displays error message to user
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(Color.red)
                }
                
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
                    color: .blue,
                    width: UIScreen.screenWidth * 0.5,
                    height: 50){
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

//#Preview {
//    RegisterView()
//}
