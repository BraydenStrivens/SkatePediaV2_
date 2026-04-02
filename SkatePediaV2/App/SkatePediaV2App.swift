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

class AppDelegate: NSObject, UIApplicationDelegate {
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

@main
struct SkatePediaV2App: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var authStore = AuthenticationStore()
    @StateObject var sessionContainer = SessionContainer()
    
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
            .environmentObject(authStore)
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
