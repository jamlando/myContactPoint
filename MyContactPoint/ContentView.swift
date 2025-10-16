//
//  ContentView.swift
//  MyContactPoint
//
//  Created by Taylor Larson on 10/3/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthService()
    @State private var showSplash = true
    @State private var showTutorial = false
    @State private var showAuthentication = false
    @State private var isSignUpMode = false
    
    var body: some View {
        Group {
            if showSplash {
                SplashScreenView(showSplash: $showSplash, showTutorial: $showTutorial)
            } else if showTutorial {
                OnboardingTutorialView(
                    showTutorial: $showTutorial,
                    onSignInTapped: {
                        showTutorial = false
                        isSignUpMode = false
                        showAuthentication = true
                    },
                    onSignUpTapped: {
                        showTutorial = false
                        isSignUpMode = true
                        showAuthentication = true
                    }
                )
            } else if showAuthentication || (!authService.isAuthenticated && !showTutorial) {
                AuthenticationView(isSignUpMode: $isSignUpMode, showAuthentication: $showAuthentication)
            } else if authService.isAuthenticated {
                MainAppView()
            }
        }
        .environmentObject(authService)
        .onAppear {
            // Check if user is already authenticated
            Task {
                await authService.checkCurrentSession()
            }
        }
        .onChange(of: authService.isAuthenticated) { isAuthenticated in
            // Reset authentication view when user becomes authenticated
            if isAuthenticated {
                showAuthentication = false
            }
        }
    }
}

struct MainAppView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var permissionService = CameraPermissionService()
    @State private var showingCameraView = false
    @State private var showingLibraryView = false
    @State private var showingPermissionAlert = false
    @State private var permissionType: PermissionType = .camera
    
    enum PermissionType {
        case camera
        case photoLibrary
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Spacer()
                
                // App Logo and Name at Top Center
                VStack(spacing: 16) {
                    LogoView(size: .extraLarge)
                    
                    Text("My Contact Point")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if let user = authService.currentUser {
                        Text("Welcome back, \(user.userMetadata["full_name"]?.stringValue ?? "Player")!")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Main Action Buttons
                VStack(spacing: 20) {
                    // Record Swing Button
                    Button(action: {
                        requestCameraPermission()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                            Text("Record Swing")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(permissionService.cameraPermissionStatus == .denied)
                    
                    // View Library Button
                    Button(action: {
                        requestPhotoLibraryPermission()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "video.fill")
                                .font(.title2)
                            Text("View Library")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(permissionService.photoLibraryPermissionStatus == .denied)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Permission Status Indicators
                VStack(spacing: 8) {
                    if permissionService.cameraPermissionStatus == .denied {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Camera access denied - enable in Settings")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if permissionService.photoLibraryPermissionStatus == .denied {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Photo library access denied - enable in Settings")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
            .onAppear {
                permissionService.checkPermissions()
            }
            .alert(isPresented: $showingPermissionAlert) {
                switch permissionType {
                case .camera:
                    return Alert(
                        title: Text("Camera Permission Required"),
                        message: Text("My Contact Point needs camera access to record your baseball swing for biomechanical analysis."),
                        primaryButton: .default(Text("Allow Camera Access")) {
                            Task {
                                await permissionService.requestCameraPermission()
                                if permissionService.hasCameraPermission {
                                    showingCameraView = true
                                }
                            }
                        },
                        secondaryButton: .cancel()
                    )
                case .photoLibrary:
                    return Alert(
                        title: Text("Photo Library Permission Required"),
                        message: Text("My Contact Point needs photo library access to view and manage your recorded swing videos."),
                        primaryButton: .default(Text("Allow Library Access")) {
                            Task {
                                await permissionService.requestPhotoLibraryPermission()
                                if permissionService.hasPhotoLibraryPermission {
                                    showingLibraryView = true
                                }
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .fullScreenCover(isPresented: $showingCameraView) {
                CameraView()
            }
            .fullScreenCover(isPresented: $showingLibraryView) {
                VideoLibraryView()
            }
        }
    }
    
    private func requestCameraPermission() {
        if permissionService.hasCameraPermission {
            showingCameraView = true
        } else {
            permissionType = .camera
            showingPermissionAlert = true
        }
    }
    
    private func requestPhotoLibraryPermission() {
        if permissionService.hasPhotoLibraryPermission {
            showingLibraryView = true
        } else {
            permissionType = .photoLibrary
            showingPermissionAlert = true
        }
    }
}

#Preview {
    ContentView()
}
