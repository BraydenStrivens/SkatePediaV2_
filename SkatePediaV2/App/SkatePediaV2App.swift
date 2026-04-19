//
//  SkatePediaV2App.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/10/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions
import FirebaseStorage

/// Handles app lifecycle events and performs Firebase configuration on launch.
class AppDelegate: NSObject, UIApplicationDelegate {
    /// Called when the app has finished launching.
        ///
        /// - Parameters:
        ///   - application: The singleton app object.
        ///   - launchOptions: A dictionary indicating the reason the app was launched (if any).
        ///
        /// - Returns: `true` if the app launched successfully.
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
//        initializeEmulator()
        return true
    }
}

/// The main entry point of the SkatePediaV2 app.
///
/// Initializes global stores, configures UI appearance, and injects environment objects
/// into the root view.
@main
struct SkatePediaV2App: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var sessionContainer = SessionContainer()

    @StateObject private var authStore = AuthenticationStore()
    @StateObject private var userStore = UserStore()
    @StateObject private var trickListStore = TrickListStore()
    @StateObject private var trickItemStore = TrickItemStore()
    @StateObject private var postStore = PostStore()
    @StateObject private var notificationStore = NotificationStore()
    
    /// Sets up global UI appearance.
    init() {
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(named: "buttonColor")
        UITabBar.appearance().isHidden = true
    }
    
    var body: some Scene {
        WindowGroup {
            OverlayHost {
                RootView()
                    .tint(.primary)
            }
            // Inject environment objects for global state
            .environmentObject(authStore)
            .environmentObject(userStore)
            .environmentObject(trickListStore)
            .environmentObject(trickItemStore)
            .environmentObject(postStore)
            .environmentObject(notificationStore)

            .environmentObject(sessionContainer)
            .environmentObject(sessionContainer.userStore)
            .environmentObject(sessionContainer.trickListStore)
            .environmentObject(sessionContainer.trickItemStore)
            .environmentObject(sessionContainer.postStore)
            .onAppear {
                Task {
//                    #if DEBUG
//                                            try? Auth.auth().signOut()
//                    #endif
                }
            }
        }
    }
}

/// Configures Firebase to use local emulators for development.
///
/// Used for local testing without connecting to production services.
func initializeEmulator() {
    let firestore = Firestore.firestore()
    let settings = firestore.settings
    settings.host = "127.0.0.1:8080"
    settings.isSSLEnabled = false
    settings.cacheSettings = MemoryCacheSettings()
    firestore.settings = settings
    Auth.auth().useEmulator(withHost: "127.0.0.1", port: 9099)
    Functions.functions().useEmulator(withHost: "127.0.0.1", port: 5001)
    Storage.storage().useEmulator(withHost: "127.0.0.1", port: 9199)
    print("=====================================")
    print("HOST: \(Firestore.firestore().settings.host)")
}
