-- Supabase Storage Configuration
-- Storage buckets and policies for My Contact Point app
-- Created: 2025-09-25

-- Create storage buckets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
    ('swing-videos', 'swing-videos', false, 104857600, ARRAY['video/mp4', 'video/mov', 'video/avi', 'video/quicktime']), -- 100MB limit
    ('user-avatars', 'user-avatars', false, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']), -- 5MB limit
    ('analysis-thumbnails', 'analysis-thumbnails', true, 2097152, ARRAY['image/jpeg', 'image/png', 'image/webp']); -- 2MB limit, public

-- Storage policies for swing-videos bucket
CREATE POLICY "Users can upload their own swing videos" ON storage.objects
FOR INSERT WITH CHECK (
    bucket_id = 'swing-videos' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can view their own swing videos" ON storage.objects
FOR SELECT USING (
    bucket_id = 'swing-videos' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can update their own swing videos" ON storage.objects
FOR UPDATE USING (
    bucket_id = 'swing-videos' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can delete their own swing videos" ON storage.objects
FOR DELETE USING (
    bucket_id = 'swing-videos' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Storage policies for user-avatars bucket
CREATE POLICY "Users can upload their own avatars" ON storage.objects
FOR INSERT WITH CHECK (
    bucket_id = 'user-avatars' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can view their own avatars" ON storage.objects
FOR SELECT USING (
    bucket_id = 'user-avatars' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can update their own avatars" ON storage.objects
FOR UPDATE USING (
    bucket_id = 'user-avatars' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can delete their own avatars" ON storage.objects
FOR DELETE USING (
    bucket_id = 'user-avatars' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Storage policies for analysis-thumbnails bucket (public read)
CREATE POLICY "Anyone can view analysis thumbnails" ON storage.objects
FOR SELECT USING (bucket_id = 'analysis-thumbnails');

CREATE POLICY "Authenticated users can upload analysis thumbnails" ON storage.objects
FOR INSERT WITH CHECK (
    bucket_id = 'analysis-thumbnails' 
    AND auth.role() = 'authenticated'
);

CREATE POLICY "Users can update their own analysis thumbnails" ON storage.objects
FOR UPDATE USING (
    bucket_id = 'analysis-thumbnails' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can delete their own analysis thumbnails" ON storage.objects
FOR DELETE USING (
    bucket_id = 'analysis-thumbnails' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Create storage functions for file management
CREATE OR REPLACE FUNCTION get_user_storage_usage(user_uuid UUID)
RETURNS TABLE (
    bucket_name TEXT,
    total_files BIGINT,
    total_size BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.name as bucket_name,
        COUNT(o.id) as total_files,
        COALESCE(SUM(o.metadata->>'size')::BIGINT, 0) as total_size
    FROM storage.buckets b
    LEFT JOIN storage.objects o ON b.id = o.bucket_id 
        AND o.name LIKE user_uuid::text || '/%'
    WHERE b.name IN ('swing-videos', 'user-avatars', 'analysis-thumbnails')
    GROUP BY b.name
    ORDER BY b.name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to clean up orphaned files
CREATE OR REPLACE FUNCTION cleanup_orphaned_storage_files()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER := 0;
    temp_count INTEGER;
BEGIN
    -- Delete swing videos that don't have corresponding database records
    DELETE FROM storage.objects 
    WHERE bucket_id = 'swing-videos'
    AND NOT EXISTS (
        SELECT 1 FROM public.swing_videos 
        WHERE file_path = name
    );
    
    GET DIAGNOSTICS temp_count = ROW_COUNT;
    deleted_count := deleted_count + temp_count;
    
    -- Delete user avatars for deleted users
    DELETE FROM storage.objects 
    WHERE bucket_id = 'user-avatars'
    AND NOT EXISTS (
        SELECT 1 FROM public.users 
        WHERE id::text = (storage.foldername(name))[1]
    );
    
    GET DIAGNOSTICS temp_count = ROW_COUNT;
    deleted_count := deleted_count + temp_count;
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to generate signed URLs for video access
CREATE OR REPLACE FUNCTION generate_video_signed_url(
    video_path TEXT,
    expires_in INTEGER DEFAULT 3600
)
RETURNS TEXT AS $$
DECLARE
    signed_url TEXT;
BEGIN
    -- This would typically call Supabase's storage API
    -- For now, return a placeholder that would be handled by the client
    RETURN 'https://storage-url-placeholder/' || video_path || '?expires=' || expires_in;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create storage usage view for admin monitoring
CREATE OR REPLACE VIEW storage_usage_summary AS
SELECT 
    b.name as bucket_name,
    COUNT(o.id) as total_files,
    COALESCE(SUM((o.metadata->>'size')::BIGINT), 0) as total_size_bytes,
    COALESCE(SUM((o.metadata->>'size')::BIGINT), 0) / 1024 / 1024 as total_size_mb,
    COUNT(DISTINCT (storage.foldername(o.name))[1]) as unique_users
FROM storage.buckets b
LEFT JOIN storage.objects o ON b.id = o.bucket_id
WHERE b.name IN ('swing-videos', 'user-avatars', 'analysis-thumbnails')
GROUP BY b.name
ORDER BY b.name;

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION get_user_storage_usage(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION cleanup_orphaned_storage_files() TO service_role;
GRANT EXECUTE ON FUNCTION generate_video_signed_url(TEXT, INTEGER) TO authenticated;
GRANT SELECT ON storage_usage_summary TO service_role;

-- Create indexes for storage performance
CREATE INDEX IF NOT EXISTS idx_storage_objects_bucket_id ON storage.objects(bucket_id);
CREATE INDEX IF NOT EXISTS idx_storage_objects_name ON storage.objects(name);
CREATE INDEX IF NOT EXISTS idx_storage_objects_created_at ON storage.objects(created_at);

-- Insert storage configuration metadata
INSERT INTO public.storage_configuration (
    bucket_name,
    max_file_size,
    allowed_mime_types,
    is_public,
    description
) VALUES 
    ('swing-videos', 104857600, ARRAY['video/mp4', 'video/mov', 'video/avi', 'video/quicktime'], false, 'User uploaded swing analysis videos'),
    ('user-avatars', 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp'], false, 'User profile pictures'),
    ('analysis-thumbnails', 2097152, ARRAY['image/jpeg', 'image/png', 'image/webp'], true, 'Public thumbnails for swing analysis results');

-- Create storage_configuration table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.storage_configuration (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    bucket_name TEXT UNIQUE NOT NULL,
    max_file_size BIGINT NOT NULL,
    allowed_mime_types TEXT[] NOT NULL,
    is_public BOOLEAN DEFAULT false,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on storage_configuration
ALTER TABLE public.storage_configuration ENABLE ROW LEVEL SECURITY;

-- Allow public read access to storage configuration
CREATE POLICY "Anyone can read storage configuration" ON public.storage_configuration 
FOR SELECT USING (true);
