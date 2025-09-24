# My Contact Point - iOS App

A baseball hitting mechanics analysis iOS app that helps players improve their swing through biomechanical comparison with MLB averages.

## Project Overview

**Version**: 1.3  
**Platform**: iOS 15+  
**Language**: Swift  
**Framework**: SwiftUI  

## Features Implemented

### ✅ Onboarding Tutorial
- 5 interactive slides teaching app usage
- Swipeable TabView with PageTabViewStyle
- Progress indicator dots
- Analytics tracking for each slide
- Tutorial completion persistence

### ✅ Project Structure
- SwiftUI-based iOS project
- Modular view architecture
- Service layer for analytics and data persistence
- Proper navigation flow

### ✅ Brand Integration
- Custom SVG logo integrated throughout the app
- Reusable LogoView component with multiple sizes
- Consistent branding across all screens
- Professional visual identity

## Project Structure

```
MyContactPoint/
├── MyContactPoint/
│   ├── MyContactPointApp.swift          # Main app entry point
│   ├── ContentView.swift                # Home screen placeholder
│   ├── Views/
│   │   ├── SplashScreenView.swift       # App launch screen
│   │   ├── OnboardingTutorialView.swift # Tutorial implementation
│   │   └── Components/
│   │       └── LogoView.swift           # Reusable logo component
│   ├── Services/
│   │   ├── AnalyticsService.swift       # PostHog analytics integration
│   │   └── DataPersistenceService.swift # UserDefaults + Supabase sync
│   └── Assets.xcassets/
│       └── AppLogo.imageset/            # Custom SVG logo
├── Assets.xcassets/                     # App icons and assets
└── Preview Content/                     # SwiftUI preview assets
```

## Tutorial Slides

1. **Welcome Slide**: App introduction with baseball logo
2. **How to Film**: Instructions for proper swing recording
3. **Understanding Analysis**: Side-by-side comparison preview
4. **Navigation Guide**: App interface overview with highlights
5. **Get Started**: Call-to-action with upload/skip options

## Technical Implementation

### Navigation Flow
```
SplashScreen → OnboardingTutorial → HomeScreen
                    ↓
              VideoUploadScreen (placeholder)
```

### Analytics Events
- `tutorial_started`
- `tutorial_slide_viewed` (with slide_number)
- `tutorial_completed`
- `tutorial_skipped`

### Data Persistence
- Tutorial completion status stored in UserDefaults
- Ready for Supabase integration
- Service layer abstraction for easy backend integration

## Dependencies

- **Supabase Swift**: Backend services (Auth, Database, Storage)
- **PostHog iOS**: Analytics tracking
- **SwiftUI**: UI framework
- **Foundation**: Core iOS functionality

## Getting Started

1. Open `MyContactPoint.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run the project
4. Experience the onboarding tutorial flow

## Next Steps

- [ ] Implement Supabase backend integration
- [ ] Add PostHog analytics configuration
- [ ] Create Video Upload Screen
- [ ] Implement Apple Vision pose detection
- [ ] Add Home Screen with navigation
- [ ] Create Progress Tracker Screen
- [ ] Add Settings/Profile Screen

## Development Notes

- iOS 15+ target for SwiftUI compatibility
- Portrait mode primary orientation
- Accessibility considerations included
- Multilingual support ready (iOS String Catalogs)
- TestFlight integration planned

## Contact

For questions or support, please refer to the project documentation or contact the development team.
