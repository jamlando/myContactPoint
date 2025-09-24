# My Contact Point - Development Scratchpad

## Background and Motivation

**Project**: My Contact Point - Baseball Hitting Mechanics Analysis iOS App
**Version**: 1.3 (PRD Date: September 05, 2025)
**Current Request**: Develop the first wireframe for testing based on the updated comprehensive PRD

**Key Objectives**:
- Create an iOS app that helps baseball players improve hitting mechanics through biomechanical analysis
- Compare user swings to MLB averages using 40 data points (8 body landmarks across 5 swing phases)
- Provide visual overlays, progress tracking, and educational resources
- Support multiple languages and TestFlight beta testing
- Solo developer approach using Cursor as AI co-pilot

**Updated Technical Stack**:
- **Frontend**: Swift with SwiftUI for iOS development
- **Backend**: Supabase (PostgreSQL, Storage, Auth) for data and video storage
- **Analytics**: PostHog for anonymous usage tracking
- **Deployment**: Vercel for backend APIs and Edge Functions
- **Version Control**: GitHub for code and CI/CD
- **ML/AI**: Apple Vision for on-device pose detection, Core ML for custom models
- **Design**: AI tools (Canva, Logo Diffusion, MidJourney) for assets

**Core Differentiators**:
- Real-time biomechanical comparison using 40 data points
- Visual overlays for intuitive feedback
- Integration of strength training progress tracking
- Educational content tied directly to swing phases
- Comprehensive database structure with Supabase
- Offline support with local caching

## Key Challenges and Analysis

**Technical Challenges**:
1. **ML/AI Integration**: Implement Apple Vision (VNDetectHumanBodyPoseRequest) for on-device pose detection, with Vercel API fallback for older devices
2. **Video Processing**: Handle video upload to Supabase Storage, processing, and comparison with MLB data
3. **Data Management**: Secure storage in Supabase with RLS policies, privacy compliance (GDPR/CCPA)
4. **Offline Support**: Local caching with SwiftData/Core Data, sync when online
5. **Performance**: <10 second video processing, <2 second app load time

**Design Challenges**:
1. **User Experience**: Create intuitive interface for complex biomechanical data
2. **Visual Communication**: Effectively display comparison overlays (user vs MLB averages)
3. **Progress Visualization**: Clear graphs using Swift Charts for improvement tracking
4. **Multilingual Support**: iOS String Catalogs for multiple languages (EN, ES, JA, KO, ZH)
5. **Accessibility**: WCAG 2.1 compliance with VoiceOver support

**Business Challenges**:
1. **MLB Data Access**: Securing datasets (OpenBiomechanics Project or KinaTrax license)
2. **Beta Testing**: TestFlight setup with internal (1-2 testers) and external (up to 10K) users
3. **Content Creation**: Educational resources and expert partnerships
4. **Monetization**: Freemium model with In-App Purchases ($4.99/month premium tier)
5. **Solo Development**: Leveraging Cursor AI for rapid development

## High-level Task Breakdown

### Phase 1: Foundation & First Wireframe (Current Focus)
- [ ] **Task 1.1**: Set up project structure and development environment
  - Success Criteria: iOS project created with Swift/SwiftUI, Supabase integration, PostHog setup, GitHub repository
- [ ] **Task 1.2**: Create Splash Screen wireframe/mockup
  - Success Criteria: Visual design with AI-generated app logo, loading animation, auto-transition to Home/Tutorial
- [ ] **Task 1.3**: Design Onboarding Tutorial wireframe/mockup (NEW)
  - Success Criteria: 3-5 interactive slides teaching app usage, swipeable TabView, completion tracking
- [ ] **Task 1.4**: Design Home Screen wireframe/mockup
  - Success Criteria: Navigation bar, upload button, video library, quick actions, PostHog event tracking
- [ ] **Task 1.5**: Create Video Upload Screen wireframe/mockup
  - Success Criteria: Camera/gallery options, filming instructions, validation, Supabase Storage integration
