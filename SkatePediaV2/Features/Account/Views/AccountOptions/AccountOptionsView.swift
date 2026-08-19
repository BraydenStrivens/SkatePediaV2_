//
//  SettingsView.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import SwiftUI
import FirebaseAuth

/// View displaying the account settings and management options for a user.
///
/// Organizes settings into sections for account info, app information, and account management.
/// Provides functionality for navigation to profile and trick settings, logging out,
/// updating password, and deleting the account.
///
/// - Parameters:
///   - user: The current user whose account settings are being managed.
///   - viewModel: The view model responsible for handling account actions such as sign out, password updates, and account deletion.
struct AccountOptionsView: View {
    @EnvironmentObject private var router: AccountRouter
    @EnvironmentObject var overlayManager: OverlayManager

    @Environment(\.colorScheme) private var colorScheme
    
    @AppStorage("appTheme") private var appTheme = AppTheme.system.rawValue
    
    @State private var toggleUpdatePassword: Bool = false
    @State private var toggleDeleteAccountVerifyer: Bool = false
    @State private var newPassword: String = ""

    @ObservedObject var viewModel: AccountOptionsViewModel
    let user: User
    
    init(
        user: User,
        viewModel: AccountOptionsViewModel
    ) {
        self.user = user
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                settingsViewSection(header: "Account Info") {
                    AccountDetails(user: user)
                        .environmentObject(viewModel)
                }
                
                settingsViewSection(header: "Settings") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Theme: ")
                            .font(.caption)
                            .foregroundStyle(.gray)
                                                
                        Picker("Appearance", selection: $appTheme) {
                            ForEach(AppTheme.allCases) { theme in
                                Text(theme.displayName)
                                    .tag(theme.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Divider()
                    
                    settingsCell(
                        title: "Profile Settings",
                        navigationAction: {
                            router.push(.profileSettings)
                        }
                    )

                    Divider()
                       
                    settingsCell(
                        title: "Trick Settings",
                        navigationAction: {
                            router.push(.trickItemSettings)
                        }
                    )
                }
                
                settingsViewSection(header: "App Information") {
                    
                    settingsCell(
                        title: "About SkatePedia",
                        navigationAction: {
                            router.push(.aboutSkatePedia)
                        }
                    )

                    Divider()
                    
                    settingsCell(
                        title: "Terms of Service",
                        navigationAction: {
                            router.push(.termsOfService)
                        }
                    )

                    Divider()

                    settingsCell(
                        title: "Privacy Policy",
                        navigationAction: {
                            router.push(.privacyPolicy)
                        }
                    )
                }
                
                settingsViewSection(header: "Manage Account") {
                    Button("Log out") {
                        viewModel.signOut()
                    }
                    .tint(Color("textAccentColor"))
                    
                    Divider()
                    
                    Button("Update Password") {
                        toggleUpdatePassword.toggle()
                    }
                    .tint(Color("textAccentColor"))
                    .alert("Update Password", isPresented: $toggleUpdatePassword) {
                        updatePasswordPopupView
                    } message: {
                        Text("Enter new password.")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        toggleDeleteAccountVerifyer.toggle()
                    } label: {
                        Text("Delete Account")
                    }
                    .alert("Delete Account", isPresented: $toggleDeleteAccountVerifyer) {
                        verifyDeleteAccountPopup
                    } message: {
                        Text("Are you SURE you want to delete your account? All data and videos will be permenantly deleted...")
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .customNavHeader(
            title: "Settings",
            showDivider: true
        )
    }
    
    private func settingsCell(
        title: String,
        navigationAction: @escaping () -> Void
    ) -> some View {
        Button {
            navigationAction()
        } label: {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
    }
    
    func settingsViewSection<Content: View>(
        header: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(header)
                .font(.caption)
                .foregroundStyle(.gray)
            
            VStack(alignment: .leading, spacing: 12) {
                content()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SPBackgrounds(colorScheme: colorScheme, cornerRadius: 15).protruded)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
    }
    
    @ViewBuilder
    var updatePasswordPopupView: some View {
        TextField("New Password", text: $newPassword)
            .autocorrectionDisabled()
            .autocapitalization(.none)
        
        Button("Cancel", role: .cancel) {
            toggleUpdatePassword.toggle()
        }
        
        Button("Update") {
            Task {
                let success = await viewModel.updatePassword(password: newPassword)
                
                if success {
                    _ = overlayManager.present(level: .popup) { id in
                        ErrorPopup(
                            error: AppError(
                                title: "Operation Complete",
                                message: "Successfully updated password."),
                            style: .autoDismiss(seconds: 2),
                            onDismiss: {
                                overlayManager.dismiss(id: id)
                            }
                        )
                    }
                }
            }
        }
    }
    
    var verifyDeleteAccountPopup: some View {
        Button("Delete", role: .destructive) {
            Task {
                await viewModel.deleteUser()
            }
        }
    }
}


