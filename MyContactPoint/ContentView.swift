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
                AuthenticationView(isSignUpMode: $isSignUpMode)
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
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CameraView()
                .tabItem {
                    Image(systemName: "camera")
                    Text("Record")
                }
                .tag(0)
            
            VideoLibraryView()
                .tabItem {
                    Image(systemName: "video")
                    Text("Library")
                }
                .tag(1)
        }
    }
}

#Preview {
    ContentView()
}
