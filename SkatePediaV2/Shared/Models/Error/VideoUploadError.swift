//
//  VideoUploadError.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/8/26.
//

import Foundation

enum VideoUploadError: LocalizedError {
    case loadFailed
    case invalidVideo
    case invalidAsset
    case tooLong(maxSeconds: Double)
    case slowMoTooLong
    case exportFailed
    case uploadFailed
    case finalizeFailed
    case unsupportedFormat
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .loadFailed:
            return "Error loading video. Please try another one."
        case .invalidVideo:
            return "This video can't be used. Please try another one."
        case .invalidAsset:
            return "Invalid video asset."
        case .tooLong(let maxSeconds):
            return "Videos must be \(maxSeconds) seconds or less."
        case .slowMoTooLong:
            return "Video must be 4 seconds or less. It is recommended that slo-motion videos are not used."
        case .exportFailed:
            return "Error processing video."
        case .uploadFailed:
            return "Upload failed. Check your connection and try again."
        case .finalizeFailed:
            return "Upload completed, but an error occured saving it."
        case .unsupportedFormat:
            return "This video format is not supported."
        case .unknown:
            return "Something went wrong."
        }
    }
}
