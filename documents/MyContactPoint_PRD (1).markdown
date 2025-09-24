# Product Requirements Document (PRD)

## 1. Document Information
- **Product Name:** My Contact Point
- **Version:** 1.3
- **Date:** September 05, 2025
- **Author:** Grok 4 (Assisted Draft)
- **Purpose:** This PRD outlines the requirements for developing an iOS mobile app that helps baseball players improve their hitting mechanics through biomechanical analysis, comparing user swings to MLB averages. The app is 100% data-driven, user-friendly, and targeted at players of all levels. It is based on provided wireframe descriptions and guides visual design, development, and implementation by a solo developer using Cursor as an AI co-pilot. This version incorporates Supabase for database and storage, PostHog for analytics, Vercel for deployment, and GitHub for version control. It includes a detailed database structure and addresses missing pieces for completeness.

## 2. Product Overview
### 2.1 Description
My Contact Point is a comprehensive iOS application designed to enhance baseball hitting mechanics by allowing users to upload videos of their swings, analyze them against aggregated MLB player data, and receive personalized improvement recommendations. The app uses biomechanical landmarks to provide objective, data-driven insights, tracks progress over time, and offers educational resources. It supports multiple languages to cater to a global audience.

Key differentiators:
- Real-time biomechanical comparison using 40 data points (8 body landmarks across 5 swing phases).
- Visual overlays for intuitive feedback.
- Integration of strength training progress tracking (user-inputted).
- Educational content tied directly to swing phases.

### 2.2 Goals and Objectives
- Empower users to self-improve their hitting mechanics without needing a coach.
- Provide accurate, data-backed comparisons to MLB averages for credibility.
- Track user progress to motivate sustained engagement.
- Support multilingual access for international users (e.g., Spanish, Japanese, Korean, Mandarin).
- Ensure a seamless, intuitive user experience from video upload to actionable insights.

### 2.3 Scope
- **In Scope:** Core features including splash screen, home navigation, video upload/analysis, progress tracking, settings, educational resources, and biomechanical analysis engine (with Supabase backend). Beta testing via TestFlight. Database and storage via Supabase. Analytics via PostHog. Deployment via Vercel. Version control via GitHub.
- **Out of Scope:** Advanced AI training (e.g., custom MLB data updates), hardware integrations (e.g., wearables), e-commerce for premium content, Android, or web versions. Initial release focuses on iOS.
- **TestFlight Scope:** Use TestFlight for beta testing with internal (developer, 1-2 trusted testers) and external testers (up to 10,000) to gather feedback and ensure stability before App Store submission.

### 2.4 Assumptions and Dependencies
- Access to MLB biomechanical data (e.g., OpenBiomechanics Project or licensed datasets like KinaTrax).
- Supabase for database (PostgreSQL) and storage (buckets for videos).
- PostHog for anonymous usage analytics.
- Vercel for backend API deployment and hosting.
- GitHub for version control and CI/CD integration.
- AI graphic design tools (e.g., Canva, Logo Diffusion, MidJourney) for logo, icons, and UI elements.
- Apple Developer Program account ($99/year) for TestFlight and App Store submission.
- No real-time multiplayer features; all data is user-specific and private.

## 3. Target Audience
- **Primary Users:** Baseball players aged 8+ (youth, high school, adult leagues, professionals).
- **Secondary Users:** Coaches, scouts, or parents monitoring progress.
- **Demographics:** Global, with emphasis on baseball-popular regions (US, Japan, Korea, Latin America). Users range from beginners seeking basic drills to advanced players analyzing fine mechanics.
- **User Needs:** Easy video upload, clear visual comparisons, personalized advice, progress visibility, multilingual support, secure data storage.