- [ ] **Task 1.6**: Design Swing Comparison Screen wireframe/mockup
  - Success Criteria: Side-by-side video display, overlay system, comparison stats, Apple Vision integration
- [ ] **Task 1.7**: Create Progress Tracker Screen wireframe/mockup
  - Success Criteria: Timeline view, Swift Charts graphs, feedback section, Supabase data queries
- [ ] **Task 1.8**: Design Settings/Profile Screen wireframe/mockup
  - Success Criteria: User profile management, preferences, language options, Supabase Auth integration
- [ ] **Task 1.9**: Create Educational Resources Screen wireframe/mockup
  - Success Criteria: Training library, categorized content, search functionality, Supabase Storage streaming

### Phase 2: Core Development (Future)
- [ ] Supabase database setup and RLS policies
- [ ] Apple Vision ML integration for pose detection
- [ ] Vercel API development for video processing
- [ ] PostHog analytics implementation
- [ ] Offline support with SwiftData/Core Data
- [ ] Error handling and user feedback systems

### Phase 3: Testing & Beta (Future)
- [ ] TestFlight setup with App Store Connect
- [ ] Internal beta testing (developer + 1-2 testers)
- [ ] External beta testing (up to 10K users)
- [ ] Feedback collection via TestFlight and in-app surveys
- [ ] Performance optimization based on beta feedback

## Project Status Board

### Current Sprint: Wireframe Development
- [ ] **In Progress**: Project setup and first wireframe creation
- [ ] **Pending**: Individual screen wireframes (7 screens total)
- [ ] **Pending**: Wireframe review and iteration
- [ ] **Pending**: Technical feasibility assessment

### Completed Tasks
- [x] PRD analysis and project understanding
- [x] Initial planning and task breakdown

## Current Status / Progress Tracking

**Current Phase**: Planning and Onboarding Tutorial Wireframe Development
**Last Updated**: Updated with PRD 1.3 and user preferences
**Next Milestone**: Complete Onboarding Tutorial wireframe design in Figma

**User Preferences Confirmed**:
- Design Tools: Figma and Xcode
- Priority Screen: Onboarding Tutorial
- Logo: Baseball placeholder (user currently designing final logo)

**Immediate Next Steps**:
1. Set up iOS project structure with Swift/SwiftUI
2. Implement Onboarding Tutorial directly in Xcode
3. Create basic UI components and navigation flow

## Executor's Feedback or Assistance Requests

**PLANNER MODE ACTIVE** - Creating comprehensive test environment setup guide

**Current Request**: Switch to Planner mode and setup a file that walks a user through how to setup a test environment for this app

**PLANNER ANALYSIS**:
The user needs a comprehensive guide for setting up a test environment for the My Contact Point iOS app. This is critical for:
1. Enabling proper testing of the Onboarding Tutorial implementation
2. Preparing for future development phases
3. Ensuring all team members can test the app consistently
4. Documenting the complete development environment setup

**PLANNER TASK BREAKDOWN**:
- [x] **Task P.1**: Analyze current project structure and dependencies ✅
- [x] **Task P.2**: Document Xcode and iOS development requirements ✅
- [x] **Task P.3**: Create Supabase test environment setup instructions ✅
- [x] **Task P.4**: Document PostHog analytics test configuration ✅
- [x] **Task P.5**: Create step-by-step setup guide with verification steps ✅
- [x] **Task P.6**: Include troubleshooting section for common issues ✅
- [x] **Task P.7**: Document test data and sample content requirements ✅
- [x] **Task P.8**: Update PostHog integration with official documentation ✅

**PLANNER DELIVERABLE COMPLETED**: 
✅ Comprehensive test environment setup guide created: `TEST_ENVIRONMENT_SETUP.md`
✅ PostHog integration details updated with official iOS SDK documentation

