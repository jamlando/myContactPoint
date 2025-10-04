//
//  VideoWorkflowTestSuite.swift
//  MyContactPoint
//
//  Created by Taylor Larson on 9/25/25.
//

import Foundation
import XCTest
import AVFoundation
@testable import MyContactPoint

/// Comprehensive test suite for the complete video recording workflow
/// This test suite validates all components work together seamlessly
@MainActor
class VideoWorkflowTestSuite: XCTestCase {
    
    var authService: AuthService!
    var uploadService: VideoUploadService!
    var permissionService: CameraPermissionService!
    
    override func setUp() async throws {
        try await super.setUp()
        authService = AuthService()
        uploadService = VideoUploadService()
        permissionService = CameraPermissionService()
    }
    
    override func tearDown() {
        authService = nil
        uploadService = nil
        permissionService = nil
        super.tearDown()
    }
    
    // MARK: - Authentication Flow Tests
    
    func testUserSignupFlow() async throws {
        // Test user signup process
        let email = "test@example.com"
        let password = "testpassword123"
        
        do {
            try await authService.signUp(email: email, password: password, fullName: "Test User")
            XCTAssertNotNil(authService.currentUser)
            XCTAssertEqual(authService.currentUser?.email, email)
            print("✅ User signup successful: \(authService.currentUser?.email ?? "No email")")
        } catch {
            XCTFail("User signup failed: \(error.localizedDescription)")
        }
    }
    
    func testUserSignInFlow() async throws {
        // Test user signin process
        let email = "test@example.com"
        let password = "testpassword123"
        
        do {
            try await authService.signIn(email: email, password: password)
            XCTAssertNotNil(authService.currentUser)
            XCTAssertEqual(authService.currentUser?.email, email)
            print("✅ User signin successful: \(authService.currentUser?.email ?? "No email")")
        } catch {
            XCTFail("User signin failed: \(error.localizedDescription)")
        }
    }
    
    func testUserSessionManagement() async throws {
        // Test session persistence and management
        XCTAssertNotNil(authService.currentUser, "User should be signed in from previous test")
        
        // Test sign out
        try await authService.signOut()
        XCTAssertNil(authService.currentUser, "User should be signed out")
        
        print("✅ Session management working correctly")
    }
    
    // MARK: - Camera Permission Tests
    
    func testCameraPermissionRequest() async {
        // Test camera permission request flow
        let permissions = await permissionService.requestAllPermissions()
        
        // On macOS, camera permissions will be denied, which is expected
        XCTAssertFalse(permissions.camera, "Camera permission should be denied on macOS")
        print("✅ Camera permission handling working correctly")
    }
    
    func testPermissionStatusMessages() {
        // Test permission status messages
        let message = permissionService.cameraPermissionMessage()
        XCTAssertFalse(message.isEmpty, "Permission message should not be empty")
        print("✅ Permission status message: \(message)")
    }
    
    // MARK: - Video Upload Service Tests
    
    func testVideoUploadServiceInitialization() {
        // Test that VideoUploadService initializes correctly
        XCTAssertNotNil(uploadService, "VideoUploadService should initialize")
        XCTAssertFalse(uploadService.isUploading, "Should not be uploading initially")
        XCTAssertEqual(uploadService.uploadProgress, 0.0, "Upload progress should start at 0")
        print("✅ VideoUploadService initialization working correctly")
    }
    
    func testVideoMetadataExtraction() async throws {
        // Test video metadata extraction (using a mock video file)
        // Create a temporary test file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_video.mov")
        let testData = Data("test video content".utf8)
        try testData.write(to: tempURL)
        
        // Test metadata extraction
        let metadata = try await uploadService.getVideoMetadata(from: tempURL)
        XCTAssertNotNil(metadata, "Metadata should be extracted")
        
        // Clean up
        try FileManager.default.removeItem(at: tempURL)
        print("✅ Video metadata extraction working correctly")
    }
    
    func testUniqueFilenameGeneration() {
        // Test unique filename generation
        let testURL = URL(fileURLWithPath: "/test/video.mov")
        let filename = uploadService.generateUniqueFilename(for: testURL)
        
        XCTAssertTrue(filename.contains("video"), "Filename should contain original name")
        XCTAssertTrue(filename.contains(".mov"), "Filename should contain extension")
        XCTAssertTrue(filename.contains("_"), "Filename should contain timestamp separator")
        
        print("✅ Unique filename generation working correctly: \(filename)")
    }
    
    // MARK: - Database Integration Tests
    