## 4. User Stories
- As a user, I want a quick splash screen so I can access the app without delay.
- As a user, I want a home screen with easy navigation to upload videos, view library, and access tools.
- As a user, I want to upload or record a swing video with guidance for optimal filming.
- As a user, I want to compare my swing to MLB averages with visual overlays and stats.
- As a user, I want to track my progress over time with graphs and feedback.
- As a user, I want to manage my profile, preferences, and share comparisons.
- As a user, I want access to educational resources categorized by swing phases.
- As a tester, I want to use TestFlight to try the app and provide feedback before public release.
- As a user, I want my profile data and videos securely stored and easily accessible across sessions.
- As a user, I want an onboarding tutorial to learn how to use the app effectively.
- As a user, I want clear error messages if video uploads or analysis fail.

## 5. Functional Requirements
### 5.1 Screens and Features
Detailed based on wireframe descriptions. Each screen includes layout, elements, and interactions.

#### 5.1.1 Splash Screen
- **Purpose:** Initial loading screen to brand the app and transition smoothly.
- **Elements:**
  - Prominent app logo (created via AI tools like Canva/Logo Diffusion).
  - App name: "My Contact Point".
  - Loading spinner: Animated baseball icon.
- **Interactions:**
  - Auto-transition to Home Screen after 2-3 seconds.
- **Requirements:** Support portrait orientation only. No user input required.

#### 5.1.2 Home Screen
- **Purpose:** Central hub for navigation and quick actions.
- **Elements:**
  - **Top Navigation Bar:**
    - Profile Icon: Links to Settings/Profile Screen.
    - Home Button: Refreshes or returns to this screen.
    - Hamburger Menu: Options including FAQ, About, Contact Support.
  - **Main Content Area:**
    - Upload Video Button: "Upload your Swing" – Navigates to Video Upload Screen.
    - Video Library: Thumbnails of user’s previous uploads with "Compare" button (navigates to Swing Comparison Screen).
    - Training Tools Button: Links to Educational Resources.
  - **Bottom Quick Navigation Bar:**
    - Home: Current screen.
    - Analyze: Direct to Video Upload Screen.
    - Progress Tracker: To Progress Tracker Screen.
    - Settings: To Settings/Profile Screen.
- **Interactions:** Scrollable content if library grows. Responsive to device size.
- **Requirements:** Persist user session; display personalized content if logged in. Track usage via PostHog (e.g., button clicks).

#### 5.1.3 Video Upload Screen
- **Purpose:** Enable easy video capture or selection for analysis.
- **Elements:**
  - Capture Button: Opens device camera for new recording (support slow-motion if available).
  - Upload from Gallery: Access phone’s media library.
  - Instructions: Text guide: "Film in slow motion (optional), place camera 10-15 feet away, side view, capture full body motion."
  - Next Button: Proceeds to Swing Comparison Screen after selection/recording.
- **Interactions:** Video preview after selection. Validation for video length/format (e.g., MP4, <30 seconds). Display error messages for failed uploads (e.g., “Invalid format, please use MP4”).
- **Requirements:** Permissions for camera/storage. Store videos in Supabase Storage. Log upload events in PostHog.

#### 5.1.4 Swing Comparison Screen
- **Purpose:** Core analysis feature comparing user swing to MLB data.
- **Elements:**
  - User Video: Plays on left side.
  - MLB Comparison: Aggregated average stick figure on right side (derived from MLB data).
  - Overlays: Key landmarks (hips, knees, shoulders, head, etc.) – User in red, MLB in blue.
  - Comparison Stats: Percentage alignment across 40 data points (8 landmarks x 5 phases).
  - Next Steps Button: Personalized advice using +/- system (e.g., "+ Hips more open at impact – Strengthen knee flexors" with exercise suggestions).
- **Interactions:** Play/pause/sync videos. Zoom on overlays. Export/share results (via email/social).
- **Requirements:** Backend ML (via Vercel-hosted API) for landmark detection and comparison. Store results in Supabase. Track analysis completions in PostHog.

