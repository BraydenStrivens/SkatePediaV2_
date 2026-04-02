//
//  AppError.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/1/26.
//

import Foundation

struct AppError: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
