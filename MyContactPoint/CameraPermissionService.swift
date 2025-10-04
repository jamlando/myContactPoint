//
//  CameraPermissionService.swift
//  MyContactPoint
//
//  Created by Taylor Larson on 9/25/25.
//

import Foundation
import AVFoundation
import Photos
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@MainActor
class CameraPermissionService: ObservableObject {
    @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    @Published var microphonePermissionStatus: AVAuthorizationStatus = .notDetermined
    @Published var photoLibraryPermissionStatus: PHAuthorizationStatus = .notDetermined
    
    init() {
        checkPermissions()
    }
    
    // MARK: - Permission Checking
    
    func checkPermissions() {
        cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
        microphonePermissionStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        photoLibraryPermissionStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    // MARK: - Camera Permission
    
    func requestCameraPermission() async -> Bool {
        let status = await AVCaptureDevice.requestAccess(for: .video)
        await MainActor.run {
            cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
        }
        return status
    }
    
    // MARK: - Microphone Permission
    
    func requestMicrophonePermission() async -> Bool {
        let status = await AVCaptureDevice.requestAccess(for: .audio)
        await MainActor.run {
            microphonePermissionStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        }
        return status
    }
    
    // MARK: - Photo Library Permission
    
    func requestPhotoLibraryPermission() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        await MainActor.run {
            photoLibraryPermissionStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        }
        return status == .authorized || status == .limited
    }
    
    // MARK: - Combined Permission Requests
    
    func requestAllPermissions() async -> (camera: Bool, microphone: Bool, photoLibrary: Bool) {
        let camera = await requestCameraPermission()
        let microphone = await requestMicrophonePermission()
        let photoLibrary = await requestPhotoLibraryPermission()
        
        return (camera: camera, microphone: microphone, photoLibrary: photoLibrary)
    }
    
    // MARK: - Permission Status Helpers
    
    var hasCameraPermission: Bool {
        cameraPermissionStatus == .authorized
    }
    
    var hasMicrophonePermission: Bool {
        microphonePermissionStatus == .authorized
    }
    
    var hasPhotoLibraryPermission: Bool {
        photoLibraryPermissionStatus == .authorized || photoLibraryPermissionStatus == .limited
    }
    
    var hasAllRequiredPermissions: Bool {
        hasCameraPermission && hasMicrophonePermission && hasPhotoLibraryPermission
    }
    
    var canRecordVideo: Bool {
        hasCameraPermission && hasMicrophonePermission
    }
    
    // MARK: - Permission Status Messages
    
    func cameraPermissionMessage() -> String {
        switch cameraPermissionStatus {
        case .notDetermined:
            return "Camera permission is required to record your swing videos."
        case .denied, .restricted:
            return "Camera access is denied. Please enable it in Settings to record videos."
        case .authorized:
            return "Camera access granted."
        @unknown default:
            return "Unknown camera permission status."
        }
    }
    
    func microphonePermissionMessage() -> String {
        switch microphonePermissionStatus {
        case .notDetermined:
            return "Microphone permission is required to record audio with your videos."
        case .denied, .restricted:
            return "Microphone access is denied. Please enable it in Settings for better video quality."
        case .authorized:
            return "Microphone access granted."
        @unknown default:
            return "Unknown microphone permission status."
        }
    }
    
    func photoLibraryPermissionMessage() -> String {
        switch photoLibraryPermissionStatus {
        case .notDetermined:
            return "Photo library access is required to save your videos."
        case .denied, .restricted:
            return "Photo library access is denied. Please enable it in Settings to save videos."
        case .authorized, .limited:
            return "Photo library access granted."
        @unknown default:
            return "Unknown photo library permission status."
        }
    }
    
    // MARK: - Settings Navigation
    
    func openAppSettings() {
        #if canImport(UIKit)
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
        #else
        // On macOS, we can't open app settings programmatically
        print("Please open System Preferences > Security & Privacy > Privacy > Camera to enable camera access")
        #endif
    }
}

// MARK: - Permission Status Extensions

extension AVAuthorizationStatus {
    var displayName: String {
        switch self {
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorized:
            return "Authorized"
        @unknown default:
            return "Unknown"
        }
    }
}

extension PHAuthorizationStatus {
    var displayName: String {
        switch self {
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorized:
            return "Authorized"
        case .limited:
            return "Limited"
        @unknown default:
            return "Unknown"
        }
    }
}
