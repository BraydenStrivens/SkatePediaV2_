//
//  VideoUploadService.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 2/8/26.
//

import Foundation
import SwiftUI
import PhotosUI
import AVKit

/// Represents a Firebase Storage destination for uploaded trick item videos.
///
/// The generated storage path follows the structure:
/// `trick_item_videos/{userId}/{fileId}.mp4`
///
/// - Parameters:
///   - userId: The identifier of the user who owns the uploaded video.
///   - fileId: The unique identifier used for the uploaded video file.
struct VideoUploadDestination {
    let userId: String
    let fileId: String
    
    var fullPath: String {
        return "trick_item_videos/\(userId)/\(fileId).mp4"
    }
}

/// A service responsible for loading, validating, compressing,
/// and uploading video files.
///
/// `VideoUploadService` provides utilities for:
/// - Loading videos from `PhotosPickerItem`.
/// - Validating video duration.
/// - Compressing videos to optimized upload formats.
/// - Generating resized video compositions.
/// - Uploading videos to Firebase Storage.
/// - Reporting upload progress.
/// - Cancelling in-progress exports and uploads.
///
/// Upload progress combines:
/// - Local video export progress.
/// - Firebase Storage upload progress.
@MainActor
final class VideoUploadService {
    
    // MARK: Progress
    
    /// Callback used to report combined export and upload progress.
    ///
    /// Progress values range from `0.0` to `1.0`.
    var onProgress: ((Double) -> Void)?
    
    // MARK: Private Properties
    private var exportTask: Task<URL, Error>?
    private let storageManager = StorageManager.shared
    
    // MARK: Public Actions
    
    /// Cancels any active video export or upload operation.
    ///
    /// - Important: Cancellation propagates to both the export task
    /// and Firebase Storage upload task.
    func cancel() {
        exportTask?.cancel()
        storageManager.cancelUpload()
    }
    
    // MARK: Loading
    
    /// Loads a video from a photo picker item and extracts its dimensions.
    ///
    /// The selected video is temporarily written to disk before processing.
    ///
    /// - Parameters:
    ///   - item: The selected photo picker item containing video data.
    ///
    /// - Returns: A tuple containing:
    ///   - `url`: The temporary local file URL.
    ///   - `size`: The transformed video dimensions.
    ///
    /// - Throws:
    ///   - `VideoUploadError.loadFailed` if the video data cannot be loaded.
    ///   - `VideoUploadError.invalidVideo` if the video track is invalid.
    func loadVideo(
        from item: PhotosPickerItem
    ) async throws -> (url: URL, size: CGSize) {
        
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw VideoUploadError.loadFailed
        }

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")
        
        try data.write(to: tempURL, options: [.atomic])
                
        let asset = AVURLAsset(url: tempURL)
        let tracks = try await asset.loadTracks(withMediaType: .video)
        
        guard let track = tracks.first else {
            throw VideoUploadError.invalidVideo
        }
        
        let naturalSize = try await track.load(.naturalSize)
        let transform = try await track.load(.preferredTransform)
        let transformedSize = naturalSize.applying(transform)
        
        let size = CGSize(
            width: abs(transformedSize.width),
            height: abs(transformedSize.height)
        )
        