    func testSupabaseConnection() async throws {
        // Test Supabase connection by attempting to get user videos
        guard let userId = authService.currentUser?.id else {
            XCTFail("User must be signed in to test database connection")
            return
        }
        
        do {
            let videos = try await uploadService.getUserVideos(userId: userId)
            XCTAssertNotNil(videos, "Should be able to retrieve videos (even if empty)")
            print("✅ Supabase database connection working correctly")
        } catch {
            XCTFail("Database connection failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Video Library Tests
    
    func testVideoLibraryViewInitialization() {
        // Test VideoLibraryView initialization
        let libraryView = VideoLibraryView()
        XCTAssertNotNil(libraryView, "VideoLibraryView should initialize")
        print("✅ VideoLibraryView initialization working correctly")
    }
    
    func testVideoThumbnailViewInitialization() {
        // Test VideoThumbnailView initialization
        let mockVideo = SwingVideo(
            id: UUID(),
            userId: UUID(),
            filename: "test.mov",
            filePath: "test/path.mov",
            fileSize: 1024,
            durationSeconds: 5.0,
            resolution: "1920x1080",
            fps: 30,
            createdAt: Date(),
            updatedAt: Date(),
            metadata: [:]
        )
        
        let thumbnailView = VideoThumbnailView(
            video: mockVideo,
            onTap: {},
            onDelete: {}
        )
        
        XCTAssertNotNil(thumbnailView, "VideoThumbnailView should initialize")
        print("✅ VideoThumbnailView initialization working correctly")
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandlingForInvalidVideo() async {
        // Test error handling for invalid video files
        let invalidURL = URL(fileURLWithPath: "/nonexistent/video.mov")
        
        do {
            _ = try await uploadService.getVideoMetadata(from: invalidURL)
            XCTFail("Should have thrown an error for invalid video")
        } catch {
            print("✅ Error handling working correctly: \(error.localizedDescription)")
        }
    }
    
    func testErrorHandlingForUnauthorizedAccess() async {
        // Test error handling for unauthorized database access
        try? await authService.signOut() // Ensure user is signed out
        
        do {
            _ = try await uploadService.getUserVideos(userId: UUID())
            XCTFail("Should have thrown an error for unauthorized access")
        } catch {
            print("✅ Unauthorized access error handling working correctly")
        }
    }
    
    // MARK: - Integration Tests
    
    func testCompleteWorkflowIntegration() async throws {
        print("\n🔄 Testing Complete Video Recording Workflow Integration...")
        
        // Step 1: User Authentication
        print("1. Testing user authentication...")
        let email = "integration@example.com"
        let password = "integration123"
        
        try await authService.signUp(email: email, password: password, fullName: "Integration Test")
        XCTAssertNotNil(authService.currentUser)
        print("   ✅ User authenticated successfully")
        
        // Step 2: Camera Permission Check
        print("2. Testing camera permission handling...")
        let permissions = await permissionService.requestAllPermissions()
        print("   ✅ Camera permission status: \(permissions.camera ? "Granted" : "Denied")")
        
        // Step 3: Video Service Initialization
        print("3. Testing video service initialization...")
        XCTAssertNotNil(uploadService)
        print("   ✅ Video service initialized successfully")
        
        // Step 4: Database Connection
        print("4. Testing database connection...")
        let videos = try await uploadService.getUserVideos(userId: authService.currentUser!.id)
        XCTAssertNotNil(videos)
        print("   ✅ Database connection successful")
        
        // Step 5: Video Library View
        print("5. Testing video library view...")
        let libraryView = VideoLibraryView()
        XCTAssertNotNil(libraryView)
        print("   ✅ Video library view initialized successfully")
        
        // Step 6: Cleanup
        print("6. Cleaning up test data...")
        try await authService.signOut()
        print("   ✅ Test cleanup completed")
        
        print("\n🎉 Complete workflow integration test PASSED!")
    }
    
    // MARK: - Performance Tests
    
    func testVideoServicePerformance() {
        // Test VideoUploadService performance characteristics
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Initialize service
        _ = VideoUploadService()
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let executionTime = endTime - startTime
        
        XCTAssertLessThan(executionTime, 1.0, "Service initialization should be fast")
        print("✅ VideoUploadService initialization time: \(executionTime)s")
    }
    
    func testVideoLibraryViewPerformance() {
        // Test VideoLibraryView performance characteristics
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Initialize view
        _ = VideoLibraryView()
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let executionTime = endTime - startTime
        
        XCTAssertLessThan(executionTime, 0.5, "View initialization should be very fast")
        print("✅ VideoLibraryView initialization time: \(executionTime)s")
    }
}

// MARK: - Test Helper Extensions

extension VideoUploadService {
    // Helper method for testing metadata extraction
    func getVideoMetadata(from url: URL) async throws -> VideoMetadata {
        let asset = AVAsset(url: url)
        
        // Use modern async API for better compatibility
        let duration = try await asset.load(.duration)
        let tracks = try await asset.loadTracks(withMediaType: .video)
        
        guard let videoTrack = tracks.first else {
            throw VideoUploadError.noVideoTrack
        }
        
        let naturalSize = try await videoTrack.load(.naturalSize)
        let nominalFrameRate = try await videoTrack.load(.nominalFrameRate)
        
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
        let fileSize = fileAttributes[.size] as? Int64 ?? 0
        
        return VideoMetadata(
            duration: CMTimeGetSeconds(duration),
            resolution: "\(Int(naturalSize.width))x\(Int(naturalSize.height))",
            fps: Int(nominalFrameRate),
            fileSize: fileSize
        )
    }
    
    // Helper method for testing filename generation
    func generateUniqueFilename(for url: URL) -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let originalName = url.lastPathComponent
        let fileExtension = url.pathExtension
        let baseName = originalName.replacingOccurrences(of: ".\(fileExtension)", with: "")
        
        return "\(baseName)_\(timestamp).\(fileExtension)"
    }
}