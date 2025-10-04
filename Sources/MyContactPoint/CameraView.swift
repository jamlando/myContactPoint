//
//  CameraView.swift
//  MyContactPoint
//
//  Created by Taylor Larson on 9/25/25.
//

import SwiftUI
import AVFoundation
import Photos

struct CameraView: View {
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var permissionService = CameraPermissionService()
    @State private var showingPermissionAlert = false
    @State private var showingSettingsAlert = false
    @State private var isRecording = false
    @State private var recordingDuration: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            // Camera Preview
            if permissionService.hasCameraPermission {
                CameraPreviewView(cameraManager: cameraManager)
                    .ignoresSafeArea()
            } else {
                // Permission Request View
                PermissionRequestView(permissionService: permissionService)
            }
            
            // Recording Controls Overlay
            VStack {
                Spacer()
                
                if permissionService.hasCameraPermission {
                    RecordingControlsView(
                        isRecording: $isRecording,
                        recordingDuration: $recordingDuration,
                        cameraManager: cameraManager,
                        permissionService: permissionService
                    )
                }
            }
        }
        .onAppear {
            checkPermissions()
        }
        .alert("Camera Permission Required", isPresented: $showingPermissionAlert) {
            Button("Request Permission") {
                Task {
                    await requestPermissions()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(permissionService.cameraPermissionMessage())
        }
        .alert("Settings Required", isPresented: $showingSettingsAlert) {
            Button("Open Settings") {
                permissionService.openAppSettings()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable camera access in Settings to record videos.")
        }
    }
    
    private func checkPermissions() {
        permissionService.checkPermissions()
        
        if !permissionService.hasCameraPermission {
            showingPermissionAlert = true
        }
    }
    
    private func requestPermissions() async {
        let permissions = await permissionService.requestAllPermissions()
        
        if !permissions.camera {
            showingSettingsAlert = true
        }
    }
}

// MARK: - Camera Preview View

struct CameraPreviewView: UIViewRepresentable {
    let cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black
        
        let previewLayer = cameraManager.previewLayer
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = cameraManager.previewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}

// MARK: - Permission Request View

struct PermissionRequestView: View {
    @ObservedObject var permissionService: CameraPermissionService
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Camera Access Required")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("My Contact Point needs camera access to record your baseball swing for biomechanical analysis.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button("Enable Camera Access") {
                Task {
                    await permissionService.requestCameraPermission()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            if permissionService.cameraPermissionStatus == .denied {
                Button("Open Settings") {
                    permissionService.openAppSettings()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .padding()
    }
}

// MARK: - Recording Controls View

struct RecordingControlsView: View {
    @Binding var isRecording: Bool
    @Binding var recordingDuration: TimeInterval
    let cameraManager: CameraManager
    @ObservedObject var permissionService: CameraPermissionService
    
    var body: some View {
        VStack(spacing: 20) {
            // Recording Duration Display
            if isRecording {
                HStack {
                    Circle()
                        .fill(.red)
                        .frame(width: 12, height: 12)
                        .opacity(0.8)
                    
                    Text(formatDuration(recordingDuration))
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.black.opacity(0.6))
                .cornerRadius(20)
            }
            
            // Recording Button
            Button(action: toggleRecording) {
                ZStack {
                    Circle()
                        .fill(isRecording ? .red : .white)
                        .frame(width: 80, height: 80)
                    
                    if isRecording {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white)
                            .frame(width: 30, height: 30)
                    } else {
                        Circle()
                            .stroke(.black, lineWidth: 4)
                            .frame(width: 60, height: 60)
                    }
                }
            }
            .disabled(!permissionService.canRecordVideo)
            .scaleEffect(isRecording ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isRecording)
            
            // Instructions
            Text(isRecording ? "Tap to stop recording" : "Tap to start recording")
                .font(.caption)
                .foregroundColor(.white)
                .shadow(radius: 2)
        }
        .padding(.bottom, 50)
    }
    
    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        guard permissionService.canRecordVideo else { return }
        
        cameraManager.startRecording()
        isRecording = true
        
        // Start timer for recording duration
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            recordingDuration += 0.1
        }
    }
    
    private func stopRecording() {
        cameraManager.stopRecording()
        isRecording = false
        
        // Stop timer
        timer?.invalidate()
        timer = nil
        recordingDuration = 0
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        let milliseconds = Int((duration.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%d", minutes, seconds, milliseconds)
    }
}

// MARK: - Camera Manager

class CameraManager: NSObject, ObservableObject {
    private let captureSession = AVCaptureSession()
    private var videoOutput = AVCaptureMovieFileOutput()
    private var audioInput: AVCaptureDeviceInput?
    private var videoInput: AVCaptureDeviceInput?
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        return layer
    }
    
    override init() {
        super.init()
        setupCamera()
    }
    
    private func setupCamera() {
        captureSession.beginConfiguration()
        
        // Configure session preset
        if captureSession.canSetSessionPreset(.high) {
            captureSession.sessionPreset = .high
        }
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoInput) else {
            return
        }
        
        captureSession.addInput(videoInput)
        self.videoInput = videoInput
        
        // Add audio input
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
              captureSession.canAddInput(audioInput) else {
            return
        }
        
        captureSession.addInput(audioInput)
        self.audioInput = audioInput
        
        // Add video output
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        captureSession.commitConfiguration()
        
        // Start session on background queue
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    func startRecording() {
        guard !videoOutput.isRecording else { return }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "swing_video_\(Date().timeIntervalSince1970).mov"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        videoOutput.startRecording(to: fileURL, recordingDelegate: self)
    }
    
    func stopRecording() {
        guard videoOutput.isRecording else { return }
        videoOutput.stopRecording()
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Recording error: \(error.localizedDescription)")
            return
        }
        
        // Save to photo library
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
        }) { success, error in
            if let error = error {
                print("Error saving to photo library: \(error.localizedDescription)")
            } else if success {
                print("Video saved to photo library successfully")
            }
        }
    }
}

#Preview {
    CameraView()
}
