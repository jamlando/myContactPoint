-- My Contact Point Database Schema
-- Initial migration for baseball hitting mechanics analysis app
-- Created: 2025-09-25

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create custom types
CREATE TYPE swing_phase AS ENUM ('stance', 'load', 'stride', 'contact', 'follow_through');
CREATE TYPE body_landmark AS ENUM ('head', 'left_shoulder', 'right_shoulder', 'left_hip', 'right_hip', 'left_knee', 'right_knee', 'left_ankle', 'right_ankle', 'left_wrist', 'right_wrist', 'left_elbow', 'right_elbow');
CREATE TYPE analysis_status AS ENUM ('uploaded', 'processing', 'analyzed', 'error');
CREATE TYPE subscription_tier AS ENUM ('free', 'premium');

-- Users table (extends Supabase auth.users)
CREATE TABLE public.users (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE,
    subscription_tier subscription_tier DEFAULT 'free',
    subscription_expires_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true
);

-- User preferences table
CREATE TABLE public.user_preferences (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    tutorial_completed BOOLEAN DEFAULT false,
    language_preference TEXT DEFAULT 'en',
    analysis_depth TEXT DEFAULT 'basic', -- 'basic', 'detailed', 'expert'
    notifications_enabled BOOLEAN DEFAULT true,
    privacy_mode BOOLEAN DEFAULT false, -- Hide personal data in analytics
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Swing videos table
CREATE TABLE public.swing_videos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    filename TEXT NOT NULL,
    file_path TEXT NOT NULL, -- Supabase Storage path
    file_size BIGINT,
    duration_seconds DECIMAL(5,2),
    resolution TEXT, -- e.g., '1920x1080'
    fps INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb -- Additional video metadata
);

