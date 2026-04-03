//
//  PasswordResetView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 4/2/26.
//

import SwiftUI

/// Screen for requesting a password reset via email.
struct PasswordResetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @StateObject var viewModel = PasswordResetViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Reset Password")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Text("Enter your registered email to reset your password.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            messagePopups
            
            SPTextField(
                title: "Email",
                borderColor: Color.accent,
                text: $viewModel.resetEmail
            )
            
            HStack(spacing: 20) {
                Button("Cancel") { dismiss() }
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .background(RoundedRectangle(cornerRadius: 15).stroke(.primary))
                    .foregroundColor(.primary)

                Button("Send") {
                    Task {
                        await viewModel.resetPassword()
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 45)
                .background(Color.button.opacity(viewModel.resetEmail.isEmpty ? 0.5 : 1))
                .foregroundColor(.white.opacity(viewModel.resetEmail.isEmpty ? 0.5 : 1))
                .cornerRadius(15)
                .disabled(viewModel.resetEmail.isEmpty)
            }
        }
        .padding()
        .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 20).protruded)
        .padding(.horizontal, 20)
    }
    
    var messagePopups: some View {
        Group {
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
            
            if !viewModel.successMessage.isEmpty {
                Text(viewModel.successMessage)
                    .foregroundStyle(Color.textAccent)
            }
        }
        .onChange(of: viewModel.errorMessage) { oldValue, newValue in
            if oldValue.isEmpty, !newValue.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    viewModel.errorMessage = ""
                }
            }
        }
        .onChange(of: viewModel.successMessage) { oldValue, newValue in
            if oldValue.isEmpty, !newValue.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    viewModel.successMessage = ""
                }
            }
        }
    }
}