        return (tempURL, size)
    }
    
    // MARK: Validation
    
    /// Validates that a video's duration is within an allowed limit.
    ///
    /// - Parameters:
    ///   - sourceURL: The local URL of the source video.
    ///   - max: The maximum allowed duration in seconds.
    ///
    /// - Throws:
    ///   - `VideoUploadError.invalidVideo` if the duration is invalid.
    ///   - `VideoUploadError.tooLong` if the duration exceeds the limit.
    func validateDuration(
        sourceURL: URL,
        max: Double
    ) async throws {
        
        let asset = AVURLAsset(url: sourceURL)
        let duration = try await asset.load(.duration)
        let seconds = CMTimeGetSeconds(duration)
        
        if seconds <= 0 {
            throw VideoUploadError.invalidVideo
        }
        
        if seconds > max {
            throw VideoUploadError.tooLong(maxSeconds: 4)
        }
    }
    
    // MARK: Uploading
    
    /// Compresses and uploads a video to Firebase Storage.
    ///
    /// The upload workflow includes:
    /// 1. Duration validation.
    /// 2. Video compression.
    /// 3. Video resolution extraction.
    /// 4. Firebase Storage upload.
    ///
    /// - Parameters:
    ///   - sourceURL: The local URL of the source video.
    ///   - size: The original dimensions of the source video.
    ///   - storagePath: The destination storage configuration.
    ///   - maxDuration: The maximum allowed duration in seconds.
    ///
    /// - Returns: Metadata describing the uploaded video.
    ///
    /// - Throws: An error if validation, export, or upload fails.
    func uploadVideo(
        sourceURL: URL,
        size: CGSize,
        storagePath: VideoUploadDestination,
        maxDuration: Double = 4
    ) async throws -> VideoData {

        try await validateDuration(sourceURL: sourceURL, max: maxDuration)
        
        let compressedURL = try await exportCompressedVideo(
            from: sourceURL,
            progressRange: 0...0.2
        )
        
        let newSize = try await getVideoResolution(url: compressedURL.absoluteString)
        
        // Upload to storage takes the remaining 80% of upload progress
        let uploadResult = try await uploadToStorage(
            videoURL: compressedURL,
            storagePath: storagePath,
            progressRange: 0.2...1
        )
        
        return VideoData(
            videoUrl: uploadResult.downloadURL.absoluteString,
            storagePath: uploadResult.path,
            width: newSize.width,
            height: newSize.height
        )
    }
    
    // MARK: Compression
    
    /// Compresses a video into an optimized upload format.
    ///
    /// - Parameters:
    ///   - url: The local URL of the source video.
    ///   - progressRange: The portion of total progress reserved for export.
    ///
    /// - Returns: The URL of the compressed video.
    ///
    /// - Throws:
    ///   - `CancellationError` if export is cancelled.
    ///   - `VideoUploadError.exportFailed` if export fails.
    private func exportCompressedVideo(
        from url: URL,
        progressRange: ClosedRange<Double>
    ) async throws -> URL {
        
        let asset = AVURLAsset(url: url)
        
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")
        
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(at: outputURL)
        }
        
        guard let exportSession = AVAssetExportSession(
            asset: asset,
            presetName: AVAssetExportPresetHEVCHighestQuality
        ) else {
            throw VideoUploadError.unsupportedFormat
        }
        
        exportSession.videoComposition = try await videoComposition720p(asset: asset)
        exportSession.shouldOptimizeForNetworkUse = true
        
        let exportTask = Task {
            try await exportSession.export(to: outputURL, as: .mp4)
            return outputURL
        }
        
        let progressTask = Task { [weak exportSession] in
            guard let exportSession else { return }
            
            for await state in exportSession.states(updateInterval: 0.01) {
                if case .exporting(let progress) = state {
                    let weightedProgress = self.lerp(progress.fractionCompleted, from: progressRange)
                    await MainActor.run {
                        self.onProgress?(weightedProgress)
                    }
                }
            }
        }
        
        defer {
            progressTask.cancel()
        }
        
        do {
            let resultURL = try await exportTask.value
            await MainActor.run {
                self.onProgress?(progressRange.upperBound)
            }
            progressTask.cancel()
            return resultURL
            
        } catch is CancellationError {
            progressTask.cancel()
            throw CancellationError()
            
        } catch {
            progressTask.cancel()
            throw VideoUploadError.exportFailed
        }
    }
    
    // MARK: Video Composition
    
    /// Creates a resized 720p-compatible video composition.
    ///
    /// Videos smaller than 720px wide are not upscaled.
    ///
    /// - Parameters:
    ///   - asset: The source AVAsset.
    ///
    /// - Returns: A configured video composition.
    ///
    /// - Throws: An error if asset metadata loading fails.
    private func videoComposition720p(
        asset: AVAsset
    ) async throws -> AVVideoComposition {
        
        let track = try await asset.loadTracks(withMediaType: .video).first!
        let naturalSize = try await track.load(.naturalSize)
        let preferredTransform = try await track.load(.preferredTransform)
        let duration = try await asset.load(.duration)
        
        let transformedSize = naturalSize.applying(preferredTransform)
        let videoSize = CGSize(
            width: abs(transformedSize.width),
            height: abs(transformedSize.height)
        )
        
        // Prevent upscaling if video width is already 720 or lower
        let targetWidth: CGFloat = min(720, videoSize.width)
        let scale = targetWidth / videoSize.width
        let renderSize = CGSize(
            width: targetWidth,
            height: even(videoSize.height * scale)
        )
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: duration)
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(
            assetTrack: track
        )
        var finalTransform = CGAffineTransform(scaleX: scale, y: scale)
        finalTransform = preferredTransform.concatenating(finalTransform)
        
        layerInstruction.setTransform(finalTransform, at: .zero)
        instruction.layerInstructions = [layerInstruction]
        
        let nominalFrameRate = try await track.load(.nominalFrameRate)
        let fps = nominalFrameRate > 0 ? min(60, Int(nominalFrameRate)) : 60
        
        let composition = AVMutableVideoComposition()
        composition.instructions = [instruction]
        composition.renderSize = renderSize
        composition.frameDuration = CMTime(
            value: 1,
            timescale: CMTimeScale(fps)
        )
            
        return composition
    }
    
    // MARK: Firebase Storage
    
    /// Uploads a compressed video to Firebase Storage.
    ///
    /// - Parameters:
    ///   - videoURL: The local URL of the compressed video.
    ///   - storagePath: The destination upload configuration.
    ///   - progressRange: The portion of total progress reserved for upload.
    ///
    /// - Returns: A tuple containing:
    ///   - `downloadURL`: The Firebase Storage download URL.
    ///   - `path`: The Firebase Storage path.
    ///
    /// - Throws: An error if the upload fails.
    private func uploadToStorage(
        videoURL: URL,
        storagePath: VideoUploadDestination,
        progressRange: ClosedRange<Double>
    ) async throws -> (downloadURL: URL, path: String) {
        
        return try await storageManager.uploadVideo(
            url: videoURL,
            storagePath: storagePath
        ) { progress in
            
            let weighted = self.lerp(progress, from: progressRange)
            self.onProgress?(weighted)
        }
    }
    
    // MARK: Utilities
    
    /// Linearly interpolates a progress value into a target range.
    ///
    /// - Parameters:
    ///   - value: The normalized progress value.
    ///   - range: The destination progress range.
    ///
    /// - Returns: The weighted progress value.
    private func lerp(
        _ value: Double,
        from range: ClosedRange<Double>
    ) -> Double {
        
        range.lowerBound + (range.upperBound - range.lowerBound) * value
    }
    
    /// Rounds a value down to the nearest even number.
    ///
    /// - Parameters:
    ///   - value: The value to normalize.
    ///
    /// - Returns: The nearest even value.
    private func even(
        _ value: CGFloat
    ) -> CGFloat {
        
        floor(value / 2) * 2
    }
    
    /// Retrieves the rendered resolution of a video file.
    ///
    /// - Parameters:
    ///   - url: The string representation of the video URL.
    ///
    /// - Returns: The transformed video dimensions.
    ///
    /// - Throws: An error if video metadata loading fails.
    private func getVideoResolution(url: String) async throws -> CGSize {
        let url = URL(string: url)
        let track = try await AVURLAsset(url: url!).loadTracks(withMediaType: AVMediaType.video).first
        let size = try await track!.load(.naturalSize).applying(track!.load(.preferredTransform))
        
        return CGSize(
            width: abs(size.width),
            height: abs(size.height)
        )
    }
}


