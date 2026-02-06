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
        initializeEmulator()
        return true
    }
}

@main
struct SkatePediaV2App: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    init() {
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(named: "buttonColor")
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground() // makes it solid
        appearance.backgroundColor = UIColor(named: "backgroundColor") // or your custom color
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
                .onAppear {
                    Task {
//#if DEBUG
//                        try? Auth.auth().signOut()
//#endif
                    }
                }
        }
    }
}

func initializeEmulator() {
//    let db = Firestore.firestore()
//    db.settings = {
//        let settings = FirestoreSettings()
//        settings.cacheSettings = MemoryCacheSettings()
//        return settings
//    }()
    let firestore = Firestore.firestore()
    let settings = firestore.settings
    settings.host = "127.0.0.1:8080"
    settings.isSSLEnabled = false
    settings.cacheSettings = MemoryCacheSettings()
    firestore.settings = settings
//    db.useEmulator(withHost: "127.0.0.1", port: 8080)
    Auth.auth().useEmulator(withHost: "127.0.0.1", port: 9099)
    Functions.functions().useEmulator(withHost: "127.0.0.1", port: 5001)
    Storage.storage().useEmulator(withHost: "127.0.0.1", port: 9199)
    
    
    
    print("=====================================")
    print("HOST: \(Firestore.firestore().settings.host)")
}
