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
    
    var body: some View {
        Group {
            if showSplash {
                SplashScreenView(showSplash: $showSplash, showTutorial: $showTutorial)
            } else if showTutorial {
                OnboardingTutorialView(showTutorial: $showTutorial)
            } else if authService.isAuthenticated {
                MainAppView()
            } else {
                AuthenticationView()
            }
        }
        .environmentObject(authService)
        .onAppear {
            // Check if user is already authenticated
            Task {
                await authService.checkAuthStatus()
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