-- Swing analyses table (40 data points: 8 landmarks × 5 phases)
CREATE TABLE public.swing_analyses (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    video_id UUID REFERENCES public.swing_videos(id) ON DELETE CASCADE NOT NULL,
    analysis_status analysis_status DEFAULT 'uploaded',
    processing_started_at TIMESTAMP WITH TIME ZONE,
    processing_completed_at TIMESTAMP WITH TIME ZONE,
    processing_error TEXT,
    
    -- Pose detection results (40 data points)
    pose_data JSONB NOT NULL DEFAULT '{}'::jsonb, -- Structured pose data
    
    -- Analysis results
    overall_score DECIMAL(5,2), -- 0-100 overall swing score
    phase_scores JSONB DEFAULT '{}'::jsonb, -- Scores for each phase
    
    -- Comparison with MLB averages
    mlb_comparison JSONB DEFAULT '{}'::jsonb, -- Comparison data
    
    -- Recommendations
    improvement_areas TEXT[], -- Array of improvement suggestions
    drill_recommendations TEXT[], -- Array of recommended drills
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- MLB comparison data table (reference data)
CREATE TABLE public.mlb_comparison_data (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    landmark body_landmark NOT NULL,
    phase swing_phase NOT NULL,
    average_x DECIMAL(10,6), -- Average X coordinate
    average_y DECIMAL(10,6), -- Average Y coordinate
    standard_deviation_x DECIMAL(10,6),
    standard_deviation_y DECIMAL(10,6),
    sample_size INTEGER,
    data_source TEXT, -- 'OpenBiomechanics', 'KinaTrax', etc.
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(landmark, phase)
);

-- User progress tracking table
CREATE TABLE public.user_progress (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    analysis_id UUID REFERENCES public.swing_analyses(id) ON DELETE CASCADE NOT NULL,
    improvement_score DECIMAL(5,2), -- Improvement from previous analysis
    phase_improvements JSONB DEFAULT '{}'::jsonb, -- Improvements per phase
    goals_achieved TEXT[], -- Array of achieved goals
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Educational resources table
CREATE TABLE public.educational_resources (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    resource_type TEXT NOT NULL, -- 'article', 'video', 'drill', 'tip'
    phase_focus swing_phase[], -- Which phases this resource addresses
    difficulty_level TEXT DEFAULT 'beginner', -- 'beginner', 'intermediate', 'advanced'
    is_premium BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Drill recommendations table
CREATE TABLE public.drill_recommendations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    analysis_id UUID REFERENCES public.swing_analyses(id) ON DELETE CASCADE NOT NULL,
    drill_name TEXT NOT NULL,
    description TEXT NOT NULL,
    phase_focus swing_phase NOT NULL,
    difficulty_level TEXT DEFAULT 'beginner',
    estimated_duration_minutes INTEGER,
    equipment_needed TEXT[],
    instructions TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Session analytics table (PostHog integration)
CREATE TABLE public.session_analytics (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    session_id TEXT NOT NULL,
    event_name TEXT NOT NULL,
    event_properties JSONB DEFAULT '{}'::jsonb,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Strength training progress table (integration with external apps)
CREATE TABLE public.strength_training_progress (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    exercise_name TEXT NOT NULL,
    weight_lifted DECIMAL(8,2),
    reps INTEGER,
    sets INTEGER,
    workout_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_subscription ON public.users(subscription_tier, subscription_expires_at);
CREATE INDEX idx_swing_videos_user_id ON public.swing_videos(user_id);
CREATE INDEX idx_swing_videos_created_at ON public.swing_videos(created_at);
CREATE INDEX idx_swing_analyses_user_id ON public.swing_analyses(user_id);
CREATE INDEX idx_swing_analyses_video_id ON public.swing_analyses(video_id);
CREATE INDEX idx_swing_analyses_status ON public.swing_analyses(analysis_status);
CREATE INDEX idx_user_progress_user_id ON public.user_progress(user_id);
CREATE INDEX idx_session_analytics_user_id ON public.session_analytics(user_id);
CREATE INDEX idx_session_analytics_timestamp ON public.session_analytics(timestamp);
CREATE INDEX idx_mlb_comparison_landmark_phase ON public.mlb_comparison_data(landmark, phase);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON public.user_preferences FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_swing_videos_updated_at BEFORE UPDATE ON public.swing_videos FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_swing_analyses_updated_at BEFORE UPDATE ON public.swing_analyses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_mlb_comparison_data_updated_at BEFORE UPDATE ON public.mlb_comparison_data FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_educational_resources_updated_at BEFORE UPDATE ON public.educational_resources FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS) Policies
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.swing_videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.swing_analyses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.drill_recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.session_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strength_training_progress ENABLE ROW LEVEL SECURITY;

-- Users can only access their own data
CREATE POLICY "Users can view own profile" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.users FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can manage own preferences" ON public.user_preferences FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own videos" ON public.swing_videos FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own analyses" ON public.swing_analyses FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own progress" ON public.user_progress FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own drill recommendations" ON public.drill_recommendations FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own analytics" ON public.session_analytics FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own strength training" ON public.strength_training_progress FOR ALL USING (auth.uid() = user_id);

-- Public read access for reference data
CREATE POLICY "Anyone can read MLB comparison data" ON public.mlb_comparison_data FOR SELECT USING (true);
CREATE POLICY "Anyone can read educational resources" ON public.educational_resources FOR SELECT USING (true);

-- Insert sample MLB comparison data
INSERT INTO public.mlb_comparison_data (landmark, phase, average_x, average_y, standard_deviation_x, standard_deviation_y, sample_size, data_source) VALUES
-- Stance phase data (sample values)
('head', 'stance', 0.5, 0.8, 0.05, 0.03, 1000, 'OpenBiomechanics'),
('left_shoulder', 'stance', 0.3, 0.7, 0.04, 0.02, 1000, 'OpenBiomechanics'),
('right_shoulder', 'stance', 0.7, 0.7, 0.04, 0.02, 1000, 'OpenBiomechanics'),
('left_hip', 'stance', 0.4, 0.5, 0.03, 0.02, 1000, 'OpenBiomechanics'),
('right_hip', 'stance', 0.6, 0.5, 0.03, 0.02, 1000, 'OpenBiomechanics'),
('left_knee', 'stance', 0.4, 0.3, 0.02, 0.02, 1000, 'OpenBiomechanics'),
('right_knee', 'stance', 0.6, 0.3, 0.02, 0.02, 1000, 'OpenBiomechanics'),
('left_ankle', 'stance', 0.4, 0.1, 0.02, 0.01, 1000, 'OpenBiomechanics'),
('right_ankle', 'stance', 0.6, 0.1, 0.02, 0.01, 1000, 'OpenBiomechanics'),
('left_wrist', 'stance', 0.2, 0.6, 0.03, 0.02, 1000, 'OpenBiomechanics'),
('right_wrist', 'stance', 0.8, 0.6, 0.03, 0.02, 1000, 'OpenBiomechanics'),
('left_elbow', 'stance', 0.25, 0.65, 0.03, 0.02, 1000, 'OpenBiomechanics'),
('right_elbow', 'stance', 0.75, 0.65, 0.03, 0.02, 1000, 'OpenBiomechanics');

-- Insert sample educational resources
INSERT INTO public.educational_resources (title, content, resource_type, phase_focus, difficulty_level, is_premium) VALUES
('Proper Stance Fundamentals', 'Learn the fundamentals of a proper batting stance including foot placement, weight distribution, and body alignment.', 'article', ARRAY['stance']::swing_phase[], 'beginner', false),
('Load Phase Mechanics', 'Understanding how to properly load your weight and prepare for the swing during the load phase.', 'article', ARRAY['load']::swing_phase[], 'intermediate', false),
('Contact Point Optimization', 'Master the art of making contact at the optimal point for maximum power and accuracy.', 'article', ARRAY['contact']::swing_phase[], 'advanced', true),
('Follow-Through Techniques', 'Complete your swing with proper follow-through mechanics for consistent results.', 'article', ARRAY['follow_through']::swing_phase[], 'intermediate', false);
