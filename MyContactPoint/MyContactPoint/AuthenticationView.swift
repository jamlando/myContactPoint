//
//  AuthenticationView.swift
//  MyContactPoint
//
//  Created by Taylor Larson on 9/25/25.
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authService: AuthService
    @State private var isSignUpMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Logo and Title
                VStack(spacing: 16) {
                    Image(systemName: "baseball.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("My Contact Point")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Improve your swing with MLB-level analysis")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Authentication Form
                VStack(spacing: 16) {
                    if isSignUpMode {
                        TextField("Full Name", text: $fullName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocorrectionDisabled()
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if isSignUpMode {
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Error Message
                    if let errorMessage = authService.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Action Button
                    Button(action: handleAuthentication) {
                        HStack {
                            if authService.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Text(isSignUpMode ? "Sign Up" : "Sign In")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(authService.isLoading || !isFormValid)
                    
                    // Toggle Mode Button
                    Button(action: {
                        isSignUpMode.toggle()
                        authService.clearError()
                        clearForm()
                    }) {
                        Text(isSignUpMode ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .foregroundColor(.blue)
                    }
                    
                    // Forgot Password
                    if !isSignUpMode {
                        Button("Forgot Password?") {
                            handleForgotPassword()
                        }
                        .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Password Reset"),
                    message: Text("If an account with that email exists, you'll receive a password reset link."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        guard !email.isEmpty && !password.isEmpty else { return false }
        guard authService.validateEmail(email) else { return false }
        
        if isSignUpMode {
            guard !fullName.isEmpty && !confirmPassword.isEmpty else { return false }
            guard password == confirmPassword else { return false }
            let passwordValidation = authService.validatePassword(password)
            return passwordValidation.isValid
        }
        
        return true
    }
    
    // MARK: - Actions
    
    private func handleAuthentication() {
        Task {
            do {
                if isSignUpMode {
                    try await authService.signUp(
                        email: email,
                        password: password,
                        fullName: fullName.isEmpty ? nil : fullName
                    )
                } else {
                    try await authService.signIn(
                        email: email,
                        password: password
                    )
                }
            } catch {
                // Error is handled by AuthService and displayed in UI
                print("Authentication error: \(error)")
            }
        }
    }
    
    private func handleForgotPassword() {
        guard !email.isEmpty && authService.validateEmail(email) else {
            authService.errorMessage = "Please enter a valid email address"
            return
        }
        
        Task {
            do {
                try await authService.resetPassword(email: email)
                showingAlert = true
            } catch {
                print("Password reset error: \(error)")
            }
        }
    }
    
    private func clearForm() {
        email = ""
        password = ""
        fullName = ""
        confirmPassword = ""
    }
}

// MARK: - Preview

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(AuthService())
    }
}
