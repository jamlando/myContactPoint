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
    let onSignInTapped: () -> Void
    
    private let slides = [
        TutorialSlide(
            subtitle: "Improve your swing with MLB-level analysis",
            content: "We'll help you analyze your baseball swing using advanced biomechanical data and compare it to MLB averages.",
            imageName: "figure.baseball"
        ),
        TutorialSlide(
            subtitle: "How to Film Your Swing",
            content: "• Place camera 10-15 feet away\n• Film from the side view\n• Capture your full body motion\n• Slow motion is optional but helpful",
            imageName: "camera.fill"
        ),
        TutorialSlide(
            subtitle: "Understanding Your Analysis",
            content: "We analyze 40 data points across 5 swing phases to give you detailed feedback on your mechanics.",
            imageName: "chart.bar.fill"
        ),
        TutorialSlide(
            subtitle: "Navigate Your Progress",
            content: "Use the upload button to add videos, view your library, and track your progress with detailed analytics.",
            imageName: "chart.line.uptrend.xyaxis"
        ),
        TutorialSlide(
            subtitle: "Ready to Improve Your Swing?",
            content: "Let's begin your journey to better hitting mechanics!",
            imageName: "play.circle.fill"
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Static Header Component
            OnboardingHeaderView(onSignInTapped: onSignInTapped)
            
            TabView(selection: $currentSlide) {
                ForEach(0..<slides.count, id: \.self) { index in
                    TutorialSlideView(slide: slides[index])
                        .tag(index)
                }
            }
            #if os(iOS)
            .tabViewStyle(.page(indexDisplayMode: .never))
            #else
            .tabViewStyle(.automatic)
            #endif
            
            // Navigation elements with optimized spacing
            VStack(spacing: 20) {
                // Custom page indicator (moved above primary button per ONBOARD.4)
                HStack(spacing: 10) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentSlide ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
                            .animation(.easeInOut(duration: 0.3), value: currentSlide)
                    }
                }
                .padding(.vertical, 4)

                // Primary action button (now below dots) - standardized across all slides
                Button("Sign up Now") {
                    // TODO: Navigate to sign up flow
                    showTutorial = false
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .font(.headline)

                // Navigation text (below buttons)
                HStack {
                    if currentSlide > 0 {
                        Button("Previous") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentSlide -= 1
                            }
                        }
                        .foregroundColor(.blue)
                        .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    if currentSlide < slides.count - 1 {
                        Button("Next") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentSlide += 1
                            }
                        }
                        .foregroundColor(.blue)
                        .font(.subheadline)
                    }
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        #if os(iOS)
        .navigationBarHidden(true)
        #endif
    }
}

struct OnboardingHeaderView: View {
    let onSignInTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Top row with Sign In button
            HStack {
                Spacer()
                Button("Sign In") {
                    onSignInTapped()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            // Title and logo - centered together
            VStack(spacing: 16) {
                Text("My Contact Point")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                LogoView(size: .large)
            }
        }
        .padding(.bottom, 16)
    }
}

struct TutorialSlide {
    let subtitle: String
    let content: String
    let imageName: String
}

struct TutorialSlideView: View {
    let slide: TutorialSlide
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 20)
            
            VStack(spacing: 24) {
                Text(slide.subtitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                Image(systemName: slide.imageName)
                    .font(.system(size: 64))
                    .foregroundColor(.blue)
                
                Text(slide.content)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
            }
            
            Spacer(minLength: 20)
        }
    }
}

#Preview {
    OnboardingTutorialView(showTutorial: .constant(true), onSignInTapped: {})
}
