//
//  FirebaseAuthService.swift
//  MyContactPoint
//
//  Created by Taylor Larson on 10/16/25.
//

import Foundation
// import FirebaseAuth
// import FirebaseCore
import SwiftUI
import os.log

// MARK: - Security Extensions

extension String {
    /// Masks email addresses for secure logging
    var maskedEmail: String {
        guard self.contains("@") else { return "***" }
        let components = self.components(separatedBy: "@")
        guard components.count == 2 else { return "***" }
        
        let username = components[0]
        let domain = components[1]
        
        // Mask username: show first 2 chars, mask the rest
        let maskedUsername = username.count > 2 ? 
            String(username.prefix(2)) + String(repeating: "*", count: username.count - 2) : 
            String(repeating: "*", count: username.count)
        
        return "\(maskedUsername)@\(domain)"
    }
}

// MARK: - Mock Firebase Types for Development
struct MockUser {
    let uid: String
    let email: String?
    let displayName: String?
}

enum MockAuthErrorCode: Int, CaseIterable {
    case emailAlreadyInUse = 1
    case weakPassword = 2
    case invalidEmail = 3
    case userNotFound = 4
    case wrongPassword = 5
    case userDisabled = 6
    
    var localizedDescription: String {
        switch self {
        case .emailAlreadyInUse:
            return "The email address is already in use by another account."
        case .weakPassword:
            return "The password must be 6 characters long or more."
        case .invalidEmail:
            return "The email address is badly formatted."
        case .userNotFound:
            return "There is no user record corresponding to this identifier."
        case .wrongPassword:
            return "The password is invalid or the user does not have a password."
        case .userDisabled:
            return "The user account has been disabled by an administrator."
        }
    }
}

struct MockAuthError: Error {
    let code: MockAuthErrorCode
    var localizedDescription: String { code.localizedDescription }
}

class MockAuth {
    static let auth = MockAuth()
    private init() {}
    
    var currentUser: MockUser? = nil
    
    func createUser(withEmail email: String, password: String) async throws -> MockUser {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        let normalizedEmail = email.lowercased()
        print("🔍 MockAuth.createUser called with email: \(email.maskedEmail) -> normalized: \(normalizedEmail.maskedEmail)")
        os_log("🔍 MockAuth.createUser called with email: %{public}@ -> normalized: %{public}@", log: .default, type: .info, email.maskedEmail, normalizedEmail.maskedEmail)
        
        // Mock validation - taylor.larson5@gmail.com already exists (case-insensitive)
        if normalizedEmail == "taylor.larson5@gmail.com" {
            print("❌ MockAuth.createUser: Email already in use - throwing emailAlreadyInUse error")
            os_log("❌ MockAuth.createUser: Email already in use - throwing emailAlreadyInUse error", log: .default, type: .error)
            throw MockAuthError(code: .emailAlreadyInUse)
        }
        
        let user = MockUser(uid: UUID().uuidString, email: email, displayName: nil)
        currentUser = user
        return user
    }
    
    func signIn(withEmail email: String, password: String) async throws -> MockUser {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        let normalizedEmail = email.lowercased()
        print("🔍 MockAuth.signIn called with email: \(email.maskedEmail) -> normalized: \(normalizedEmail.maskedEmail), password length: \(password.count)")
        os_log("🔍 MockAuth.signIn called with email: %{public}@ -> normalized: %{public}@, password length: %{public}@", log: .default, type: .info, email.maskedEmail, normalizedEmail.maskedEmail, String(password.count))
        
        // Mock validation - Allow sign-in for taylor.larson5@gmail.com (case-insensitive)
        if normalizedEmail == "taylor.larson5@gmail.com" && password == "password123" {
            print("✅ MockAuth.signIn: Successful sign-in for \(normalizedEmail.maskedEmail)")
            os_log("✅ MockAuth.signIn: Successful sign-in for %{public}@", log: .default, type: .info, normalizedEmail.maskedEmail)
            let user = MockUser(uid: "mock-user-taylor", email: email, displayName: "Taylor Larson")
            currentUser = user
            return user
        } else if normalizedEmail == "test@example.com" && password == "testpassword123" {
            let user = MockUser(uid: "mock-user-test", email: email, displayName: "Test User")
            currentUser = user
            return user
        } else if normalizedEmail == "taylor.larson5@gmail.com" {
            // Wrong password for taylor.larson5@gmail.com
            print("❌ MockAuth.signIn: Wrong password for \(normalizedEmail.maskedEmail) - throwing wrongPassword error")
            os_log("❌ MockAuth.signIn: Wrong password for %{public}@ - throwing wrongPassword error", log: .default, type: .error, normalizedEmail.maskedEmail)
            throw MockAuthError(code: .wrongPassword)
        } else {
            // User not found
            print("❌ MockAuth.signIn: User not found for email: \(normalizedEmail.maskedEmail) - throwing userNotFound error")
            os_log("❌ MockAuth.signIn: User not found for email: %{public}@ - throwing userNotFound error", log: .default, type: .error, normalizedEmail.maskedEmail)
            throw MockAuthError(code: .userNotFound)
        }
    }
    
    func signOut() throws {
        currentUser = nil
    }
    
    func sendPasswordReset(withEmail email: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        print("Mock password reset email sent to: \(email)")
    }
    