**PLANNER ANALYSIS COMPLETE**:
The test environment setup guide includes:
1. **Complete Development Environment**: Xcode, iOS Simulator, Command Line Tools
2. **Dependency Management**: Swift Package Manager setup for Supabase and PostHog
3. **Backend Services**: Supabase project setup with database schema and RLS policies
4. **Analytics Configuration**: PostHog project setup with event tracking
5. **App Configuration**: Config.swift template and initialization code
6. **Testing Procedures**: Simulator and physical device testing workflows
7. **Verification Checklists**: Step-by-step verification for all components
8. **Troubleshooting Guide**: Common issues and solutions
9. **Test Data**: Sample content and data for comprehensive testing
10. **Performance Guidelines**: Launch time and UI responsiveness targets
11. **PostHog Integration**: Official SDK configuration with proper API key format and host settings

**PLANNER RECOMMENDATIONS**:
- The guide is ready for immediate use by any developer
- All current app features (Onboarding Tutorial, Navigation, Logo integration) are covered
- The setup supports future development phases (Video Upload, ML Analysis, etc.)
- The guide includes both technical setup and user testing procedures
- Troubleshooting section addresses common iOS development issues
- PostHog integration follows official documentation with proper configuration

**UPDATED TODO LIST**:
- [x] Test environment setup guide completed
- [ ] PostHog analytics SDK integration with proper configuration and event tracking

**Current Status**: Test environment setup guide completed with updated PostHog integration details

## Detailed Onboarding Tutorial Wireframe Planning

### Tutorial Overview
Based on PRD Section 5.2 and 10.3, the Onboarding Tutorial is a new requirement that should appear after the Splash Screen and before the Home Screen for first-time users. It teaches users how to navigate the app and film swings correctly.

### Tutorial Structure (5 Slides)
1. **Welcome Slide**: App introduction and value proposition
2. **How to Film**: Proper swing recording techniques
3. **Understanding Analysis**: Explanation of biomechanical comparison
4. **Navigation Guide**: Key app features and navigation
5. **Get Started**: Call-to-action to begin using the app

### Wireframe Specifications

#### Slide 1: Welcome Slide
- **Layout**: Full-screen with centered content
- **Elements**:
  - Baseball placeholder logo (top center)
  - App name: "My Contact Point" (below logo)
  - Tagline: "Improve your swing with MLB-level analysis"
  - Illustration: Stylized baseball player silhouette
  - Progress indicator: 1 of 5 dots
- **Interactions**: Swipe right or tap "Next" button
- **Analytics**: Track `tutorial_slide_viewed` with slide_number: 1

#### Slide 2: How to Film Your Swing
- **Layout**: Split layout with instructions and visual guide
- **Elements**:
  - Title: "How to Film Your Swing"
  - Instructions list:
    - "Place camera 10-15 feet away"
    - "Film from the side view"
    - "Capture your full body motion"
    - "Slow motion is optional but helpful"
  - Visual: Phone mockup showing proper camera angle
  - Progress indicator: 2 of 5 dots
- **Interactions**: Swipe or tap "Next"
- **Analytics**: Track `tutorial_slide_viewed` with slide_number: 2

#### Slide 3: Understanding Your Analysis
- **Layout**: Side-by-side comparison preview
- **Elements**:
  - Title: "See How You Compare to MLB Players"
  - Left side: User swing silhouette (red overlay)
  - Right side: MLB average silhouette (blue overlay)
  - Text: "We analyze 40 data points across 5 swing phases"
  - Visual: Simplified comparison diagram
  - Progress indicator: 3 of 5 dots
- **Interactions**: Swipe or tap "Next"
- **Analytics**: Track `tutorial_slide_viewed` with slide_number: 3

#### Slide 4: Navigation Guide
- **Layout**: App interface preview with highlighted features
- **Elements**:
  - Title: "Navigate Your Progress"
  - Mockup of Home Screen with highlights:
    - Upload button (highlighted)
    - Video library (highlighted)
    - Progress tracker (highlighted)
  - Text: "Track your improvement over time"
  - Progress indicator: 4 of 5 dots
