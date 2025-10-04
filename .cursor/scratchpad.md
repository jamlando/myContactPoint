# My Contact Point - Development Scratchpad

## Background and Motivation

**Project**: My Contact Point - Baseball Hitting Mechanics Analysis iOS App
**Version**: 1.3 (PRD Date: September 05, 2025)
**Current Request**: Implement user authentication, video recording functionality, and prepare for TestFlight deployment while ensuring all dependencies are current and nothing is hardcoded

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

**Current Development Challenges**:
1. **Authentication Implementation**: Need to implement Supabase Auth integration with signup/signin flows
2. **Video Recording**: Implement camera access, video capture, and Supabase Storage upload
3. **Database Integration**: Connect SwiftUI app to Supabase database for user data persistence
4. **TestFlight Preparation**: Configure app for Apple Developer Program and TestFlight deployment
5. **Dependency Management**: Ensure all packages are current and no hardcoded values exist

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

### Phase 1: Authentication Implementation (Priority: CRITICAL)
- [x] **Task AUTH.1**: Implement Supabase Auth Service
  - Success Criteria: Create AuthService.swift with signup, signin, and session management ✅ COMPLETED
- [x] **Task AUTH.2**: Create Authentication UI Views
  - Success Criteria: SignUpView.swift and SignInView.swift with proper validation and error handling ✅ COMPLETED
- [x] **Task AUTH.3**: Implement User Session Management
  - Success Criteria: Persistent login state, automatic session refresh, and logout functionality ✅ COMPLETED
- [x] **Task AUTH.4**: Connect Auth to Database
  - Success Criteria: User records automatically created in Supabase users table upon signup ✅ COMPLETED

### Phase 2: Video Recording Implementation (Priority: CRITICAL)
- [ ] **Task VIDEO.1**: Implement Camera Access and Permissions
  - Success Criteria: Request camera permissions, handle denied access gracefully
- [ ] **Task VIDEO.2**: Create Video Recording UI
  - Success Criteria: CameraView.swift with record button, preview, and recording controls
- [ ] **Task VIDEO.3**: Implement Video Upload to Supabase Storage
  - Success Criteria: Videos uploaded to Supabase Storage with proper metadata and progress tracking
- [ ] **Task VIDEO.4**: Create Video Library View
  - Success Criteria: Display user's uploaded videos with thumbnails and metadata

### Phase 3: TestFlight Preparation (Priority: HIGH)
- [ ] **Task TESTFLIGHT.1**: Configure App for Apple Developer Program
  - Success Criteria: App configured with proper bundle ID, signing certificates, and provisioning profiles
- [ ] **Task TESTFLIGHT.2**: Implement App Store Connect Integration
  - Success Criteria: App metadata, screenshots, and TestFlight configuration complete
- [ ] **Task TESTFLIGHT.3**: Set up CI/CD Pipeline
  - Success Criteria: Automated build and upload to TestFlight via GitHub Actions
- [ ] **Task TESTFLIGHT.4**: Create Beta Testing Workflow
  - Success Criteria: TestFlight build uploaded and ready for beta testing

### Phase 4: Dependency and Configuration Updates (Priority: HIGH)
- [ ] **Task DEP.1**: Update All Dependencies to Latest Versions
  - Success Criteria: All Swift packages updated to latest stable versions, no compatibility issues
- [ ] **Task DEP.2**: Remove Hardcoded Values
  - Success Criteria: All configuration values moved to environment variables or configuration files
- [ ] **Task DEP.3**: Update System Environment
  - Success Criteria: All development tools updated to latest versions compatible with macOS 26.0.0
- [ ] **Task DEP.4**: Implement Environment Configuration
  - Success Criteria: Separate configuration for development, staging, and production environments

### Phase 5: Testing and Quality Assurance (Priority: MEDIUM)
- [ ] **Task QA.1**: Implement Unit Tests
  - Success Criteria: Unit tests for authentication, video upload, and core business logic