#### 5.1.5 Progress Tracker Screen
- **Purpose:** Visualize improvements and suggest focus areas.
- **Elements:**
  - Timeline View: Chronological swing data.
  - Improvement Graph: Line/bar chart for landmark alignment over time (using Swift Charts).
  - Recent Comparisons: Thumbnails with progress markers.
  - Feedback Section: Algorithmic/coach-like text/video suggestions (e.g., "More tee work on inside pitching").
  - Exercise Improvement: User-inputted strength data (e.g., "Single leg press: 90lbs → 180lbs").
  - Next Steps: Targeted advice (e.g., "Raise hand position at load").
- **Interactions:** Interactive graphs (zoom/filter). Manual entry for exercise data.
- **Requirements:** Query Supabase for historical data. Log graph views in PostHog.

#### 5.1.6 Settings/Profile Screen
- **Purpose:** Manage user info and app preferences.
- **Elements:**
  - **User Profile:**
    - Photo, username, email, social links.
    - Age, play level (e.g., 8-10, high school).
    - Share feature: Send comparisons via email/social (UIActivityViewController).
  - **Preferences:**
    - Notifications (reminders, tips).
    - Language: English (default), Spanish, Japanese, Korean, Mandarin, etc.
  - **Account Management:**
    - Subscription details (if applicable), payments (via Apple In-App Purchases).
- **Interactions:** Edit/save profile. Toggle switches for prefs. Display error messages for failed saves (e.g., “Invalid email format”).
- **Requirements:** Store profile in Supabase. Secure authentication via Supabase Auth. Track profile updates in PostHog.

#### 5.1.7 Educational Resources Screen
- **Purpose:** Provide learning materials tied to mechanics.
- **Elements:**
  - Training Library: Videos, drills, tips (e.g., Joe Girardi on follow-through).
  - Categories: Organized by 5 swing phases (e.g., load, stride, contact, follow-through, finish).
- **Interactions:** Search/filter. Play embedded videos (streamed from Supabase Storage).
- **Requirements:** Content sourced from experts/partners, stored in Supabase. Offline access for downloaded items. Track video views in PostHog.

### 5.2 User Flows
- **Onboarding Flow:** Splash → Tutorial → Home (first-time: Profile setup prompt).
- **Core Analysis Flow:** Home → Upload → Select/Record Video → Compare → View Results → Save to Library/Progress.
- **Progress Review Flow:** Home → Progress Tracker → View Graphs → Next Steps → Educational Resources.
- **Settings Flow:** Any screen → Settings → Edit → Save.
- **Testing Flow:** TestFlight users access beta builds, provide feedback via TestFlight interface or in-app surveys, and report issues for pre-submission refinement.

### 5.3 Database Structure
This section defines the database structure for user profiles, video storage, and progress tracking using Supabase (PostgreSQL for relational data, Storage for videos). It supports PRD requirements (Sections 5.1.2, 5.1.3, 5.1.4, 5.1.5, 5.1.6) and is optimized for a solo developer.

#### 5.3.1 User Profiles (Table: `users`)
- **Table:** `users` (PostgreSQL)
- **Columns:**
  - `id`: UUID (primary key, auto-generated by Supabase Auth).
  - `username`: VARCHAR(50) (e.g., "Player123").
  - `email`: VARCHAR(255) (e.g., "player@example.com").
  - `profile_photo_url`: TEXT (URL to photo in Supabase Storage, nullable).
  - `age`: INTEGER (e.g., 15).
  - `play_level`: VARCHAR(20) (enum: "Youth", "HighSchool", "AdultLeague", "Professional").
  - `social_links`: JSONB (e.g., `{ "twitter": "player123", "instagram": null }`).
  - `created_at`: TIMESTAMPTZ (default: now()).
  - `updated_at`: TIMESTAMPTZ (updated on change).
  - `preferences`: JSONB
    - `language`: VARCHAR(5) (e.g., "en", "es", "ja").
    - `notifications`: JSONB (e.g., `{ "reminders": true, "tips": false }`).
  - `subscription`: JSONB (nullable)
    - `status`: VARCHAR(20) (e.g., "free", "premium").
    - `start_date`: TIMESTAMPTZ (nullable).
    - `end_date`: TIMESTAMPTZ (nullable).