- **Interactions**: Swipe or tap "Next"
- **Analytics**: Track `tutorial_slide_viewed` with slide_number: 4

#### Slide 5: Get Started
- **Layout**: Call-to-action centered layout
- **Elements**:
  - Title: "Ready to Improve Your Swing?"
  - Subtitle: "Upload your first video to get started"
  - Primary button: "Upload My Swing" (navigates to Video Upload)
  - Secondary button: "Skip for Now" (navigates to Home)
  - Progress indicator: 5 of 5 dots (complete)
- **Interactions**: 
  - Tap "Upload My Swing" → Video Upload Screen
  - Tap "Skip for Now" → Home Screen
- **Analytics**: Track `tutorial_completed` or `tutorial_skipped`

### Technical Implementation Plan

#### Figma Wireframe Requirements
- **Canvas Size**: iPhone 14 Pro (393 × 852px) - primary target
- **Components Needed**:
  - Baseball placeholder logo component
  - Progress indicator dots component
  - Button components (primary/secondary)
  - Typography styles (headings, body text)
  - Color palette (red for user data, blue for MLB data)
- **Frames**: 5 tutorial slides + navigation flow
- **Prototyping**: Basic tap/swipe interactions between slides

#### Xcode Implementation Plan
- **SwiftUI Structure**:
  ```swift
  struct OnboardingTutorialView: View {
      @State private var currentSlide = 0
      @State private var tutorialCompleted = false
      
      var body: some View {
          TabView(selection: $currentSlide) {
              // 5 tutorial slides
          }
          .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
      }
  }
  ```
- **Navigation**: Present modally from Splash Screen
- **Data Persistence**: Store completion status in Supabase (`users.preferences.tutorial_completed`)
- **Analytics Integration**: PostHog events for each slide view and completion

#### Database Schema Updates
- **Supabase Table**: `users.preferences.tutorial_completed` (BOOLEAN)
- **PostHog Events**:
  - `tutorial_started`
  - `tutorial_slide_viewed` (with slide_number)
  - `tutorial_completed`
  - `tutorial_skipped`

### Design Considerations
- **Accessibility**: VoiceOver support for all text and buttons
- **Multilingual**: Prepare for iOS String Catalogs (EN, ES, JA, KO, ZH)
- **Visual Hierarchy**: Clear progression from general to specific
- **Brand Consistency**: Use baseball theme throughout
- **User Experience**: Smooth transitions, clear progress indication
- **Error Handling**: Graceful handling if tutorial data fails to save

### Success Criteria
- [ ] Figma wireframe includes all 5 tutorial slides with proper layout
- [ ] Baseball placeholder logo integrated consistently
- [ ] Clear visual hierarchy and typography
- [ ] Prototype demonstrates smooth slide transitions
- [ ] Technical implementation plan documented
- [ ] Analytics tracking plan defined
- [ ] Accessibility considerations included

## Lessons

**Project Setup**:
- Always read existing scratchpad before starting new tasks
- Create comprehensive task breakdown with clear success criteria
- Document assumptions and dependencies early
- Update planning when PRD changes are provided

**Technical Considerations**:
- iOS 15+ target for SwiftUI compatibility
- Portrait mode primary orientation
- TestFlight integration for beta testing
- Apple Vision for on-device ML processing
- Supabase for backend services (Auth, Database, Storage)
- PostHog for analytics tracking
- Vercel for API deployment
- GitHub for version control

**Design Principles**:
- User-friendly interface for complex data
- Visual overlays for intuitive feedback
- Multilingual support with iOS String Catalogs
- Accessibility compliance (WCAG 2.1)
- AI-generated assets for rapid prototyping
- Offline support with local caching

**Updated PRD Insights**:
- Solo developer approach with Cursor AI assistance
- Comprehensive database structure with RLS policies
- Freemium monetization model ($4.99/month premium)
- Enhanced error handling and user feedback
- Onboarding tutorial requirement added
- Performance targets: <10s video processing, <2s app load
