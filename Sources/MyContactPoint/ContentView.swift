//
//  ContentView.swift
//  MyContactPoint
//
//  Created by Taylor Larson on 9/19/25.
//

import SwiftUI

struct ContentView: View {
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
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
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
                        // TODO: Navigate to video upload
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Upload My Swing")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        // TODO: Navigate to video library
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
            .toolbar(.hidden, for: .navigationBar)
            #endif
        }
    }
}

#Preview {
    ContentView()
}
