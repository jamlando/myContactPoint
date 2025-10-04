# Production Supabase Setup Guide

## Critical Issue: TestFlight Authentication Failure

**Problem**: "Could not connect to the server" error during signup in TestFlight
**Root Cause**: App is configured to use localhost Supabase URLs (`http://127.0.0.1:54321`) instead of production Supabase URLs
**Solution**: Create production Supabase project and configure app with production credentials

## Step 1: Create Production Supabase Project

### 1.1 Sign Up/Login to Supabase
1. Go to [supabase.com](https://supabase.com)
2. Sign up or login to your account
3. Click "New Project"

### 1.2 Create New Project
1. **Organization**: Select your organization (or create one)
2. **Project Name**: `my-contact-point-production`
3. **Database Password**: Generate a strong password (save it securely!)
4. **Region**: Choose closest to your users (e.g., US East, US West, EU West)
5. **Pricing Plan**: Start with Free tier (can upgrade later)

### 1.3 Wait for Project Setup
- Project creation takes 2-3 minutes
- You'll receive an email when ready

## Step 2: Get Production Credentials

### 2.1 Access Project Settings
1. Go to your project dashboard
2. Click "Settings" in the left sidebar
3. Click "API" tab

### 2.2 Copy Credentials
1. **Project URL**: Copy the URL (format: `https://your-project-ref.supabase.co`)
2. **anon public key**: Copy the "anon public" key (starts with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`)

**Example**:
```
Project URL: https://abcdefghijklmnop.supabase.co
anon public key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoaWprbG1ub3AiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTY5ODc2ODAwMCwiZXhwIjoyMDE0MzQ0MDAwfQ.example-key-here
```

## Step 3: Configure Database Schema

### 3.1 Run Database Migrations
1. Go to "SQL Editor" in your Supabase dashboard
2. Run the following migrations:

```sql
-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create users table
CREATE TABLE users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE,
    subscription_tier TEXT DEFAULT 'free' CHECK (subscription_tier IN ('free', 'premium')),
    subscription_expires_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true
);

-- Create user_preferences table
CREATE TABLE user_preferences (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    tutorial_completed BOOLEAN DEFAULT false,
    language_preference TEXT DEFAULT 'en',
    analysis_depth TEXT DEFAULT 'basic',
    notifications_enabled BOOLEAN DEFAULT true,
    privacy_mode BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create swing_videos table
CREATE TABLE swing_videos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    file_size BIGINT,
    duration_seconds DECIMAL(10,2),
    resolution_width INTEGER,
    resolution_height INTEGER,
    fps DECIMAL(5,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE swing_videos ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view own data" ON users
    FOR ALL USING (auth.uid() = id);

CREATE POLICY "Users can manage own preferences" ON user_preferences
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own videos" ON swing_videos
    FOR ALL USING (auth.uid() = user_id);
```

### 3.2 Create Storage Bucket
1. Go to "Storage" in your Supabase dashboard
2. Click "Create Bucket"
3. **Bucket Name**: `swing-videos`
4. **Public**: No (private bucket)
5. **File Size Limit**: 100MB
6. **Allowed MIME Types**: `video/*`

## Step 4: Update App Configuration

### 4.1 Update AuthService.swift
Replace the placeholder URLs in `AuthService.swift` with your actual production credentials:

```swift
init() {
    // Initialize Supabase client with environment configuration
    // For production builds, use production Supabase URLs
    let supabaseURL = URL(string: ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "https://YOUR-PROJECT-REF.supabase.co")!
    let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? "YOUR-PRODUCTION-ANON-KEY"
    
    self.supabase = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    
    // Check for existing session on initialization
    Task {
        await checkCurrentSession()
    }
}
```

### 4.2 Update VideoUploadService.swift
Replace the placeholder URLs in `VideoUploadService.swift` with your actual production credentials:

```swift
init() {
    // Initialize Supabase client with environment configuration
    // For production builds, use production Supabase URLs
    let supabaseURL = URL(string: ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "https://YOUR-PROJECT-REF.supabase.co")!
    let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? "YOUR-PRODUCTION-ANON-KEY"
    
    self.supabase = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
}
```

## Step 5: Configure Environment Variables (Optional)

### 5.1 For Xcode Build Settings
1. Open your Xcode project
2. Select your target
3. Go to "Build Settings"
4. Add these User-Defined settings:
   - `SUPABASE_URL`: `https://YOUR-PROJECT-REF.supabase.co`
   - `SUPABASE_ANON_KEY`: `YOUR-PRODUCTION-ANON-KEY`

### 5.2 For CI/CD (Future)
When setting up GitHub Actions or Xcode Cloud:
- Add these as environment variables in your CI/CD configuration
- Never commit production keys to your repository

## Step 6: Test the Configuration

### 6.1 Build and Test Locally
1. Update the code with your production credentials
2. Build the project in Xcode
3. Test signup/signin functionality
4. Verify video upload works

### 6.2 Create New TestFlight Build
1. Archive the project in Xcode
2. Upload to App Store Connect
3. Create new TestFlight build
4. Test authentication in TestFlight

## Step 7: Security Considerations

### 7.1 API Key Security
- The `anon` key is safe to use in client-side applications
- It only allows operations permitted by your RLS policies
- Never expose your `service_role` key in client applications

### 7.2 RLS Policies
- All tables have Row Level Security enabled
- Users can only access their own data
- Policies prevent unauthorized access

### 7.3 HTTPS Only
- Production Supabase URLs use HTTPS
- All communications are encrypted
- Complies with Apple's App Transport Security requirements

## Troubleshooting

### Common Issues:
1. **"Invalid API key"**: Check that you copied the correct `anon public` key
2. **"Project not found"**: Verify the Project URL is correct
3. **"RLS policy violation"**: Ensure RLS policies are properly configured
4. **"Storage bucket not found"**: Create the `swing-videos` bucket in Storage

### Testing Checklist:
- [ ] Production Supabase project created
- [ ] Database schema migrated
- [ ] Storage bucket created
- [ ] App updated with production credentials
- [ ] Local testing successful
- [ ] TestFlight build created
- [ ] Authentication works in TestFlight

## Next Steps

After completing this setup:
1. Test authentication thoroughly in TestFlight
2. Monitor Supabase dashboard for any errors
3. Set up monitoring and alerts
4. Consider upgrading to Pro plan for production features
5. Implement proper error handling and user feedback

---

**Important**: Keep your production credentials secure and never commit them to version control. Use environment variables or secure configuration management for production deployments.
