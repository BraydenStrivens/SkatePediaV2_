//
//  AppResetManager.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/20/26.
//

import Foundation
import Security

struct AppResetManager {
    static func reset() {
        clearUserDefaults()
        clearKeychain()
        clearURLCache()
        clearDocumentsDirectory()
    }
    
    private static func clearUserDefaults() {
        guard let bundleID = Bundle.main.bundleIdentifier else { return }
        UserDefaults.standard.removePersistentDomain(forName: bundleID)
        UserDefaults.standard.synchronize()
    }
    
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
    
    private static func clearURLCache() {
        URLCache.shared.removeAllCachedResponses()
    }
    
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