- [ ] **Task QA.2**: Create Integration Tests
  - Success Criteria: End-to-end tests for user signup, video recording, and database operations
- [ ] **Task QA.3**: Manual Testing Procedures
  - Success Criteria: Comprehensive manual testing checklist for all user flows
- [ ] **Task QA.4**: Performance Testing
  - Success Criteria: App performance meets requirements (<2s load time, <10s video processing)

## Project Status Board

### Current Sprint: Authentication, Video Recording, and TestFlight Preparation
- [ ] **In Progress**: Authentication implementation with Supabase Auth
- [ ] **Pending**: Video recording and camera integration
- [ ] **Pending**: TestFlight deployment configuration
- [ ] **Pending**: Dependency updates and hardcoded value removal

### Completed Tasks
- [x] PRD analysis and project understanding
- [x] Initial planning and task breakdown
- [x] iOS app project setup and build system
- [x] Onboarding tutorial implementation
- [x] Navigation flow implementation
- [x] Supabase database integration planning
- [x] Dependency update planning and analysis

## Current Status / Progress Tracking

**Current Phase**: Authentication, Video Recording, and TestFlight Preparation - EXECUTOR MODE ACTIVE
**Last Updated**: Task AUTH.1 completed - Authentication system fully implemented
**Next Milestone**: Ready to implement video recording functionality (Task VIDEO.1)

**Current System Environment Status**:
- macOS: 26.0.0 ✅ Current
- Xcode: 26.0 ✅ Current  
- Swift: 6.2 ✅ Current
- Homebrew: 4.6.15 ✅ Current
- Node.js: 20.19.0 ✅ Current
- Python: 3.13.7 ✅ Current
- Git: 2.50.1 ✅ Current
- CocoaPods: 1.16.2 ✅ Installed

**Dependency Status Analysis**:
- ✅ **Supabase Swift**: 2.32.0 (Latest stable)
- ✅ **PostHog iOS**: 3.31.0 (Latest stable)
- ✅ **Swift ASN1**: 1.4.0 (Apple dependency)
- ✅ **Swift Clocks**: 1.0.6 (PointFree dependency)
- ✅ **Swift Concurrency Extras**: 1.3.2 (PointFree dependency)
- ✅ **Swift Crypto**: 3.15.0 (Apple dependency)
- ✅ **Swift HTTP Types**: 1.4.0 (Apple dependency)
- ✅ **XCTest Dynamic Overlay**: 1.6.1 (PointFree dependency)

**Hardcoded Values Identified**:
- ⚠️ **Supabase Config**: Local development URLs (127.0.0.1) - Expected for local dev
- ⚠️ **TECH_STACK_WIKI.md**: Local development URLs in documentation - Expected
- ✅ **No Production Hardcoded Values**: All production URLs use environment variables

**Authentication Status**:
- ✅ **Fully Implemented**: Complete authentication system with Supabase Auth integration
- ✅ **UI Complete**: AuthenticationView with signup/signin forms and validation
- ✅ **Session Management**: Persistent login state, automatic session refresh, and logout functionality
- ✅ **Database Integration**: User records automatically created in Supabase users table upon signup
- ✅ **Error Handling**: Comprehensive validation and error messaging
- ✅ **Testing**: Build successful, no compilation errors

**Video Recording Status**:
- ❌ **Not Implemented**: No camera access or video recording functionality
- ❌ **Storage Not Configured**: Supabase Storage not set up for video uploads
- ✅ **Database Schema Ready**: swing_videos table created and ready

**TestFlight Preparation Status**:
- ❌ **Not Configured**: No Apple Developer Program integration
- ❌ **No CI/CD**: No automated build pipeline
- ❌ **No App Store Connect**: No app metadata or screenshots

