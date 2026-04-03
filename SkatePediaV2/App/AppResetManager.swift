//
//  AppResetManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/20/26.
//

import Foundation
import Security

/// Handles resetting the app by clearing all user data and cached files.
///
/// This includes:
/// - UserDefaults
/// - Keychain items
/// - URL cache
/// - Documents directory
///
/// Useful for logging out a user or restoring the app to a clean state.
struct AppResetManager {
    
    /// Performs a full reset of the app’s local data.
    static func reset() {
        clearUserDefaults()
        clearKeychain()
        clearURLCache()
        clearDocumentsDirectory()
    }
    
    /// Removes all data stored in UserDefaults for the app.
    private static func clearUserDefaults() {
        guard let bundleID = Bundle.main.bundleIdentifier else { return }
        UserDefaults.standard.removePersistentDomain(forName: bundleID)
        UserDefaults.standard.synchronize()
    }
    
    /// Deletes all Keychain items, including passwords, keys, certificates, and identities.
    private static func clearKeychain() {
        let securityItemClasses = [
            kSecClassGenericPassword,
            kSecClassInternetPassword,
            kSecClassCertificate,
            kSecClassKey,
            kSecClassIdentity
        ]
        
        for securityClass in securityItemClasses {
            let query: [String : Any] = [
                kSecClass as String: securityClass
            ]
            SecItemDelete(query as CFDictionary)
        }
    }
    
    /// Deletes all Keychain items, including passwords, keys, certificates, and identities.
    private static func clearURLCache() {
        URLCache.shared.removeAllCachedResponses()
    }
    
    /// Deletes all files in the app’s Documents directory.
    private static func clearDocumentsDirectory() {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        
        guard let documentsURL = urls.first else { return }
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(
                at: documentsURL,
                includingPropertiesForKeys: nil,
                options: []
            )
            
            for fileURL in fileURLs {
                try fileManager.removeItem(at: fileURL)
            }
        } catch {
            print("Failed to clear documents directory", error)
        }
    }
}
