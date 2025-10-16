//
//  Config.swift
//  MyContactPoint
//
//  Created by Security Audit on 1/16/25.
//

import Foundation

/// Secure configuration management for My Contact Point
/// All sensitive configuration values are loaded from environment variables
/// with secure fallbacks for development
struct Config {
    
    // MARK: - Supabase Configuration
    
    /// Supabase project URL - loaded from environment variable
    static var supabaseURL: String {
        guard let url = ProcessInfo.processInfo.environment["SUPABASE_URL"] else {
            #if DEBUG
            // Development fallback - local Supabase instance
            return "http://127.0.0.1:54321"
            #else
            fatalError("SUPABASE_URL environment variable is required for production builds")
            #endif
        }
        return url
    }
    
    /// Supabase anonymous key - loaded from environment variable
    static var supabaseAnonKey: String {
        guard let key = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] else {
            #if DEBUG
            // Development fallback - local Supabase instance
            return "LOCAL_DEV_KEY_PLACEHOLDER"
            #else
            fatalError("SUPABASE_ANON_KEY environment variable is required for production builds")
            #endif
        }
        return key
    }
    
    // MARK: - PostHog Configuration
    
    /// PostHog API key - loaded from environment variable
    static var posthogKey: String? {
        return ProcessInfo.processInfo.environment["POSTHOG_API_KEY"]
    }
    
    /// PostHog host URL - loaded from environment variable
    static var posthogHost: String {
        return ProcessInfo.processInfo.environment["POSTHOG_HOST"] ?? "https://us.i.posthog.com"
    }
    
    // MARK: - App Configuration
    
    /// App version for analytics and debugging
    static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    /// Build number for analytics and debugging
    static var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    /// Bundle identifier
    static var bundleIdentifier: String {
        return Bundle.main.bundleIdentifier ?? "com.taylorlarson.mycontactpoint.app"
    }
    
    // MARK: - Security Configuration
    
    /// Maximum video file size in bytes (50MB)
    static var maxVideoFileSize: Int64 {
        return 50 * 1024 * 1024 // 50MB
    }
    
    /// Maximum video duration in seconds (30 seconds)
    static var maxVideoDuration: TimeInterval {
        return 30.0
    }
    
    /// Allowed video formats
    static var allowedVideoFormats: [String] {
        return ["mp4", "mov", "m4v"]
    }
    
    // MARK: - Environment Detection
    
    /// Returns true if running in debug mode
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    /// Returns true if running in production
    static var isProduction: Bool {
        return !isDebug
    }
    
    /// Returns true if running in simulator
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    // MARK: - Validation
    
    /// Validates that all required configuration is present
    static func validateConfiguration() -> Bool {
        // In production, ensure all required environment variables are set
        if isProduction {
            let requiredVars = ["SUPABASE_URL", "SUPABASE_ANON_KEY"]
            for varName in requiredVars {
                if ProcessInfo.processInfo.environment[varName] == nil {
                    print("❌ Missing required environment variable: \(varName)")
                    return false
                }
            }
        }
        return true
    }
    
    /// Logs configuration status (without sensitive data)
    static func logConfigurationStatus() {
        print("🔧 Configuration Status:")
        print("   Environment: \(isDebug ? "DEBUG" : "PRODUCTION")")
        print("   Supabase URL: \(supabaseURL)")
        print("   Supabase Key: \(supabaseAnonKey.prefix(20))...")
        print("   PostHog Key: \(posthogKey != nil ? "SET" : "NOT SET")")
        print("   PostHog Host: \(posthogHost)")
        print("   App Version: \(appVersion) (\(buildNumber))")
        print("   Bundle ID: \(bundleIdentifier)")
        print("   Simulator: \(isSimulator)")
    }
}
