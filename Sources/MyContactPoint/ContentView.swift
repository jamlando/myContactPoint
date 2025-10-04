//
//  ContentView.swift
//  MyContactPoint
//
//  Created by Taylor Larson on 9/19/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @State private var showSplash = true
    @State private var showTutorial = false
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView(showSplash: $showSplash, showTutorial: $showTutorial)
            } else if showTutorial {
                OnboardingTutorialView(showTutorial: $showTutorial)
            } else {
                HomeView()
            }
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var authService: AuthService
    @State private var showingLogoutAlert = false
    @State private var showingCameraView = false
    @State private var showingVideoLibrary = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // User Info Header
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome back!")
                                .font(.headline)
                            if let user = authService.currentUser {
                                Text(user.email ?? "User")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Button(action: {
                            showingLogoutAlert = true
                        }) {
                            Image(systemName: "person.circle")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                }
                
                LogoView(size: .large)
                
                Text("My Contact Point")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Improve your swing with MLB-level analysis")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 16) {
                    Button(action: {
                        showingCameraView = true
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Record My Swing")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        showingVideoLibrary = true
                    }) {
                        HStack {
                            Image(systemName: "video.fill")
                            Text("View My Videos")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Home")
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
            .sheet(isPresented: $showingCameraView) {
                CameraView()
            }
            .sheet(isPresented: $showingVideoLibrary) {
                VideoLibraryView()
            }
            .alert(isPresented: $showingLogoutAlert) {
                Alert(
                    title: Text("Sign Out"),
                    message: Text("Are you sure you want to sign out?"),
                    primaryButton: .destructive(Text("Sign Out")) {
                        Task {
                            try? await authService.signOut()
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService())
}
