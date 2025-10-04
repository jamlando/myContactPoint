# My Contact Point - Tech Stack Wiki

## Table of Contents
1. [Project Overview](#project-overview)
2. [Frontend Architecture](#frontend-architecture)
3. [Backend Infrastructure](#backend-infrastructure)
4. [Database Design](#database-design)
5. [Analytics & Monitoring](#analytics--monitoring)
6. [Machine Learning & AI](#machine-learning--ai)
7. [Development Tools](#development-tools)
8. [Deployment & DevOps](#deployment--devops)
9. [Security & Privacy](#security--privacy)
10. [Development Workflow](#development-workflow)
11. [Team Onboarding](#team-onboarding)
12. [Troubleshooting](#troubleshooting)

---

## Project Overview

**My Contact Point** is a baseball hitting mechanics analysis iOS app that helps players improve their swing through biomechanical comparison with MLB averages.

### Key Metrics
- **Version**: 1.3
- **Platform**: iOS 15+
- **Target Devices**: iPhone (primary), iPad (future)
- **Development Model**: Solo development with AI assistance (Cursor)
- **Monetization**: Freemium ($4.99/month premium tier)

### Core Features
- Real-time biomechanical analysis using 40 data points (8 body landmarks × 5 swing phases)
- Visual overlays comparing user swings to MLB averages
- Progress tracking and educational resources
- Multilingual support (EN, ES, JA, KO, ZH)
- Offline support with cloud sync

---

## Frontend Architecture

### Technology Stack
- **Primary Framework**: SwiftUI (iOS 15+)
- **Language**: Swift 6.2
- **Architecture Pattern**: MVVM (Model-View-ViewModel)
- **Navigation**: SwiftUI NavigationView with custom flow management
- **State Management**: @State, @StateObject, @ObservableObject

### UI Framework Details

#### SwiftUI Implementation
```swift
// Main App Structure
@main
struct MyContactPointApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

#### Navigation Flow
```
SplashScreenView → OnboardingTutorialView → HomeView
                                    ↓
                              VideoUploadView (planned)
```

#### Key Components
1. **SplashScreenView**: App launch screen with 3-second auto-transition
2. **OnboardingTutorialView**: 5-slide tutorial with swipe navigation
3. **LogoView**: Reusable component with multiple size variants
4. **HomeView**: Main dashboard with upload and library access
5. **ContentView**: Root view managing navigation state

#### UI Design System
- **Colors**: System colors with custom baseball theme
- **Typography**: San Francisco font family (system default)
- **Icons**: SF Symbols for consistency
- **Layout**: Auto Layout with SwiftUI's adaptive design
- **Accessibility**: VoiceOver support, WCAG 2.1 compliance

### Project Structure
```
Sources/MyContactPoint/
├── MyContactPointApp.swift          # App entry point
├── ContentView.swift                # Root navigation controller
├── Views/
│   ├── SplashScreenView.swift       # Launch screen
│   ├── OnboardingTutorialView.swift # Tutorial implementation
│   └── Components/
│       └── LogoView.swift           # Reusable logo component
├── Services/                        # Business logic layer
│   ├── AnalyticsService.swift       # PostHog integration
│   └── DataPersistenceService.swift # Local + cloud storage
└── Assets.xcassets/                 # Images and icons
```

---

## Backend Infrastructure

### Primary Backend: Supabase
**Supabase** serves as the complete backend-as-a-service solution providing:

#### Core Services
1. **PostgreSQL Database**: Relational database with JSONB support
2. **Authentication**: JWT-based auth with social logins
3. **Storage**: S3-compatible object storage for video files
4. **Real-time**: WebSocket subscriptions for live updates
5. **Edge Functions**: Serverless functions for custom logic

#### Configuration
- **Project ID**: `myContactPoint`
- **Region**: East US (North Virginia)
- **Database Version**: PostgreSQL 17
- **Local Development**: Docker-based with Supabase CLI

#### API Integration
```swift
// Supabase Swift Client Configuration
let supabase = SupabaseClient(
    supabaseURL: URL(string: Config.supabaseURL)!,
    supabaseKey: Config.supabaseKey
)
```

#### Environment Setup
```toml
# supabase/config.toml
project_id = "myContactPoint"

[api]
enabled = true
port = 54321

[db]
port = 54322
major_version = 17

[storage]
enabled = true
file_size_limit = "50MiB"
```

### Secondary Services

#### Vercel (Planned)
- **Edge Functions**: Video processing APIs
- **Deployment**: Serverless function hosting
- **CDN**: Global content delivery

#### Apple Services
- **TestFlight**: Beta testing and distribution
- **App Store Connect**: Production app distribution
- **Apple Vision**: On-device pose detection

---

## Database Design

### Schema Overview
The database supports comprehensive biomechanical analysis with 40 data points across 5 swing phases.

#### Core Tables

##### Users & Authentication
```sql
-- Users table (extends Supabase auth.users)
CREATE TABLE public.users (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    subscription_tier subscription_tier DEFAULT 'free',
    subscription_expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User preferences
CREATE TABLE public.user_preferences (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    tutorial_completed BOOLEAN DEFAULT false,
    language_preference TEXT DEFAULT 'en',
    analysis_depth TEXT DEFAULT 'basic'
);
```

##### Video & Analysis Data
```sql
-- Swing videos table
CREATE TABLE public.swing_videos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    filename TEXT NOT NULL,
    file_path TEXT NOT NULL, -- Supabase Storage path
    file_size BIGINT,
    duration_seconds DECIMAL(5,2),
    resolution TEXT,
    fps INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Swing analyses (40 data points: 8 landmarks × 5 phases)
CREATE TABLE public.swing_analyses (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    video_id UUID REFERENCES public.swing_videos(id) ON DELETE CASCADE NOT NULL,
    analysis_status analysis_status DEFAULT 'uploaded',
    
    -- Pose detection results (40 data points)
    pose_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    
    -- Analysis results
    overall_score DECIMAL(5,2), -- 0-100 overall swing score
    phase_scores JSONB DEFAULT '{}'::jsonb,
    mlb_comparison JSONB DEFAULT '{}'::jsonb,
    
    -- Recommendations
    improvement_areas TEXT[],
    drill_recommendations TEXT[]
);
```

##### Reference Data
```sql
-- MLB comparison data (reference data)
CREATE TABLE public.mlb_comparison_data (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    landmark body_landmark NOT NULL,
    phase swing_phase NOT NULL,
    average_x DECIMAL(10,6),
    average_y DECIMAL(10,6),
    standard_deviation_x DECIMAL(10,6),
    standard_deviation_y DECIMAL(10,6),
    sample_size INTEGER,
    data_source TEXT -- 'OpenBiomechanics', 'KinaTrax', etc.
);
```

#### Custom Types
```sql
CREATE TYPE swing_phase AS ENUM ('stance', 'load', 'stride', 'contact', 'follow_through');
CREATE TYPE body_landmark AS ENUM ('head', 'left_shoulder', 'right_shoulder', 'left_hip', 'right_hip', 'left_knee', 'right_knee', 'left_ankle', 'right_ankle', 'left_wrist', 'right_wrist', 'left_elbow', 'right_elbow');
CREATE TYPE analysis_status AS ENUM ('uploaded', 'processing', 'analyzed', 'error');
CREATE TYPE subscription_tier AS ENUM ('free', 'premium');
```

#### Security: Row Level Security (RLS)
All user data is protected with RLS policies:

```sql
-- Users can only access their own data
CREATE POLICY "Users can manage own videos" ON public.swing_videos 
FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own analyses" ON public.swing_analyses 
FOR ALL USING (auth.uid() = user_id);

-- Public read access for reference data
CREATE POLICY "Anyone can read MLB comparison data" ON public.mlb_comparison_data 
FOR SELECT USING (true);
```

#### Performance Optimization
```sql
-- Key indexes for performance
CREATE INDEX idx_swing_videos_user_id ON public.swing_videos(user_id);
CREATE INDEX idx_swing_analyses_user_id ON public.swing_analyses(user_id);
CREATE INDEX idx_swing_analyses_status ON public.swing_analyses(analysis_status);
```

### Migration Management
- **Tool**: Supabase CLI with migration files
- **Location**: `supabase/migrations/`
- **Naming**: Timestamp-based (e.g., `20250925154534_initial_schema.sql`)
- **Environment**: Separate local/production migrations

---

## Analytics & Monitoring

### PostHog Analytics
**PostHog** provides comprehensive product analytics and user behavior tracking.

#### Configuration
```swift
// PostHog iOS SDK Setup
let config = PostHogConfig(
    apiKey: Config.posthogKey, // Format: phc_...
    host: Config.posthogHost   // https://us.i.posthog.com
)
PostHogSDK.shared.setup(config)
```

#### Key Events Tracked
1. **App Lifecycle**
   - `app_launched`
   - `app_backgrounded`
   - `app_terminated`

2. **Tutorial Flow**
   - `tutorial_started`
   - `tutorial_slide_viewed` (with slide_number)
   - `tutorial_completed`
   - `tutorial_skipped`

3. **Video Analysis**
   - `video_upload_started`
   - `video_upload_completed`
   - `analysis_requested`
   - `analysis_completed`

4. **User Engagement**
   - `swing_comparison_viewed`
   - `drill_recommendation_viewed`
   - `progress_chart_viewed`

#### Event Implementation
```swift
// Example event tracking
PostHogSDK.shared.capture("tutorial_slide_viewed", properties: [
    "slide_number": 1,
    "slide_name": "Welcome",
    "user_type": "first_time"
])
```

#### Analytics Storage
Events are also stored locally in the database for detailed analysis:

```sql
CREATE TABLE public.session_analytics (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    session_id TEXT NOT NULL,
    event_name TEXT NOT NULL,
    event_properties JSONB DEFAULT '{}'::jsonb,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

## Machine Learning & AI

### Apple Vision Framework
**Apple Vision** provides on-device pose detection for privacy and performance.

#### Core Implementation
```swift
import Vision

// Human body pose detection request
let request = VNDetectHumanBodyPoseRequest { request, error in
    guard let observations = request.results as? [VNHumanBodyPoseObservation] else {
        return
    }
    
    // Process pose landmarks
    for observation in observations {
        // Extract 8 key landmarks for analysis
        let landmarks = try observation.recognizedPoints(.all)
        // Process landmarks for swing analysis
    }
}
```

#### Key Landmarks (8 total)
1. **Head**: Overall posture and balance
2. **Shoulders** (Left/Right): Upper body rotation and alignment
3. **Hips** (Left/Right): Lower body mechanics and power generation
4. **Knees** (Left/Right): Stance stability and weight transfer
5. **Ankles** (Left/Right): Foundation and balance
6. **Wrists** (Left/Right): Bat control and swing path
7. **Elbows** (Left/Right): Arm mechanics and power transfer

#### Swing Phases (5 total)
1. **Stance**: Initial batting position
2. **Load**: Weight shift and preparation
3. **Stride**: Forward movement and timing
4. **Contact**: Bat-ball impact point
5. **Follow-through**: Completion of swing

#### Data Processing Pipeline
```
Video Upload → Apple Vision → Pose Detection → 40 Data Points → MLB Comparison → Analysis Results
```

### Fallback: Vercel API (Planned)
For older devices without Apple Vision support:
- **Cloud Processing**: Server-side pose detection
- **API Endpoint**: Vercel Edge Functions
- **Fallback Logic**: Automatic detection of device capabilities

---

## Development Tools

### Primary Development Environment

#### Xcode
- **Version**: 26.0 (Build 17A324)
- **Swift Version**: 6.2 (swiftlang-6.2.0.19.9)
- **iOS Target**: iOS 15.0+
- **Simulator**: iPhone 14 Pro (recommended)

#### Package Management
```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0"),
    .package(url: "https://github.com/PostHog/posthog-ios.git", from: "3.0.0"),
]
```

#### System Requirements
- **macOS**: 12.0+ (Monterey or later)
- **RAM**: 8GB+ recommended
- **Storage**: 10GB+ for Xcode and simulators
- **Apple Developer Account**: Free tier sufficient for development

### Development Environment Setup

#### Required Tools
1. **Xcode**: iOS development IDE
2. **Homebrew**: Package manager for macOS
3. **Supabase CLI**: Database management
4. **Docker Desktop**: Local Supabase environment
5. **Git**: Version control

#### Installation Commands
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Supabase CLI
brew install supabase/tap/supabase

# Install Docker Desktop (GUI installer)
# Download from: https://www.docker.com/products/docker-desktop

# Verify installations
supabase --version  # v2.45.5+
docker --version    # 24.0+
```

### Code Editor: Cursor
**Cursor** serves as the AI-powered development environment for rapid development.

#### Key Features
- **AI Code Generation**: Context-aware code suggestions
- **Codebase Understanding**: Semantic search and analysis
- **Pair Programming**: AI assistant for complex tasks
- **Documentation**: Automated documentation generation

#### Configuration
- **Model**: Claude Sonnet 4
- **Context**: Full codebase awareness
- **Integration**: Direct Xcode project support

---

## Deployment & DevOps

### Version Control: GitHub
- **Repository**: Private GitHub repository
- **Branching Strategy**: Git Flow (main, develop, feature branches)
- **CI/CD**: GitHub Actions (planned)

#### Git Workflow
```bash
# Development workflow
git checkout -b feature/new-feature
# Make changes
git add .
git commit -m "feat: add new feature"
git push origin feature/new-feature
# Create pull request
```

### Build & Distribution

#### TestFlight (Beta Testing)
- **Internal Testing**: 1-2 core testers
- **External Testing**: Up to 10,000 beta users
- **Distribution**: Automatic via Xcode Cloud (planned)

#### App Store Distribution
- **Target**: iOS App Store
- **Pricing Model**: Freemium with IAP
- **Premium Tier**: $4.99/month subscription
- **Markets**: Global (multilingual support)

### Environment Management

#### Local Development
```bash
# Start local Supabase
supabase start

# Services available:
# - Database: postgresql://postgres:postgres@127.0.0.1:54322/postgres
# - API: http://127.0.0.1:54321
# - Studio: http://127.0.0.1:54323
# - Storage: http://127.0.0.1:54321/storage/v1/s3
```

#### Production Environment
- **Database**: Supabase hosted PostgreSQL
- **Storage**: Supabase S3-compatible storage
- **CDN**: Supabase global CDN
- **Analytics**: PostHog cloud hosting

---

## Security & Privacy

### Data Protection
1. **Row Level Security (RLS)**: Database-level access control
2. **JWT Authentication**: Secure token-based auth
3. **HTTPS/TLS**: All communications encrypted
4. **Local Storage**: Encrypted device storage

### Privacy Compliance
- **GDPR**: European data protection compliance
- **CCPA**: California privacy law compliance
- **Data Minimization**: Collect only necessary data
- **User Control**: Data deletion and export options

### Security Measures
```sql
-- RLS policy example
CREATE POLICY "Users can only access own data" 
ON swing_analyses FOR ALL 
USING (auth.uid() = user_id);
```

---

## Development Workflow

### Daily Development Process
1. **Local Environment**: Start Supabase services
2. **Code Development**: Use Cursor for AI-assisted coding
3. **Testing**: Xcode simulator and unit tests
4. **Database Changes**: Create migrations
5. **Version Control**: Commit and push changes

### Testing Strategy
1. **Unit Tests**: SwiftUI view testing
2. **Integration Tests**: API and database testing
3. **Manual Testing**: Device and simulator testing
4. **Performance Testing**: Memory and speed optimization

### Code Quality
- **SwiftLint**: Code style enforcement (planned)
- **Code Reviews**: AI-assisted via Cursor
- **Documentation**: Inline comments and README updates
- **Performance Monitoring**: Xcode Instruments

---

## Team Onboarding

### New Developer Setup (30 minutes)
1. **Prerequisites**: Install Xcode, Homebrew, Docker
2. **Repository**: Clone project from GitHub
3. **Dependencies**: Run `swift package resolve`
4. **Local Backend**: Start Supabase with `supabase start`
5. **Build**: Open in Xcode and build project
6. **Test**: Run on simulator to verify setup

### Knowledge Requirements
- **iOS Development**: SwiftUI, UIKit basics
- **Database**: SQL fundamentals, PostgreSQL
- **API Integration**: RESTful APIs, JSON handling
- **Version Control**: Git workflow
- **Testing**: Unit testing, debugging

### Learning Resources
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Supabase Swift Guide](https://supabase.com/docs/guides/getting-started/quickstarts/swift)
- [PostHog iOS SDK](https://posthog.com/docs/libraries/ios)
- [Apple Vision Framework](https://developer.apple.com/documentation/vision)

---

## Troubleshooting

### Common Issues

#### Build Errors
```bash
# Clean build folder
Cmd + Shift + K

# Reset package caches
File → Packages → Reset Package Caches

# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData
```

#### Supabase Connection Issues
1. **Check Local Services**: `supabase status`
2. **Restart Services**: `supabase stop && supabase start`
3. **Verify Configuration**: Check `supabase/config.toml`
4. **Database Access**: Test connection in Studio dashboard

#### PostHog Analytics Issues
1. **API Key Format**: Ensure `phc_` prefix
2. **Network Connectivity**: Test in simulator vs device
3. **Event Format**: Validate event properties
4. **Dashboard**: Check PostHog project settings

#### Performance Issues
1. **Memory Leaks**: Use Xcode Instruments
2. **Slow Queries**: Check database indexes
3. **UI Lag**: Profile with SwiftUI performance tools
4. **Large Files**: Optimize video compression

### Debug Tools
- **Xcode Debugger**: Breakpoints and variable inspection
- **Console Logs**: Print statements and os_log
- **Instruments**: Memory, CPU, and network profiling
- **Supabase Studio**: Database query testing
- **PostHog Dashboard**: Event tracking verification

### Support Contacts
- **Supabase**: [Discord Community](https://discord.supabase.com)
- **PostHog**: [Slack Community](https://posthog.com/slack)
- **Apple Developer**: [Forums](https://forums.developer.apple.com)
- **SwiftUI**: [Swift Forums](https://forums.swift.org/c/swiftui)

---

## Appendix

### Technology Versions
- **iOS**: 15.0+ (deployment target)
- **Swift**: 6.2
- **Xcode**: 26.0
- **Supabase Swift**: 2.32.0+
- **PostHog iOS**: 3.31.0+
- **PostgreSQL**: 17
- **Docker**: 24.0+

### Useful Commands
```bash
# Supabase
supabase start              # Start local development
supabase stop               # Stop local services
supabase status             # Check service status
supabase db reset           # Reset local database
supabase gen types swift    # Generate Swift types

# Git
git status                  # Check working directory
git log --oneline          # View commit history
git branch -a              # List all branches
git pull origin main       # Update from remote

# Xcode
xcodebuild -list           # List schemes and targets
xcodebuild clean           # Clean build artifacts
xcrun simctl list          # List available simulators
```

### Configuration Files
- `Package.swift`: Swift package dependencies
- `supabase/config.toml`: Local Supabase configuration
- `.gitignore`: Version control exclusions
- `README.md`: Project overview and setup
- `TEST_ENVIRONMENT_SETUP.md`: Detailed testing setup

---

**Last Updated**: September 25, 2025  
**Maintained By**: Development Team  
**Version**: 1.0