    func addStateDidChangeListener(_ listener: @escaping (MockAuth, MockUser?) -> Void) {
        // Mock listener - in real Firebase this would be called when auth state changes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            listener(self, self.currentUser)
        }
    }
}

// MARK: - FirebaseAuthService Implementation
@MainActor
class FirebaseAuthService: ObservableObject {
    @Published var isAuthenticated = false {
        didSet {
            print("🔄 FirebaseAuthService: isAuthenticated changed from \(oldValue) to \(isAuthenticated)")
            os_log("🔄 FirebaseAuthService: isAuthenticated changed from %{public}@ to %{public}@", log: .default, type: .info, String(oldValue), String(isAuthenticated))
        }
    }
    @Published var currentUser: MockUser?
    @Published var isLoading = false {
        didSet {
            print("🔄 FirebaseAuthService: isLoading changed from \(oldValue) to \(isLoading)")
            os_log("🔄 FirebaseAuthService: isLoading changed from %{public}@ to %{public}@", log: .default, type: .info, String(oldValue), String(isLoading))
        }
    }
    @Published var errorMessage: String?
    
    init() {
        // Set up auth state listener
        MockAuth.auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isAuthenticated = user != nil
                print("🔥 Mock Firebase Auth state changed - User: \(user?.email ?? "nil"), Authenticated: \(user != nil)")
                os_log("🔥 Mock Firebase Auth state changed - User: %{public}@, Authenticated: %{public}@", log: .default, type: .info, user?.email ?? "nil", String(user != nil))
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String, fullName: String?) async throws {
        isLoading = true
        errorMessage = nil
        
        print("📝 Starting Mock Firebase sign-up for email: \(email.maskedEmail)")
        os_log("📝 Starting Mock Firebase sign-up for email: %{public}@", log: .default, type: .info, email.maskedEmail)
        
        defer {
            isLoading = false
            print("🔄 Mock Firebase sign-up loading state reset to false")
            os_log("🔄 Mock Firebase sign-up loading state reset to false", log: .default, type: .info)
        }
        
        do {
            let user = try await MockAuth.auth.createUser(withEmail: email, password: password)
            print("✅ Mock Firebase sign-up successful for user: \(user.uid)")
            os_log("✅ Mock Firebase sign-up successful for user: %{public}@", log: .default, type: .info, user.uid)
            
            self.currentUser = user
            self.isAuthenticated = true
            
        } catch {
            print("❌ Mock Firebase sign-up error: \(error)")
            os_log("❌ Mock Firebase sign-up error: %{public}@", log: .default, type: .error, error.localizedDescription)
            
            // Handle specific Firebase auth errors
            if let authError = error as? MockAuthError {
                switch authError.code {
                case .emailAlreadyInUse:
                    self.errorMessage = "An account with this email already exists. Please sign in instead."
                case .weakPassword:
                    self.errorMessage = "Password is too weak. Please choose a stronger password."
                case .invalidEmail:
                    self.errorMessage = "Please enter a valid email address."
                default:
                    self.errorMessage = authError.localizedDescription
                }
            } else {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        print("🔐 Starting Mock Firebase sign-in for email: \(email.maskedEmail)")
        os_log("🔐 Starting Mock Firebase sign-in for email: %{public}@", log: .default, type: .info, email.maskedEmail)
        
        defer {
            isLoading = false
            print("🔄 Mock Firebase sign-in loading state reset to false")
            os_log("🔄 Mock Firebase sign-in loading state reset to false", log: .default, type: .info)
        }
        
        do {
            let user = try await MockAuth.auth.signIn(withEmail: email, password: password)
            print("✅ Mock Firebase sign-in successful for user: \(user.uid)")
            os_log("✅ Mock Firebase sign-in successful for user: %{public}@", log: .default, type: .info, user.uid)
            
            self.currentUser = user
            self.isAuthenticated = true
            
        } catch {
            print("❌ Mock Firebase sign-in error: \(error)")
            os_log("❌ Mock Firebase sign-in error: %{public}@", log: .default, type: .error, error.localizedDescription)
            
            // Handle specific Firebase auth errors
            if let authError = error as? MockAuthError {
                switch authError.code {
                case .userNotFound:
                    self.errorMessage = "No account found with this email address."
                case .wrongPassword:
                    self.errorMessage = "Incorrect password. Please try again."
                case .invalidEmail:
                    self.errorMessage = "Please enter a valid email address."
                case .userDisabled:
                    self.errorMessage = "This account has been disabled."
                default:
                    self.errorMessage = authError.localizedDescription
                }
            } else {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func signOut() async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try MockAuth.auth.signOut()
            self.currentUser = nil
            self.isAuthenticated = false
            print("✅ Mock Firebase sign-out successful")
            os_log("✅ Mock Firebase sign-out successful", log: .default, type: .info)
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
            try await MockAuth.auth.sendPasswordReset(withEmail: email)
            print("✅ Mock Firebase password reset email sent to: \(email.maskedEmail)")
            os_log("✅ Mock Firebase password reset email sent to: %{public}@", log: .default, type: .info, email.maskedEmail)
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
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

// MARK: - Extensions

extension FirebaseAuthService {
    var userDisplayName: String {
        return currentUser?.displayName ?? currentUser?.email ?? "Player"
    }
    
    var userEmail: String? {
        return currentUser?.email
    }
}
