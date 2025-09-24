# My Contact Point - Test Environment Setup Guide

## Overview

This guide walks you through setting up a complete test environment for the My Contact Point iOS app. The app is currently in Phase 1 with a fully implemented Onboarding Tutorial and basic navigation structure.

## Prerequisites

### System Requirements
- **macOS**: macOS 12.0 (Monterey) or later
- **Xcode**: Version 14.0 or later (recommended: latest stable version)
- **iOS Simulator**: iOS 15.0 or later
- **Device**: iPhone with iOS 15.0+ (for physical testing)
- **Apple Developer Account**: Free account sufficient for simulator testing

### Required Accounts
- **Supabase Account**: Free tier available at [supabase.com](https://supabase.com)
- **PostHog Account**: Free tier available at [posthog.com](https://posthog.com)
- **GitHub Account**: For version control (optional but recommended)

## Step 1: Development Environment Setup

### 1.1 Install Xcode
```bash
# Install Xcode from Mac App Store or Apple Developer Portal
# Verify installation
xcode-select --version
```

### 1.2 Install Command Line Tools
```bash
# Install Xcode command line tools
xcode-select --install
```

### 1.3 Verify iOS Simulator
```bash
# List available simulators
xcrun simctl list devices
```

## Step 2: Project Setup

### 2.1 Clone/Download Project
```bash
# Navigate to your development directory
cd ~/Development

# Clone the repository (if using Git)
git clone <repository-url> myContactPoint
cd myContactPoint

# OR extract from downloaded ZIP file
```

### 2.2 Open Project in Xcode
```bash
# Open the main Xcode project
open MyContactPoint/MyContactPoint.xcodeproj
```

### 2.3 Configure Project Settings
1. **Select Target Device**: Choose iPhone simulator (iPhone 14 Pro recommended)
2. **Set Deployment Target**: iOS 15.0
3. **Configure Bundle Identifier**: 
   - Go to Project Settings → General → Bundle Identifier
   - Use format: `com.yourname.mycontactpoint` (replace yourname)

## Step 3: Dependencies Setup

### 3.1 Swift Package Manager Dependencies
The project uses Swift Package Manager with these dependencies:
- **Supabase Swift Client**: v2.0.0+
- **PostHog iOS SDK**: v3.0.0+

**Setup Steps**:
1. In Xcode, go to File → Add Package Dependencies
2. Add these URLs:
   - `https://github.com/supabase/supabase-swift.git`
   - `https://github.com/PostHog/posthog-ios.git`
3. Select latest versions and add to target

### 3.2 Verify Dependencies
```swift
// Check Package.swift file contains:
dependencies: [
    .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0"),
    .package(url: "https://github.com/PostHog/posthog-ios.git", from: "3.0.0"),
]
```

## Step 4: Supabase Test Environment

### 4.1 Create Supabase Project
1. Go to [supabase.com](https://supabase.com) and sign up/login
2. Click "New Project"
3. Choose organization and enter project details:
   - **Name**: `my-contact-point-test`
   - **Database Password**: Generate strong password (save it!)
   - **Region**: Choose closest to your location

### 4.2 Configure Supabase Settings
1. **Get Project URL and API Key**:
   - Go to Settings → API
   - Copy "Project URL" and "anon public" key

2. **Create Test Database Schema**:
```sql
-- Run in Supabase SQL Editor
-- Users table
CREATE TABLE users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email TEXT UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    preferences JSONB DEFAULT '{}'::jsonb
);

-- Tutorial completion tracking
ALTER TABLE users ADD COLUMN tutorial_completed BOOLEAN DEFAULT FALSE;

-- Sample data for testing
INSERT INTO users (email, tutorial_completed) VALUES 
('test@example.com', false),
('demo@example.com', true);
```

### 4.3 Configure Row Level Security (RLS)
```sql
-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policy for authenticated users
CREATE POLICY "Users can view own data" ON users
    FOR ALL USING (auth.uid() = id);
```

### 4.4 Storage Setup
1. Go to Storage → Create Bucket
2. **Bucket Name**: `swing-videos`
3. **Public**: No (private bucket)
4. **File Size Limit**: 100MB
5. **Allowed MIME Types**: `video/*`

## Step 5: PostHog Analytics Setup

### 5.1 Create PostHog Project
1. Go to [posthog.com](https://posthog.com) and sign up/login
2. Create new project:
   - **Name**: `My Contact Point Test`
   - **Environment**: Development

### 5.2 Get API Key
1. Go to Project Settings → API Keys
2. Copy "Project API Key"
3. **Note**: The API key format is `phc_` followed by a long string
4. **Example**: `phc_RbYsWCVSOPU8FHEntAoYIxW9CaXiA3Ci9uWgIx3VeRO`

### 5.3 Configure PostHog Events
Create these test events in PostHog:
- `app_launched`
- `tutorial_started`
- `tutorial_slide_viewed`
- `tutorial_completed`
- `tutorial_skipped`
- `video_upload_started`
- `video_upload_completed`

## Step 6: App Configuration

### 6.1 Create Configuration File
Create `Config.swift` in your project:

```swift
import Foundation

struct Config {
    // Supabase Configuration
    static let supabaseURL = "YOUR_SUPABASE_URL"
    static let supabaseKey = "YOUR_SUPABASE_ANON_KEY"
    
    // PostHog Configuration
    static let posthogKey = "phc_YOUR_POSTHOG_API_KEY"  // Format: phc_ followed by key
    static let posthogHost = "https://us.i.posthog.com"  // Default US region
    
    // App Configuration
    static let isDebugMode = true
    static let enableAnalytics = true
}
```

### 6.2 Update App Initialization
Modify `MyContactPointApp.swift`:

```swift
import SwiftUI
import Supabase
import PostHog

@main
struct MyContactPointApp: App {
    init() {
        // Initialize Supabase
        let supabase = SupabaseClient(
            supabaseURL: URL(string: Config.supabaseURL)!,
            supabaseKey: Config.supabaseKey
        )
        
        // Initialize PostHog with proper configuration
        if Config.enableAnalytics {
            let config = PostHogConfig(
                apiKey: Config.posthogKey, 
                host: Config.posthogHost
            )
            PostHogSDK.shared.setup(config)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 6.3 PostHog Integration Details
Based on the official PostHog iOS integration guide:

**Installation Method**: Swift Package Manager (already configured in Package.swift)
```swift
dependencies: [
    .package(url: "https://github.com/PostHog/posthog-ios.git", from: "3.0.0")
]
```

**Configuration Requirements**:
- **API Key**: Format `phc_` followed by long string
- **Host**: Default is `https://us.i.posthog.com` (US region)
- **Config Object**: Use `PostHogConfig` for proper setup

**Event Tracking Example**:
```swift
// Send a test event
PostHogSDK.shared.capture("Test Event")

// Send event with properties
PostHogSDK.shared.capture("tutorial_slide_viewed", properties: [
    "slide_number": 1,
    "slide_name": "Welcome"
])
```

## Step 7: Testing Setup

### 7.1 Simulator Testing
1. **Launch Simulator**:
   ```bash
   # Open iOS Simulator
   open -a Simulator
   ```

2. **Select Device**: iPhone 14 Pro (393 × 852px)

3. **Build and Run**:
   - In Xcode, press `Cmd + R`
   - Or click the Play button

### 7.2 Physical Device Testing
1. **Connect iPhone** via USB
2. **Trust Computer** on device
3. **Select Device** in Xcode
4. **Sign Developer Certificate**:
   - Go to Signing & Capabilities
   - Select your Apple ID
   - Enable "Automatically manage signing"

### 7.3 Test Scenarios

#### Basic App Flow Test
1. **Launch App** → Should show Splash Screen
2. **Wait 3 seconds** → Should auto-transition to Tutorial
3. **Complete Tutorial** → Should navigate to Home Screen
4. **Skip Tutorial** → Should navigate to Home Screen

#### Tutorial Flow Test
1. **Slide 1**: Welcome screen with logo
2. **Slide 2**: How to film instructions
3. **Slide 3**: Analysis explanation
4. **Slide 4**: Navigation guide
5. **Slide 5**: Get started call-to-action

#### Analytics Test
1. **Check PostHog Dashboard** for events
2. **Verify Events**: `app_launched`, `tutorial_started`, etc.
3. **Test Event Properties**: Slide numbers, completion status

## Step 8: Verification Checklist

### 8.1 Environment Verification
- [ ] Xcode opens project without errors
- [ ] Dependencies resolve successfully
- [ ] App builds without warnings
- [ ] App launches in simulator
- [ ] App launches on physical device

### 8.2 Feature Verification
- [ ] Splash screen displays correctly
- [ ] Tutorial slides navigate properly
- [ ] Logo displays in all sizes
- [ ] Home screen loads after tutorial
- [ ] Navigation works smoothly

### 8.3 Backend Verification
- [ ] Supabase connection successful
- [ ] Database queries work
- [ ] Storage bucket accessible
- [ ] PostHog events firing
- [ ] Analytics dashboard populated

### 8.4 Performance Verification
- [ ] App launch time < 2 seconds
- [ ] Smooth animations (60fps)
- [ ] No memory leaks
- [ ] Responsive UI interactions

## Step 9: Troubleshooting

### 9.1 Common Build Issues

#### Dependency Resolution Errors
```bash
# Clean build folder
Cmd + Shift + K

# Reset package caches
File → Packages → Reset Package Caches

# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData
```

#### Simulator Issues
```bash
# Reset simulator
xcrun simctl erase all

# Restart simulator
xcrun simctl shutdown all
xcrun simctl boot "iPhone 14 Pro"
```

### 9.2 Runtime Issues

#### Supabase Connection Errors
- Verify URL and API key in Config.swift
- Check Supabase project status
- Ensure RLS policies are correct

#### PostHog Analytics Issues
- Verify API key is correct
- Check network connectivity
- Ensure events are properly formatted

#### Navigation Issues
- Check @State variables are properly bound
- Verify view hierarchy is correct
- Ensure all views are properly imported

### 9.3 Performance Issues

#### Slow Launch Time
- Check for heavy initialization in App init
- Verify dependencies are loaded asynchronously
- Profile with Instruments

#### UI Lag
- Check for expensive operations on main thread
- Verify SwiftUI best practices
- Use Xcode's View Debugger

## Step 10: Test Data and Content

### 10.1 Sample User Data
```json
{
  "users": [
    {
      "email": "test@example.com",
      "tutorial_completed": false,
      "preferences": {
        "language": "en",
        "notifications": true
      }
    }
  ]
}
```

### 10.2 Test Video Files
- Create sample swing videos (10-30 seconds)
- Test different formats: MP4, MOV
- Test various file sizes: 5MB, 25MB, 50MB
- Test different orientations: Portrait, Landscape

### 10.3 Analytics Test Data
- Generate test events for all user flows
- Verify event properties are correct
- Test event deduplication
- Verify user identification

## Next Steps

After completing this setup:

1. **Test Onboarding Tutorial**: Verify all 5 slides work correctly
2. **Test Navigation**: Ensure smooth transitions between screens
3. **Test Analytics**: Confirm PostHog events are firing
4. **Test Backend**: Verify Supabase connections work
5. **Performance Testing**: Ensure app meets performance targets
6. **User Testing**: Get feedback on tutorial flow and design

## Support and Resources

### Documentation
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Supabase Swift Guide](https://supabase.com/docs/guides/getting-started/quickstarts/swift)
- [PostHog iOS SDK](https://posthog.com/docs/libraries/ios)

### Community
- [SwiftUI Forums](https://forums.swift.org/categories/swiftui)
- [Supabase Discord](https://discord.supabase.com)
- [PostHog Slack](https://posthog.com/slack)

### Development Tools
- [Xcode](https://developer.apple.com/xcode/)
- [Instruments](https://developer.apple.com/instruments/)
- [Simulator](https://developer.apple.com/documentation/xcode/running-your-app-in-the-simulator)

---

**Last Updated**: September 19, 2025  
**Version**: 1.0  
**Maintained By**: Development Team
