//
//  AuthService.swift
//  MyContactPoint
//
//  Created by Taylor Larson on 9/25/25.
//

import Foundation
import Supabase
import SwiftUI

@MainActor
class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase: SupabaseClient
    
    init() {
        // Initialize Supabase client with environment configuration
        // For local development, use local Supabase URLs
        let supabaseURL = URL(string: ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "http://127.0.0.1:54321")!
        let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? "sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH"
        
        self.supabase = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
        
        // Check for existing session on initialization
        Task {
            await checkCurrentSession()
        }
    }
    
    // MARK: - Session Management
    
    func checkCurrentSession() async {
        do {
            let session = try await supabase.auth.session
            self.currentUser = session.user
            
            // Ensure user profile exists
            let profileExists = await createUserProfileIfNeeded(user: session.user)
            self.isAuthenticated = profileExists
        } catch {
            print("Error checking current session: \(error)")
            self.isAuthenticated = false
            self.currentUser = nil
        }
    }
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String, fullName: String?) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        print("📝 Starting sign-up for email: \(email)")
        
        do {
            let authResponse = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: fullName.map { ["full_name": .string($0)] }
            )
            
            print("✅ Supabase sign-up successful for user: \(authResponse.user.id)")
            self.currentUser = authResponse.user
            
            // Create user profile in our custom users table
            print("🔍 Creating user profile...")
            let profileCreated = await createUserProfileIfNeeded(user: authResponse.user, fullName: fullName)
            print("📊 Profile created: \(profileCreated)")
            
            // Only set authenticated if profile creation succeeded
            if profileCreated {
                self.isAuthenticated = true
                print("✅ User authenticated successfully")
            } else {
                print("❌ Profile creation failed, signing out user")
                // Profile creation failed, sign out the user
                try await supabase.auth.signOut()
                self.currentUser = nil
                self.isAuthenticated = false
                throw AuthError.profileCreationFailed
            }
        } catch {
            print("❌ Sign-up error: \(error)")
            // Handle specific Supabase auth errors
            if error.localizedDescription.contains("User already registered") {
                self.errorMessage = "An account with this email already exists. Please sign in instead."
                throw AuthError.userAlreadyExists
            } else {
                self.errorMessage = error.localizedDescription
                throw error
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        print("🔐 Starting sign-in for email: \(email)")
        
        do {
            let authResponse = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            print("✅ Supabase auth successful for user: \(authResponse.user.id)")
            self.currentUser = authResponse.user
            
            // Ensure user profile exists before setting authenticated
            print("🔍 Checking if user profile exists...")
            let profileExists = await createUserProfileIfNeeded(user: authResponse.user)
            print("📊 Profile exists: \(profileExists)")
            
            if profileExists {
                self.isAuthenticated = true
                print("✅ User authenticated successfully")
                // Update last login timestamp
                await updateLastLogin(userId: authResponse.user.id)
                print("✅ Last login updated")
            } else {
                print("❌ Profile creation failed, signing out user")
                // Profile creation failed, sign out the user
                try await supabase.auth.signOut()
                self.currentUser = nil
                self.isAuthenticated = false
                throw AuthError.profileCreationFailed
            }
        } catch {
            print("❌ Sign-in error: \(error)")
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func signOut() async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await supabase.auth.signOut()
            self.currentUser = nil
            self.isAuthenticated = false
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func resetPassword(email: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await supabase.auth.resetPasswordForEmail(email)
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - User Profile Management
    
    private func createUserProfileIfNeeded(user: User, fullName: String? = nil) async -> Bool {
        print("🔍 Checking if user profile exists for user: \(user.id)")
        do {
            // Check if user profile already exists
            let _ = try await supabase
                .from("users")
                .select("id")
                .eq("id", value: user.id)
                .single()
                .execute()
            
            // Profile already exists, no need to create
            print("✅ User profile already exists")
            return true
            
        } catch {
            // Profile doesn't exist, create it
            print("📝 User profile doesn't exist, creating new profile for user: \(user.id)")
            print("❌ Profile check error: \(error)")
            do {
                let userProfile = UserProfile(
                    id: user.id,
                    email: user.email ?? "",
                    fullName: fullName ?? (user.userMetadata["full_name"]?.stringValue),
                    createdAt: Date(),
                    updatedAt: Date(),
                    lastLogin: Date(),
                    subscriptionTier: .free,
                    subscriptionExpiresAt: nil,
                    isActive: true
                )
                
                print("📝 Creating user profile: \(userProfile.email)")
                try await supabase
                    .from("users")
                    .insert(userProfile)
                    .execute()
                print("✅ User profile created successfully")
                
                // Create default user preferences
                let userPreferences = UserPreferences(
                    id: UUID(),
                    userId: user.id,
                    tutorialCompleted: false,
                    languagePreference: "en",
                    analysisDepth: "basic",
                    notificationsEnabled: true,
                    privacyMode: false,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                
                print("📝 Creating user preferences...")
                try await supabase
                    .from("user_preferences")
                    .insert(userPreferences)
                    .execute()
                print("✅ User preferences created successfully")
                
                print("✅ Successfully created user profile and preferences for user: \(user.id)")
                return true
                
            } catch {
                print("Error creating user profile: \(error)")
                print("Error details: \(error.localizedDescription)")
                print("User ID: \(user.id)")
                print("User email: \(user.email ?? "nil")")
                self.errorMessage = "Failed to create user profile: \(error.localizedDescription)"
                return false
            }
        }
    }
    
    private func updateLastLogin(userId: UUID) async {
        do {
            try await supabase
                .from("users")
                .update(["last_login": Date().iso8601String])
                .eq("id", value: userId)
                .execute()
        } catch {
            print("Error updating last login: \(error)")
        }
    }
    
    // MARK: - Validation Methods
    
    func validateEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func validatePassword(_ password: String) -> (isValid: Bool, message: String?) {
        if password.count < 6 {
            return (false, "Password must be at least 6 characters long")
        }
        
        // Check for at least one letter and one number
        let hasLetter = password.rangeOfCharacter(from: .letters) != nil
        let hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
        
        if !hasLetter || !hasNumber {
            return (false, "Password must contain at least one letter and one number")
        }
        
        return (true, nil)
    }
    
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Data Models

struct UserProfile: Codable {
    let id: UUID
    let email: String
    let fullName: String?
    let createdAt: Date
    let updatedAt: Date
    let lastLogin: Date?
    let subscriptionTier: SubscriptionTier
    let subscriptionExpiresAt: Date?
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case lastLogin = "last_login"
        case subscriptionTier = "subscription_tier"
        case subscriptionExpiresAt = "subscription_expires_at"
        case isActive = "is_active"
    }
}

struct UserPreferences: Codable {
    let id: UUID
    let userId: UUID
    let tutorialCompleted: Bool
    let languagePreference: String
    let analysisDepth: String
    let notificationsEnabled: Bool
    let privacyMode: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case tutorialCompleted = "tutorial_completed"
        case languagePreference = "language_preference"
        case analysisDepth = "analysis_depth"
        case notificationsEnabled = "notifications_enabled"
        case privacyMode = "privacy_mode"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum SubscriptionTier: String, Codable, CaseIterable {
    case free = "free"
    case premium = "premium"
}

// MARK: - Error Types

enum AuthError: LocalizedError {
    case profileCreationFailed
    case userCreationFailed
    case userAlreadyExists
    
    var errorDescription: String? {
        switch self {
        case .profileCreationFailed:
            return "Failed to create user profile. Please try again."
        case .userCreationFailed:
            return "Failed to create user account. Please try again."
        case .userAlreadyExists:
            return "An account with this email already exists. Please sign in instead."
        }
    }
}

// MARK: - Extensions

extension Date {
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}
