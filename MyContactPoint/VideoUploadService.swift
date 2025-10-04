//
//  VideoUploadService.swift
//  MyContactPoint
//
//  Created by Taylor Larson on 9/25/25.
//

import Foundation
import Supabase
import SwiftUI
import AVFoundation
import Photos

@MainActor
class VideoUploadService: ObservableObject {
    @Published var uploadProgress: Double = 0.0
    @Published var isUploading = false
    @Published var uploadError: String?
    @Published var uploadedVideo: SwingVideo?
    
    private let supabase: SupabaseClient
    
    init() {
        // Initialize Supabase client with environment configuration
        // For production builds, use production Supabase URLs
        let supabaseURL = URL(string: ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "https://your-project-ref.supabase.co")!
        let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? "your-production-anon-key"
        
        self.supabase = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }
    
    // MARK: - Video Upload Methods
    
    func uploadVideo(from url: URL, userId: UUID) async throws -> SwingVideo {
        isUploading = true
        uploadError = nil
        uploadProgress = 0.0
        
        do {
            // Get video metadata
            let metadata = try await getVideoMetadata(from: url)
            
            // Generate unique filename
            let filename = generateUniqueFilename(for: url)
            let storagePath = "\(userId)/\(filename)"
            
            // Upload to Supabase Storage
            _ = try await uploadToStorage(
                fileURL: url,
                path: storagePath,
                bucket: "swing-videos"
            )
            
            // Create database record
            let swingVideo = try await createVideoRecord(
                userId: userId,
                filename: filename,
                filePath: storagePath,
                metadata: metadata
            )
            
            uploadProgress = 1.0
            uploadedVideo = swingVideo
            isUploading = false
            
            return swingVideo
            
        } catch {
            uploadError = error.localizedDescription
            isUploading = false
            throw error
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func getVideoMetadata(from url: URL) async throws -> VideoMetadata {
        let asset = AVAsset(url: url)
        
        // Use synchronous APIs for better compatibility
        let duration = asset.duration
        let tracks = asset.tracks(withMediaType: .video)
        
        guard let videoTrack = tracks.first else {
            throw VideoUploadError.noVideoTrack
        }
        
        let naturalSize = videoTrack.naturalSize
        let nominalFrameRate = videoTrack.nominalFrameRate
        
        // Get file size
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
        let fileSize = fileAttributes[.size] as? Int64 ?? 0
        
        return VideoMetadata(
            duration: CMTimeGetSeconds(duration),
            resolution: "\(Int(naturalSize.width))x\(Int(naturalSize.height))",
            fps: Int(nominalFrameRate),
            fileSize: fileSize
        )
    }
    
    private func generateUniqueFilename(for url: URL) -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let originalName = url.lastPathComponent
        let fileExtension = url.pathExtension
        let baseName = originalName.replacingOccurrences(of: ".\(fileExtension)", with: "")
        
        return "\(baseName)_\(timestamp).\(fileExtension)"
    }
    
    private func uploadToStorage(fileURL: URL, path: String, bucket: String) async throws -> FileUploadResponse {
        let fileData = try Data(contentsOf: fileURL)
        
        return try await supabase.storage
            .from(bucket)
            .upload(
                path,
                data: fileData,
                options: FileOptions(
                    contentType: "video/mp4",
                    upsert: false
                )
            )
    }
    
    private func createVideoRecord(
        userId: UUID,
        filename: String,
        filePath: String,
        metadata: VideoMetadata
    ) async throws -> SwingVideo {
        let swingVideo = SwingVideo(
            id: UUID(),
            userId: userId,
            filename: filename,
            filePath: filePath,
            fileSize: metadata.fileSize,
            durationSeconds: metadata.duration,
            resolution: metadata.resolution,
            fps: metadata.fps,
            createdAt: Date(),
            updatedAt: Date(),
            metadata: [:]
        )
        
        let response: SwingVideo = try await supabase
            .from("swing_videos")
            .insert(swingVideo)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    // MARK: - Video Management Methods
    
    func getUserVideos(userId: UUID) async throws -> [SwingVideo] {
        let response: [SwingVideo] = try await supabase
            .from("swing_videos")
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response
    }
    
    func deleteVideo(videoId: UUID, userId: UUID) async throws {
        // First get the video record to get the file path
        let video: SwingVideo = try await supabase
            .from("swing_videos")
            .select()
            .eq("id", value: videoId)
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value
        
        // Delete from storage
        try await supabase.storage
            .from("swing-videos")
            .remove(paths: [video.filePath])
        
        // Delete from database
        try await supabase
            .from("swing_videos")
            .delete()
            .eq("id", value: videoId)
            .execute()
    }
    
    func getVideoDownloadURL(videoId: UUID, userId: UUID) async throws -> URL {
        // Get the video record
        let video: SwingVideo = try await supabase
            .from("swing_videos")
            .select()
            .eq("id", value: videoId)
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value
        
        // Generate signed URL for download
        let signedURL = try await supabase.storage
            .from("swing-videos")
            .createSignedURL(
                path: video.filePath,
                expiresIn: 3600 // 1 hour
            )
        
        return signedURL
    }
}

// MARK: - Data Models

struct SwingVideo: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let filename: String
    let filePath: String
    let fileSize: Int64?
    let durationSeconds: Double?
    let resolution: String?
    let fps: Int?
    let createdAt: Date
    let updatedAt: Date
    let metadata: [String: AnyCodable]
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case filename
        case filePath = "file_path"
        case fileSize = "file_size"
        case durationSeconds = "duration_seconds"
        case resolution
        case fps
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case metadata
    }
}

struct VideoMetadata {
    let duration: Double
    let resolution: String
    let fps: Int
    let fileSize: Int64
}

// MARK: - Error Types

enum VideoUploadError: LocalizedError {
    case noVideoTrack
    case invalidFileFormat
    case uploadFailed
    case databaseError
    
    var errorDescription: String? {
        switch self {
        case .noVideoTrack:
            return "No video track found in the file"
        case .invalidFileFormat:
            return "Invalid video file format"
        case .uploadFailed:
            return "Failed to upload video to storage"
        case .databaseError:
            return "Failed to save video record to database"
        }
    }
}

// MARK: - AnyCodable Helper

struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.typeMismatch(AnyCodable.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let string = value as? String {
            try container.encode(string)
        } else if let int = value as? Int {
            try container.encode(int)
        } else if let double = value as? Double {
            try container.encode(double)
        } else if let bool = value as? Bool {
            try container.encode(bool)
        } else if let array = value as? [Any] {
            try container.encode(array.map { AnyCodable($0) })
        } else if let dictionary = value as? [String: Any] {
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
}
