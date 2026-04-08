//
//  DuelPlayerSyncing.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 3/26/26.
//

import Foundation
import AVKit

final class VideoSyncService {
    static let shared = VideoSyncService()
    private init() { }

    // MARK: - Extract audio samples
    func extractAudioSamples(url: URL) async throws -> [Float] {
        let asset = AVURLAsset(url: url)
        try await asset.load(.tracks)

        guard let track = try await asset.loadTracks(withMediaType: .audio).first else {
            return []
        }

        let reader = try AVAssetReader(asset: asset)

        let output = AVAssetReaderTrackOutput(
            track: track,
            outputSettings: [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVLinearPCMIsFloatKey: true,
                AVLinearPCMBitDepthKey: 32
            ]
        )

        reader.add(output)
        reader.startReading()

        var samples: [Float] = []

        while
            let buffer = output.copyNextSampleBuffer(),
            let blockBuffer = CMSampleBufferGetDataBuffer(buffer)
        {
            let length = CMBlockBufferGetDataLength(blockBuffer)
            var data = [Float](repeating: 0, count: length / 4)

            CMBlockBufferCopyDataBytes(
                blockBuffer,
                atOffset: 0,
                dataLength: length,
                destination: &data
            )

            samples.append(contentsOf: data)
        }

        return samples
    }

    // MARK: - Find first major spike (board pop)
    func findFirstMajorSpike(samples: [Float]) -> Int? {
        guard samples.count > 100 else { return nil }

        let windowSize = 1024
        var energy: [Float] = []

        for i in stride(from: 0, to: samples.count - windowSize, by: windowSize) {
            let window = samples[i..<i + windowSize]
            let avg = window.map { abs($0) }.reduce(0, +) / Float(windowSize)
            energy.append(avg)
        }

        let maxEnergy = energy.max() ?? 1
        let normalized = energy.map { $0 / maxEnergy }

        for i in 5..<normalized.count {
            let isQuietBefore = normalized[(i - 5)..<i].allSatisfy { $0 < 0.2 }
            let isSpike = normalized[i] > 0.6

            if isQuietBefore && isSpike {
                // Return sample index relative to start of audio
                return i * windowSize
            }
        }

        return nil
    }

    // MARK: - Find spike time in seconds
    func findSyncTime(for url: URL) async throws -> Double? {
        let asset = AVURLAsset(url: url)
        try await asset.load(.tracks)
        let duration = try await asset.load(.duration).seconds

        guard let track = try await asset.loadTracks(withMediaType: .audio).first else {
            return nil
        }

        // Load format descriptions asynchronously
        let formatDescsAny = try await track.load(.formatDescriptions)
        guard let formatDesc = formatDescsAny.first,
              let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(formatDesc)?.pointee else {
            return nil
        }

        let sampleRate = Float(asbd.mSampleRate)
        let samples = try await extractAudioSamples(url: url)

        guard let spikeIndex = findFirstMajorSpike(samples: samples) else {
            return nil
        }

        // Convert spike index to seconds, clamp safely to duration
        let spikeTimeRaw = Double(spikeIndex) / Double(sampleRate)
        let spikeTime = min(spikeTimeRaw, max(duration - 0.05, 0)) // avoid exact end

        return spikeTime
    }

    // MARK: - Sync two players
    func syncPlayers(player1: AVPlayer, player2: AVPlayer, t1: Double, t2: Double) {
        let offset = t1 - t2

        if offset > 0 {
            // Player 1 is ahead
            player1.seek(to: CMTime(seconds: t1, preferredTimescale: 600))
            player2.seek(to: CMTime(seconds: t2, preferredTimescale: 600))
        } else {
            // Player 2 is ahead
            player2.seek(to: CMTime(seconds: t2, preferredTimescale: 600))
            player1.seek(to: CMTime(seconds: t1, preferredTimescale: 600))
        }
    }
}

//final class VideoSyncService {
//    static let shared = VideoSyncService()
//    private init() { }
//    
//    func extractAudioSamples(url: URL) async throws -> [Float] {
//        let asset = AVURLAsset(url: url)
//        
//        let reader = try AVAssetReader(asset: asset)
//        
//        guard let track = try await asset.loadTracks(withMediaType: .audio).first else {
//            return []
//        }
//        
//        let output = AVAssetReaderTrackOutput(
//            track: track,
//            outputSettings: [
//                AVFormatIDKey: kAudioFormatLinearPCM,
//                AVLinearPCMIsFloatKey: true,
//                AVLinearPCMBitDepthKey: 32
//            ]
//        )
//        
//        reader.add(output)
//        reader.startReading()
//        
//        var samples: [Float] = []
//        
//        while
//            let buffer = output.copyNextSampleBuffer(),
//            let blockBuffer = CMSampleBufferGetDataBuffer(buffer)
//        {
//            let length = CMBlockBufferGetDataLength(blockBuffer)
//            var data = [Float](repeating: 0, count: length / 4)
//            
//            CMBlockBufferCopyDataBytes(
//                blockBuffer,
//                atOffset: 0,
//                dataLength: length,
//                destination: &data
//            )
//            
//            samples.append(contentsOf: data)
//        }
//        
//        return samples
//    }
//    
//    func findFirstMajorSpike(samples: [Float]) -> Int? {
//        guard samples.count > 100 else { return nil }
//        
//        let windowSize = 1024
//        var energy: [Float] = []
//        
//        for i in stride(from: 0, to: samples.count - windowSize, by: windowSize) {
//            
//            let window = samples[i..<i+windowSize]
//            let avg = window.map { abs($0) }.reduce(0, +) / Float(windowSize)
//            energy.append(avg)
//        }
//        
//        let maxEnergy = energy.max() ?? 1
//        let normalized = energy.map { $0 / maxEnergy }
//        
//        for i in 5..<normalized.count {
//            let isQuietBefore = normalized[(i-5)..<i].allSatisfy { $0 < 0.2 }
//            let isSpike = normalized[i] > 0.6
//            
//            if isQuietBefore && isSpike {
//                return i * windowSize
//            }
//        }
//        
//        return nil
//    }
//    
//    func sampleIndexToTime(index: Int, sampleRate: Float) -> Double {
//        return Double(index) / Double(sampleRate)
//    }
//        
//    func findSyncTime(for url: URL) async throws -> Double? {
//        let asset = AVURLAsset(url: url)
//        
//        guard let track = try await asset.loadTracks(withMediaType: .audio).first,
//              let formatDesc = try await track.load(.formatDescriptions).first,
//              let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(formatDesc)?.pointee else {
//            return nil
//        }
//        
//        let sampleRate = Float(asbd.mSampleRate)
//        let samples = try await extractAudioSamples(url: url)
//        
//        guard let spikeIndex = findFirstMajorSpike(samples: samples) else { return nil }
//        
//        // Clamp to duration
//        let spikeTime = min(Double(spikeIndex) / Double(sampleRate), asset.duration.seconds)
//        
//        return spikeTime
//    }
//    
//    func syncPlayers(
//        player1: AVPlayer,
//        player2: AVPlayer,
//        t1: Double,
//        t2: Double
//    ) {
//        let offset = t1 - t2
//        
//        if offset > 0 {
//            // Player 1 is ahead
//            let time = CMTime(seconds: t1, preferredTimescale: 600)
//            player1.seek(to: time)
//            player2.seek(to: CMTime(seconds: t2, preferredTimescale: 600))
//        } else {
//            let time = CMTime(seconds: t2, preferredTimescale: 600)
//            player2.seek(to: time)
//            player1.seek(to: CMTime(seconds: t1, preferredTimescale: 600))
//        }
//    }
//}
