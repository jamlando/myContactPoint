//
//  SplashScreenView.swift
//  MyContactPoint
//
//  Created by Taylor Larson on 9/19/25.
//

import SwiftUI

struct SplashScreenView: View {
    @Binding var showSplash: Bool
    @Binding var showTutorial: Bool
    
    var body: some View {
        ZStack {
            Color.blue
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                LogoView(size: .extraLarge)
                
                Text("My Contact Point")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Improve your swing with MLB-level analysis")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
            }
        }
        .onAppear {
            // Auto-transition after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSplash = false
                    showTutorial = true
                }
            }
        }
    }
}

#Preview {
    SplashScreenView(showSplash: .constant(true), showTutorial: .constant(false))
}
