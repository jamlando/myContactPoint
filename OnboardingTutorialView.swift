//
//  OnboardingTutorialView.swift
//  MyContactPoint
//
//  Created by Taylor Larson on 9/19/25.
//

import SwiftUI

struct OnboardingTutorialView: View {
    @Binding var showTutorial: Bool
    @State private var currentSlide = 0
    
    private let slides = [
        TutorialSlide(
            title: "Welcome to My Contact Point",
            subtitle: "Improve your swing with MLB-level analysis",
            content: "We'll help you analyze your baseball swing using advanced biomechanical data and compare it to MLB averages.",
            imageName: "figure.baseball"
        ),
        TutorialSlide(
            title: "How to Film Your Swing",
            subtitle: "Get the best results",
            content: "• Place camera 10-15 feet away\n• Film from the side view\n• Capture your full body motion\n• Slow motion is optional but helpful",
            imageName: "camera.fill"
        ),
        TutorialSlide(
            title: "Understanding Your Analysis",
            subtitle: "See how you compare to MLB players",
            content: "We analyze 40 data points across 5 swing phases to give you detailed feedback on your mechanics.",
            imageName: "chart.bar.fill"
        ),
        TutorialSlide(
            title: "Navigate Your Progress",
            subtitle: "Track your improvement over time",
            content: "Use the upload button to add videos, view your library, and track your progress with detailed analytics.",
            imageName: "chart.line.uptrend.xyaxis"
        ),
        TutorialSlide(
            title: "Ready to Improve Your Swing?",
            subtitle: "Upload your first video to get started",
            content: "Let's begin your journey to better hitting mechanics!",
            imageName: "play.circle.fill"
        )
    ]
    
    var body: some View {
        VStack {
            TabView(selection: $currentSlide) {
                ForEach(0..<slides.count, id: \.self) { index in
                    TutorialSlideView(slide: slides[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Custom page indicator
            HStack(spacing: 8) {
                ForEach(0..<slides.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentSlide ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: currentSlide)
                }
            }
            .padding(.bottom, 20)
            
            // Navigation buttons
            HStack {
                if currentSlide > 0 {
                    Button("Previous") {
                        withAnimation {
                            currentSlide -= 1
                        }
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                if currentSlide < slides.count - 1 {
                    Button("Next") {
                        withAnimation {
                            currentSlide += 1
                        }
                    }
                    .foregroundColor(.blue)
                } else {
                    VStack(spacing: 12) {
                        Button("Upload My Swing") {
                            // TODO: Navigate to video upload
                            showTutorial = false
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        
                        Button("Skip for Now") {
                            showTutorial = false
                        }
                        .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.horizontal)
        }
        .navigationBarHidden(true)
    }
}

struct TutorialSlide {
    let title: String
    let subtitle: String
    let content: String
    let imageName: String
}

@available(iOS 15.0, macOS 11.0, *)
struct TutorialSlideView: View {
    let slide: TutorialSlide
    
    var body: some View {
        VStack(spacing: 30) {
            LogoView(size: .large)
            
            VStack(spacing: 16) {
                Text(slide.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(slide.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Image(systemName: slide.imageName)
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text(slide.content)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    OnboardingTutorialView(showTutorial: .constant(true))
}
