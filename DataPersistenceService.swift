//
//  DataPersistenceService.swift
//  MyContactPoint
//
//  Created by Taylor Larson on 9/19/25.
//

import Foundation

class DataPersistenceService {
    static let shared = DataPersistenceService()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Tutorial Completion
    var tutorialCompleted: Bool {
        get {
            userDefaults.bool(forKey: "tutorial_completed")
        }
        set {
            userDefaults.set(newValue, forKey: "tutorial_completed")
        }
    }
    
    // MARK: - User Preferences
    var userLanguage: String {
        get {
            userDefaults.string(forKey: "user_language") ?? "en"
        }
        set {
            userDefaults.set(newValue, forKey: "user_language")
        }
    }
    
    var notificationsEnabled: Bool {
        get {
            userDefaults.bool(forKey: "notifications_enabled")
        }
        set {
            userDefaults.set(newValue, forKey: "notifications_enabled")
        }
    }
    
    // MARK: - App State
    var isFirstLaunch: Bool {
        get {
            !userDefaults.bool(forKey: "has_launched_before")
        }
        set {
            userDefaults.set(!newValue, forKey: "has_launched_before")
        }
    }
    
    // MARK: - Supabase Configuration
    var supabaseURL: String? {
        get {
            userDefaults.string(forKey: "supabase_url")
        }
        set {
            userDefaults.set(newValue, forKey: "supabase_url")
        }
    }
    
    var supabaseKey: String? {
        get {
            userDefaults.string(forKey: "supabase_key")
        }
        set {
            userDefaults.set(newValue, forKey: "supabase_key")
        }
    }
    
    // MARK: - PostHog Configuration
    var posthogKey: String? {
        get {
            userDefaults.string(forKey: "posthog_key")
        }
        set {
            userDefaults.set(newValue, forKey: "posthog_key")
        }
    }
    
    var posthogHost: String? {
        get {
            userDefaults.string(forKey: "posthog_host")
        }
        set {
            userDefaults.set(newValue, forKey: "posthog_host")
        }
    }
}