- **Indexes:**
  - Primary key: `id`.
  - Unique index: `email`.
  - Index: `username` for search.
  - Index: `created_at` for sorting.
- **Row-Level Security (RLS):**
  - Enable RLS: Only authenticated users can read/write their own profile (`SELECT, INSERT, UPDATE WHERE auth.uid() = id`).
- **Notes:** Uses Supabase Auth for user management. JSONB for flexible fields like `social_links`. Supports PRD Section 5.1.6.

#### 5.3.2 Video Storage and Metadata (Table: `videos`, Supabase Storage)
- **Table:** `videos` (PostgreSQL)
- **Columns:**
  - `id`: UUID (primary key, auto-generated).
  - `user_id`: UUID (foreign key to `users.id`).
  - `video_url`: TEXT (URL in Supabase Storage, e.g., `https://<project>.supabase.co/storage/v1/object/videos/userId/videoId.mp4`).
  - `thumbnail_url`: TEXT (URL to thumbnail in Storage).
  - `upload_date`: TIMESTAMPTZ (default: now()).
  - `analysis_results`: JSONB
    - `landmarks`: Array of JSONB (40 data points)
      - `phase`: VARCHAR(20) (e.g., "load", "stride").
      - `landmark_data`: JSONB (e.g., `{ "hips": { "x": 0.5, "y": 0.3 } }`).
      - `alignment_score`: FLOAT (e.g., 85.5).
    - `recommendations`: Array of TEXT (e.g., ["+ Hips open", "Strengthen knee flexors"]).
  - `duration`: FLOAT (seconds, e.g., 5.2).
  - `status`: VARCHAR(20) (enum: "pending", "processed", "failed").
- **Storage Path (Supabase Storage):** `videos/{user_id}/{video_id}.mp4`
  - Videos: MP4, max 30 seconds (PRD Section 5.1.3).
  - Thumbnails: Auto-generated (e.g., first frame), stored as `thumbnails/{user_id}/{video_id}_thumb.jpg`.
- **Indexes:**
  - Foreign key: `user_id`.
  - Composite index: `user_id, upload_date` for video library queries.
- **RLS:**
  - Only authenticated users can read/write their videos (`SELECT, INSERT, UPDATE WHERE auth.uid() = user_id`).
- **Storage Policies:**
  - Users can only access their own videos (`bucket: videos, allowed: read, write if auth.uid() = user_id`).
- **Notes:** Supports PRD Sections 5.1.2 (Video Library), 5.1.3 (Upload), 5.1.4 (Comparison).

#### 5.3.3 Progress Tracking (Table: `progress_entries`)
- **Table:** `progress_entries` (PostgreSQL)
- **Columns:**
  - `id`: UUID (primary key, auto-generated).
  - `user_id`: UUID (foreign key to `users.id`).
  - `video_id`: UUID (foreign key to `videos.id`, nullable).
  - `timestamp`: TIMESTAMPTZ (default: now()).
  - `alignment_scores`: JSONB (e.g., `{ "load": 80.5, "stride": 75.0 }`).
  - `exercise_data`: JSONB (nullable)
    - `exercise_name`: VARCHAR(50) (e.g., "Single leg press").
    - `weight`: FLOAT (e.g., 90.0).
    - `date`: TIMESTAMPTZ.
  - `feedback`: TEXT (e.g., "More tee work on inside pitching").
- **Indexes:**
  - Foreign key: `user_id, video_id`.
  - Composite index: `user_id, timestamp` for timeline queries.
