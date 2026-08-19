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
    
    // MARK: Color Scheme
    
//    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("appTheme") private var appTheme = AppTheme.system.rawValue
    
    // MARK: Tabbar Router
    
    @StateObject private var tabRouter = TabRouter()
    
    // MARK: Global Stores

    @StateObject private var authStore: AuthenticationStore
    @StateObject private var userStore: UserStore
    @StateObject private var trickListStore: TrickListStore
    @StateObject private var trickItemStore: TrickItemStore
    @StateObject private var prosStore: ProsStore
    @StateObject private var postStore: PostStore
    @StateObject private var notificationStore: NotificationStore
    
    let appEnvironment: AppEnvironment
    
    // MARK: Init
    
    /// Sets up global UI appearance and initializes global stores
    init() {
        FirebaseApp.configure()
//        initializeEmulator()

        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(named: "buttonColor")
        UITabBar.appearance().isHidden = true
        
        let authStore = AuthenticationStore()
        let userStore = UserStore()
        let trickListStore = TrickListStore()
        let trickItemStore = TrickItemStore()
        let prosStore = ProsStore()
        let postStore = PostStore()
        let notificationStore = NotificationStore()
        
        _authStore = StateObject(wrappedValue: authStore)
        _userStore = StateObject(wrappedValue: userStore)
        _trickListStore = StateObject(wrappedValue: trickListStore)
        _trickItemStore = StateObject(wrappedValue: trickItemStore)
        _prosStore = StateObject(wrappedValue: prosStore)
        _postStore = StateObject(wrappedValue: postStore)
        _notificationStore = StateObject(wrappedValue: notificationStore)

        self.appEnvironment = AppEnvironment(
            userStore: userStore,
            trickListStore: trickListStore,
            trickItemStore: trickItemStore,
            prosStore: prosStore,
            postStore: postStore,
            notificationStore: notificationStore
        )
    }
    
    // MARK: Private Properties
    
    private var currentTheme: AppTheme {
        AppTheme(rawValue: appTheme) ?? .system
    }
    
    // MARK: Body
    
    var body: some Scene {
        WindowGroup {
            OverlayHost {
                RootView()
                    .tint(.primary)
                    .preferredColorScheme(currentTheme.colorScheme)
            }
            // Inject environment objects for global state
            .environmentObject(appEnvironment)
            .environmentObject(tabRouter)
            .environmentObject(authStore)
            .environmentObject(userStore)
            .environmentObject(trickListStore)
            .environmentObject(trickItemStore)
            .environmentObject(prosStore)
            .environmentObject(postStore)
            .environmentObject(notificationStore)
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
private func initializeEmulator() {
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
