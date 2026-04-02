//
//  EncodableExtension.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/28/25.
//

import Foundation

extension Encodable {
    /// Returns the data from a json file as a dictionary
    ///
    /// - Returns: A dictionary containing data from a json file.
    func asDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else {
            return [:]
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data) as?[String: Any]
            return json ?? [:]
        } catch {
            return [:]
        }
    }
}
