//
//  VideoLibraryView.swift
//  MyContactPoint
//
//  Created by Taylor Larson on 9/25/25.
//

import SwiftUI
import AVFoundation
#if canImport(UIKit)
import UIKit
#endif

struct VideoLibraryView: View {
    @StateObject private var uploadService = VideoUploadService()
    @EnvironmentObject var authService: AuthService
    @State private var videos: [SwingVideo] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedVideo: SwingVideo?
    @State private var showingVideoDetail = false
    @State private var showingDeleteAlert = false
    @State private var videoToDelete: SwingVideo?
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading videos...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if videos.isEmpty {
                    EmptyStateView()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(videos) { video in
                                VideoThumbnailView(
                                    video: video,
                                    onTap: {
                                        selectedVideo = video
                                        showingVideoDetail = true
                                    },
                                    onDelete: {
                                        videoToDelete = video
                                        showingDeleteAlert = true
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Videos")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        loadVideos()
                    }
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button("Refresh") {
                        loadVideos()
                    }
                }
                #endif
            }
            .onAppear {
                loadVideos()
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete Video"),
                    message: Text("Are you sure you want to delete this video? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let video = videoToDelete {
                            deleteVideo(video)
                        }
                    },
                    secondaryButton: .cancel(Text("Cancel")) {
                        videoToDelete = nil
                    }
                )
            }
            .alert(isPresented: .constant(errorMessage != nil)) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage ?? ""),
                    dismissButton: .default(Text("OK")) {
                        errorMessage = nil
                    }
                )
            }
            .sheet(isPresented: $showingVideoDetail) {
                if let video = selectedVideo {
                    VideoDetailView(video: video)
                }
            }
        }
    }
    
    private func loadVideos() {
        guard let userId = authService.currentUser?.id else {
            errorMessage = "Please sign in to view your videos"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let userVideos = try await uploadService.getUserVideos(userId: userId)
                await MainActor.run {
                    self.videos = userVideos
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load videos: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    private func deleteVideo(_ video: SwingVideo) {
        guard let userId = authService.currentUser?.id else { return }
        
        Task {
            do {
                try await uploadService.deleteVideo(videoId: video.id, userId: userId)
                await MainActor.run {
                    videos.removeAll { $0.id == video.id }
                    videoToDelete = nil
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to delete video: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Video Thumbnail View

struct VideoThumbnailView: View {
    let video: SwingVideo
    let onTap: () -> Void
    let onDelete: () -> Void
    #if canImport(UIKit)
    @State private var thumbnailImage: UIImage?
    #else
    @State private var thumbnailImage: NSImage?
    #endif
    @State private var isLoadingThumbnail = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                // Thumbnail placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(16/9, contentMode: .fit)
                
                if isLoadingThumbnail {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if let thumbnailImage = thumbnailImage {
                    #if canImport(UIKit)
                    Image(uiImage: thumbnailImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                        .cornerRadius(12)
                    #else
                    Image(nsImage: thumbnailImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                        .cornerRadius(12)
                    #endif
                } else {
                    Image(systemName: "video.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                }
                
                // Duration overlay
                if let duration = video.durationSeconds {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text(formatDuration(duration))
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(4)
                                .padding(8)
                        }
                    }
                }
                
                // Play button overlay
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                            .padding(8)
                    }
                }
            }
            
            // Video metadata
            VStack(alignment: .leading, spacing: 4) {
                Text(formatDate(video.createdAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let resolution = video.resolution {
                    Text(resolution)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                if let fileSize = video.fileSize {
                    Text(formatFileSize(fileSize))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onTapGesture {
            onTap()
        }
        .contextMenu {
            Button("Play Video", action: onTap)
            Button("Delete", action: onDelete)
        }
        .onAppear {
            generateThumbnail()
        }
    }
    
    private func generateThumbnail() {
        // For now, we'll use a placeholder thumbnail
        // In a real implementation, you would generate thumbnails from the video
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoadingThumbnail = false
        }
    }
    
    private func formatDuration(_ duration: Double) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "video.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Videos Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Record your first swing to see it here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Record My Swing") {
                // This will be handled by the parent view
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Video Detail View

struct VideoDetailView: View {
    let video: SwingVideo
    @Environment(\.presentationMode) var presentationMode
    @State private var downloadURL: URL?
    @State private var isLoadingURL = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Video placeholder (would show actual video player in real implementation)
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(16/9, contentMode: .fit)
                        .overlay(
                            VStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                                Text("Video Player")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        )
                    
                    // Video information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Video Details")
                            .font(.headline)
                        
                        DetailRow(label: "Filename", value: video.filename)
                        DetailRow(label: "Created", value: formatDate(video.createdAt))
                        
                        if let duration = video.durationSeconds {
                            DetailRow(label: "Duration", value: formatDuration(duration))
                        }
                        
                        if let resolution = video.resolution {
                            DetailRow(label: "Resolution", value: resolution)
                        }
                        
                        if let fps = video.fps {
                            DetailRow(label: "Frame Rate", value: "\(fps) fps")
                        }
                        
                        if let fileSize = video.fileSize {
                            DetailRow(label: "File Size", value: formatFileSize(fileSize))
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button("Download Video") {
                            downloadVideo()
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                        
                        Button("Analyze Swing") {
                            // TODO: Navigate to analysis view
                        }
                        #if os(iOS)
                        .buttonStyle(.borderedProminent)
                        #else
                        .buttonStyle(.bordered)
                        #endif
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding()
            }
            .navigationTitle("Video Details")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                #endif
            }
            .alert(isPresented: .constant(errorMessage != nil)) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage ?? ""),
                    dismissButton: .default(Text("OK")) {
                        errorMessage = nil
                    }
                )
            }
        }
    }
    
    private func downloadVideo() {
        isLoadingURL = true
        
        Task {
            do {
                let url = try await VideoUploadService().getVideoDownloadURL(
                    videoId: video.id,
                    userId: video.userId
                )
                await MainActor.run {
                    downloadURL = url
                    isLoadingURL = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to get download URL: \(error.localizedDescription)"
                    isLoadingURL = false
                }
            }
        }
    }
    
    private func formatDuration(_ duration: Double) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - Detail Row Helper

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    VideoLibraryView()
        .environmentObject(AuthService())
}
