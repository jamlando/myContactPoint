-- Fix foreign key constraint issue in users table
-- The constraint was too strict and causing issues during user creation

-- Drop the existing foreign key constraint
ALTER TABLE public.users DROP CONSTRAINT IF EXISTS users_id_fkey;

-- Recreate the foreign key constraint with DEFERRABLE INITIALLY DEFERRED
-- This allows the constraint to be checked at the end of the transaction
-- rather than immediately, which helps with timing issues during user creation
ALTER TABLE public.users 
ADD CONSTRAINT users_id_fkey 
FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE 
DEFERRABLE INITIALLY DEFERRED;