- **RLS:**
  - Only authenticated users can read/write their progress (`SELECT, INSERT, UPDATE WHERE auth.uid() = user_id`).
- **Notes:** Supports PRD Section 5.1.5 (Progress Tracker).

#### 5.3.4 Data Management
- **Retention Policy:** Videos archived after 90 days to cold storage (Supabase Edge Functions to automate).
- **Backup:** Supabase PostgreSQL backups (daily, stored in Supabase or exported to Vercel Blob).
- **Privacy:** Encrypt video files at rest (Supabase Storage default). Anonymize PostHog analytics for GDPR/CCPA compliance.

## 6. Non-Functional Requirements
- **Performance:** Video processing <10 seconds. App load time <2 seconds.
- **Security:** Encrypt user data/videos (Supabase Storage encryption). Supabase Auth for secure login. GDPR/CCPA compliance with privacy policy.
- **Accessibility:** WCAG 2.1 compliant (e.g., alt text for icons, VoiceOver for graphs).
- **Platforms:** iOS 15+. Portrait mode primary.
- **Scalability:** Supabase scales to 10K+ users. Vercel handles API requests.
- **Analytics:** PostHog for anonymous usage tracking (e.g., video uploads, screen views, errors).
- **Internationalization:** Support English, Spanish, Japanese, Korean, Mandarin (using iOS String Catalogs). RTL for applicable languages.
- **Beta Testing:** TestFlight for internal (developer, 1-2 testers) and external (up to 10,000) beta testing.
- **Offline Support:** Cache recent videos and profile data locally (using Core Data or SwiftData); sync when online.

## 7. Technical Requirements
- **Frontend:** Swift with SwiftUI for iOS development, using Cursor for code assistance.
- **Backend:** Supabase (PostgreSQL, Storage, Auth) for data and video storage. Vercel for hosting APIs (Node.js or Python) and Edge Functions for ML processing if needed.
- **Machine Learning:** Apple Vision for on-device pose detection (VNDetectHumanBodyPoseRequest). Core ML for custom models. Vercel-hosted API for off-device processing.
- **Data Sources:** MLB data (e.g., OpenBiomechanics Project, licensed if commercial). User videos in Supabase Storage.
- **Integrations:** iOS Camera API (AVFoundation), media library, push notifications (via Supabase Edge Functions), sharing (UIActivityViewController).
- **Analytics:** PostHog for event tracking (e.g., `video_uploaded`, `comparison_viewed`).
- **Version Control:** GitHub for code and CI/CD (e.g., GitHub Actions for automated builds/tests).
- **Testing:**
  - Unit/UI tests via XCTest/XCUITest in Xcode.
  - Beta testing via TestFlight, with feedback via in-app surveys or TestFlight’s mechanism.
  - Manual testing using Xcode Simulator and physical iOS devices.
- **Deployment:** Xcode for building/archiving; TestFlight for beta; Vercel for backend APIs; App Store Connect for submission.
- **AI Tools:** Cursor (Taskmaster AI) for code generation. Canva, Logo Diffusion, MidJourney for graphic assets.

## 8. Risks and Mitigations
- **Risk:** Inaccurate ML analysis. **Mitigation:** Validate with OpenBiomechanics data; refine via TestFlight feedback.
- **Risk:** Data privacy concerns. **Mitigation:** Opt-in sharing; clear privacy policy; verify in TestFlight.
- **Risk:** Multilingual content gaps. **Mitigation:** Use Supabase Edge Functions for translation APIs; test in TestFlight.
- **Risk:** TestFlight feedback delays submission. **Mitigation:** Set 2-4 week beta timeline; prioritize critical fixes.
- **Risk:** Solo developer bandwidth. **Mitigation:** Leverage Cursor for rapid coding; simplify non-core features (e.g., defer full Educational Resources).
- **Risk:** Supabase storage costs. **Mitigation:** Monitor usage in Supabase dashboard; archive old videos.