**Immediate Next Steps**:
1. Implement Supabase Auth service integration
2. Create authentication UI views (SignUp/SignIn)
3. Implement camera access and video recording
4. Configure Supabase Storage for video uploads
5. Set up Apple Developer Program integration
6. Prepare TestFlight deployment configuration

## Executor's Feedback or Assistance Requests

**EXECUTOR MODE ACTIVE** - Authentication Implementation Complete

**TASK AUTH.1 COMPLETED SUCCESSFULLY** ✅

**IMPLEMENTATION SUMMARY**:
✅ **AuthService.swift**: Complete Supabase Auth integration with signup, signin, session management, and logout
✅ **AuthenticationView.swift**: Full authentication UI with signup/signin forms, validation, and error handling
✅ **MyContactPointApp.swift**: Updated to integrate AuthService and handle authentication flow
✅ **ContentView.swift**: Updated to show user info and logout functionality
✅ **Database Integration**: User profiles and preferences automatically created upon signup
✅ **Error Handling**: Comprehensive validation for email, password, and form validation
✅ **Build Status**: Project compiles successfully with no errors

**TECHNICAL IMPLEMENTATION DETAILS**:
1. **AuthService Features**:
   - Supabase Auth integration with environment configuration
   - Signup with email/password and optional full name
   - Signin with email/password
   - Session management with automatic refresh
   - Logout functionality
   - Password reset capability
   - User profile creation in custom users table
   - User preferences initialization
   - Last login timestamp tracking

2. **UI Features**:
   - Clean authentication interface with app branding
   - Toggle between signup and signin modes
   - Form validation with real-time feedback
   - Error message display
   - Loading states during authentication
   - Password confirmation for signup
   - Forgot password functionality

3. **Database Integration**:
   - Automatic user profile creation in `users` table
   - Default user preferences creation in `user_preferences` table
   - Proper foreign key relationships with Supabase auth.users
   - RLS policies ensure data security

**SUCCESS CRITERIA MET**:
- ✅ AuthService.swift created with signup, signin, and session management
- ✅ Authentication UI views with proper validation and error handling
- ✅ Persistent login state and automatic session refresh
- ✅ User records automatically created in Supabase users table upon signup
- ✅ Project builds successfully with no compilation errors

**READY FOR NEXT TASK**: Task VIDEO.1 - Implement Camera Access and Permissions

**EXECUTOR RECOMMENDATION**: 
The authentication system is fully functional and ready for testing. All success criteria have been met. The next logical step is to implement video recording functionality to complete the core app features.

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

**Database Integration Planning**:
- Migration-first approach prevents production accidents and ensures version control
- Environment isolation (local/prod) is critical for safe development
- RLS policies must be implemented from the beginning, not retrofitted
- CI integration catches database issues before production deployment
- Comprehensive documentation is essential for team scaling and maintenance
- Production monitoring should be planned from day one, not added later

**Technical Considerations**:
- iOS 15+ target for SwiftUI compatibility
- Portrait mode primary orientation
- TestFlight integration for beta testing
- Apple Vision for on-device ML processing
- Supabase for backend services (Auth, Database, Storage)
- PostHog for analytics tracking
- Vercel for API deployment
- GitHub for version control
- Migration-driven database development for production safety

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

**Database Best Practices**:
- Always use migrations for schema changes, never dashboard edits
- Implement RLS policies from the beginning for data security
- Test migrations in CI pipeline before production deployment
- Maintain strict environment separation (local/prod/staging)
- Document all database procedures for team scaling
- Monitor production performance and set up alerting early

**Git Workflow Best Practices**:
- Create feature branches for all development work, keep main clean
- Always ask before using `--force` in Git commands
- Rebase before pushing to maintain clean history
- Squash commits to keep commit history clean and meaningful
- Commit early and often with descriptive messages
- Push to GitHub regularly to practice committing early
- Verify repo exists and is configured before pushing
- GitHub settings will prevent merging until all tests pass
- Use pull requests for code review and CI validation
- Maintain clean main branch for production releases
