# TestFlight Preparation Guide for My Contact Point

## Overview
This guide provides step-by-step instructions for preparing the My Contact Point iOS app for TestFlight deployment.

## Prerequisites
- Apple Developer Account ($99/year)
- Xcode 15.0 or later
- iOS device for testing
- Valid Apple Developer Program membership

## Step 1: Create iOS App Project in Xcode

### 1.1 Open Xcode and Create New Project
1. Launch Xcode
2. Select "Create a new Xcode project"
3. Choose "iOS" → "App"
4. Click "Next"

### 1.2 Configure Project Settings
- **Product Name**: `MyContactPoint`
- **Bundle Identifier**: `com.mycontactpoint.app` (or your preferred identifier)
- **Language**: Swift
- **Interface**: SwiftUI
- **Use Core Data**: No
- **Include Tests**: Yes

### 1.3 Save Project
- Choose `/Users/taylorlarson/myContactPoint` as the save location
- Click "Create"

## Step 2: Configure App Settings

### 2.1 General Settings
1. Select the project in the navigator
2. Select the "MyContactPoint" target
3. In the "General" tab:
   - **Display Name**: `My Contact Point`
   - **Bundle Identifier**: `com.mycontactpoint.app`
   - **Version**: `1.0`
   - **Build**: `1`
   - **Deployment Target**: `iOS 15.0`

### 2.2 Signing & Capabilities
1. In the "Signing & Capabilities" tab:
   - Check "Automatically manage signing"
   - Select your Apple Developer Team
   - Ensure the bundle identifier is unique

### 2.3 Info.plist Configuration
Add the following keys to `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>My Contact Point needs camera access to record your baseball swing for biomechanical analysis.</string>
<key>NSMicrophoneUsageDescription</key>
<string>My Contact Point needs microphone access to record audio with your swing videos for better analysis.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>My Contact Point needs photo library access to save and manage your swing videos.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>My Contact Point needs permission to save your analyzed swing videos to your photo library.</string>
```

## Step 3: Add Source Files

### 3.1 Copy Source Files
Copy all Swift files from `Sources/MyContactPoint/` to the new Xcode project:
- `MyContactPointApp.swift`
- `ContentView.swift`
- `AuthService.swift`
- `CameraPermissionService.swift`
- `CameraView.swift`
- `LogoView.swift`
- `OnboardingTutorialView.swift`
- `SplashScreenView.swift`
- `VideoLibraryView.swift`
- `VideoUploadService.swift`

### 3.2 Add Dependencies
1. In Xcode, go to File → Add Package Dependencies
2. Add the following packages:
   - **Supabase**: `https://github.com/supabase/supabase-swift.git`
   - **PostHog**: `https://github.com/PostHog/posthog-ios.git`

### 3.3 Add Assets
1. Copy `Assets.xcassets` to the project
2. Add app icons (1024x1024 for App Store)
3. Add launch screen assets

## Step 4: Configure Supabase

### 4.1 Update Supabase Configuration
In `AuthService.swift` and `VideoUploadService.swift`, update the Supabase configuration:
```swift
let supabaseURL = URL(string: "YOUR_SUPABASE_URL")!
let supabaseKey = "YOUR_SUPABASE_ANON_KEY"
```

### 4.2 Environment Configuration
Create a configuration file for different environments:
```swift
struct SupabaseConfig {
    static let url = "YOUR_SUPABASE_URL"
    static let anonKey = "YOUR_SUPABASE_ANON_KEY"
}
```

## Step 5: Build and Test

### 5.1 Build Configuration
1. Select "Any iOS Device" as the destination
2. Choose "Release" configuration
3. Build the project (⌘+B)

### 5.2 Test on Device
1. Connect an iOS device
2. Select the device as the destination
3. Run the app (⌘+R)
4. Test all functionality:
   - User authentication
   - Camera permissions
   - Video recording
   - Video upload
   - Video library

## Step 6: Prepare for TestFlight

### 6.1 Archive the App
1. Select "Any iOS Device" as destination
2. Go to Product → Archive
3. Wait for the archive to complete

### 6.2 Upload to App Store Connect
1. In the Organizer, select your archive
2. Click "Distribute App"
3. Choose "App Store Connect"
4. Select "Upload"
5. Follow the upload process

## Step 7: Configure App Store Connect

### 7.1 App Information
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Create a new app:
   - **Name**: `My Contact Point`
   - **Primary Language**: English
   - **Bundle ID**: `com.mycontactpoint.app`
   - **SKU**: `mycontactpoint-001`

### 7.2 App Store Information
Fill in the required information:
- **App Description**: Describe the baseball swing analysis features
- **Keywords**: baseball, swing, analysis, biomechanics, sports
- **Support URL**: Your support website
- **Marketing URL**: Your marketing website

### 7.3 Screenshots
Upload screenshots for:
- iPhone 6.7" (iPhone 15 Pro Max)
- iPhone 6.5" (iPhone 14 Plus)
- iPhone 5.5" (iPhone 8 Plus)

## Step 8: TestFlight Beta Testing

### 8.1 Internal Testing
1. In App Store Connect, go to TestFlight
2. Add internal testers (up to 100)
3. Submit for review

### 8.2 External Testing
1. Create external testing groups
2. Add external testers (up to 10,000)
3. Submit for review

### 8.3 Beta Review Process
- Apple reviews TestFlight builds
- Review typically takes 24-48 hours
- Address any feedback from Apple

## Step 9: Production Release

### 9.1 Final Testing
- Test all features thoroughly
- Verify performance on various devices
- Check for memory leaks and crashes

### 9.2 Submit for Review
1. Complete all App Store Connect information
2. Submit for App Store review
3. Wait for Apple's review (typically 24-48 hours)

## Troubleshooting

### Common Issues
1. **Signing Errors**: Ensure your Apple Developer account is active
2. **Build Failures**: Check that all dependencies are properly added
3. **Upload Failures**: Verify bundle identifier is unique
4. **Review Rejections**: Address Apple's feedback promptly

### Support Resources
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [TestFlight Documentation](https://developer.apple.com/testflight/)

## Next Steps After TestFlight

1. **Gather Feedback**: Collect user feedback from beta testers
2. **Iterate**: Make improvements based on feedback
3. **Prepare for Launch**: Finalize marketing materials
4. **Submit to App Store**: Submit for public release

## Important Notes

- **Privacy**: Ensure all privacy policies are in place
- **Terms of Service**: Create terms of service for the app
- **Support**: Set up customer support channels
- **Analytics**: Configure PostHog analytics for user insights
- **Backup**: Keep regular backups of your project

---

**Status**: Ready for TestFlight preparation
**Last Updated**: October 3, 2025
**Next Action**: Follow Step 1 to create the iOS app project in Xcode