## 9. Timeline and Milestones (High-Level)
- **Phase 1 (1-2 months):** Design (UI/UX with AI tools), PRD refinement, MLB data sourcing.
- **Phase 2 (2-4 months):** Development (MVP: Splash, Home, Video Upload, Swing Comparison).
- **Phase 3 (1 month):** Testing/QA, including TestFlight beta (internal then external testers).
- **Phase 4:** App Store submission and iterations based on TestFlight feedback.

## 10. Appendices
### 10.1 Wireframe References
- As provided (screens 1-7: Splash, Home, Video Upload, Swing Comparison, Progress Tracker, Settings/Profile, Educational Resources).

### 10.2 Open Items
- Finalize logo/icons using AI tools (Canva, Logo Diffusion, MidJourney).
- Secure MLB data (e.g., OpenBiomechanics Project or KinaTrax license).
- Decide on monetization (e.g., freemium, subscriptions via In-App Purchases).
- Configure TestFlight, Supabase, PostHog, Vercel, and GitHub.

### 10.3 Missing Pieces and Recommendations
The following gaps were identified to enhance functionality, user experience, and development clarity:

1. **Onboarding Tutorial:**
   - **Gap:** No guided onboarding to teach users how to navigate or film swings correctly (PRD Section 5.2).
   - **Recommendation:** Add a tutorial screen after Splash (before Home) with 3-5 interactive slides (e.g., “How to film your swing,” “Understanding comparison stats”). Implement in SwiftUI using a `TabView` for swipeable pages. Store completion status in Supabase (`users.preferences.tutorial_completed`). Track tutorial views in PostHog.

2. **Error Handling and User Feedback:**
   - **Gap:** Limited mention of error handling for video uploads, analysis failures, or network issues (PRD Sections 5.1.3, 5.1.4).
   - **Recommendation:** Implement user-friendly error messages (e.g., “Upload failed: Please check your network”) using SwiftUI alerts. Log errors in PostHog (e.g., `error_upload_failed`) for debugging. Add a retry mechanism for uploads/processing. Store error logs in Supabase (`errors` table: `user_id`, `error_type`, `timestamp`).

3. **Offline Support:**
   - **Gap:** PRD mentions offline access for Educational Resources (Section 5.1.7) but not for other features like Video Library or Profile.
   - **Recommendation:** Cache recent videos (last 5) and profile data locally using SwiftData or Core Data. Sync with Supabase when online. Track offline usage in PostHog (e.g., `offline_video_viewed`). Display a banner (e.g., “Offline Mode: Limited features”) when disconnected.

4. **Analytics Events for PostHog:**
   - **Gap:** PRD lacks specific analytics events for tracking user behavior (Section 6).
   - **Recommendation:** Define PostHog events: `app_opened`, `video_uploaded`, `comparison_viewed`, `progress_graph_viewed`, `profile_updated`, `tutorial_completed`, `error_encountered`. Set up in Vercel-hosted API to send events to PostHog. Use PostHog dashboard to monitor engagement (e.g., upload frequency).

5. **Monetization Clarity:**
   - **Gap:** Monetization is an open item (Section 10.2) with no clear feature gating.
   - **Recommendation:** Define a freemium model: Free tier (5 video uploads/month, basic comparisons); Premium tier ($4.99/month via In-App Purchases) for unlimited uploads, advanced stats (e.g., per-phase scores), and exclusive educational videos. Store subscription status in Supabase (`users.subscription`). Track purchases in PostHog (`subscription_purchased`).

6. **Performance Optimization for ML:**
   - **Gap:** PRD assumes <10-second video processing (Section 6) but lacks fallback for slower devices.
   - **Recommendation:** Use Apple Vision on-device for iPhone 12+; fallback to Vercel-hosted API (using Python/TensorFlow) for older devices. Cache analysis results in Supabase to avoid reprocessing. Track processing time in PostHog (`analysis_duration`).