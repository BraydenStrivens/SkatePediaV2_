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

struct VideoUploadDestination {
    enum StorageVideoSource: String {
        case trickItem = "trick_item_videos"
        case message = "message_files"
    }
    
    let uploadSource: StorageVideoSource
    let userId: String
    let fileId: String
    
    var fullPath: String {
        return "\(uploadSource.rawValue)/\(userId)/\(fileId).mp4"
    }
}

@MainActor
final class VideoUploadService {
    // Unified progress combining export and storage upload progress
    var onProgress: ((Double) -> Void)?
    
    private var exportTask: Task<URL, Error>?
    private let storageManager = StorageManager.shared
    
    func cancel() {
        exportTask?.cancel()
        storageManager.cancelUpload()
        print("CANCELLED EXPORT AND UPLOAD")
    }
    
    struct PreviewVideo {
        let player: AVPlayer
        let playerItem: AVPlayerItem
        let size: CGSize
    }
    
    func loadVideo(
        from item: PhotosPickerItem
    ) async throws -> (url: URL, size: CGSize) {
        print("LOADING VIDEO...")
        
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
    
    func validateDuration(sourceURL: URL, max: Double) async throws {
        print("VALIDATING VIDEO...")
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
    
    func uploadVideo(
        sourceURL: URL,
        size: CGSize,
        storagePath: VideoUploadDestination,
        maxDuration: Double = 4
    ) async throws -> VideoData {
        print("UPLOADING VIDEO...")

        try await validateDuration(sourceURL: sourceURL, max: maxDuration)
        
        let compressedURL = try await exportCompressedVideo(
            from: sourceURL,
            progressRange: 0...0.2
        )
        
        let newSize = try await getVideoResolution(url: compressedURL.absoluteString)
        
        // Upload to storage takes the remaining 40% of upload progress
        let uploadResult = try await uploadToStorage(
            videoURL: compressedURL,
            storagePath: storagePath,
            progressRange: 0.2...1.0
        )
        
        return VideoData(
            videoUrl: uploadResult.downloadURL.absoluteString,
            storagePath: uploadResult.path,
            width: newSize.width,
            height: newSize.height
        )
    }
    
    private func exportCompressedVideo(
        from url: URL,
        progressRange: ClosedRange<Double>
    ) async throws -> URL {
        
        print("EXPORT COMPRESSION...")
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
    
    private func videoComposition720p(
        asset: AVAsset
    ) async throws -> AVVideoComposition {
        print("VIDEO COMPOSITION...")
        
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
    
    private func uploadToStorage(
        videoURL: URL,
        storagePath: VideoUploadDestination,
        progressRange: ClosedRange<Double>
    ) async throws -> (downloadURL: URL, path: String) {
        print("UPLOADING TO STORAGE...")
        
        return try await storageManager.uploadVideo(
            url: videoURL,
            storagePath: storagePath
        ) { progress in
            
            let weighted = self.lerp(progress, from: progressRange)
            self.onProgress?(weighted)
        }
    }
    
    private func lerp(
        _ value: Double,
        from range: ClosedRange<Double>
    ) -> Double {
        range.lowerBound + (range.upperBound - range.lowerBound) * value
    }
    
    private func even(_ value: CGFloat) -> CGFloat {
        floor(value / 2) * 2
    }
    
    private func getVideoResolution(url: String) async throws -> CGSize {
        let url = URL(string: url)
        let track = try await AVURLAsset(url: url!).loadTracks(withMediaType: AVMediaType.video).first
        let size = try await track!.load(.naturalSize).applying(track!.load(.preferredTransform))
        
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
}


