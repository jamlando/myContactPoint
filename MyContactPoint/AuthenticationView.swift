//
//  AuthenticationView.swift
//  MyContactPoint
//
//  Created by Taylor Larson on 9/25/25.
//

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

struct AuthenticationView: View {
    @EnvironmentObject var authService: FirebaseAuthService
    @Binding var isSignUpMode: Bool
    @Binding var showAuthentication: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Back Button
                HStack {
                    Button(action: {
                        showAuthentication = false
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            Text("Back to Tutorial")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding(.horizontal, 32)
                .padding(.top, 20)
                
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
                        .onChange(of: fullName) { _ in
                            authService.clearError()
                        }
                    }
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocorrectionDisabled()
                        .onChange(of: email) { _ in
                            authService.clearError()
                        }
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(isSignUpMode ? .newPassword : .password)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .submitLabel(.done)
                        .onChange(of: password) { _ in
                            authService.clearError()
                        }
                    
                    if isSignUpMode {
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.newPassword)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .submitLabel(.done)
                            .onChange(of: confirmPassword) { _ in
                                authService.clearError()
                            }
                    }
                    
                    // Error Message
                    if let errorMessage = authService.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Action Button
                    Button(action: {
                        print("🔘 Button action called!")
                        os_log("🔘 Button action called!", log: .default, type: .info)
                        handleAuthentication()
                    }) {
                        HStack {
                            if authService.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text(isSignUpMode ? "Sign Up" : "Sign In")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(authService.isLoading ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(authService.isLoading || !isFormValid)
                    .onChange(of: authService.isLoading) { isLoading in
                        print("🔄 isLoading changed: \(isLoading)")
                        os_log("🔄 isLoading changed: %{public}@", log: .default, type: .info, String(isLoading))
                    }
                    .onChange(of: isFormValid) { isValid in
                        print("✅ isFormValid changed: \(isValid)")
                        os_log("✅ isFormValid changed: %{public}@", log: .default, type: .info, String(isValid))
                    }
                    .onChange(of: authService.isAuthenticated) { isAuthenticated in
                        print("🔐 AuthenticationView: isAuthenticated changed: \(isAuthenticated)")
                        os_log("🔐 AuthenticationView: isAuthenticated changed: %{public}@", log: .default, type: .info, String(isAuthenticated))
                        if isAuthenticated {
                            print("✅ AuthenticationView: User authenticated, closing authentication view")
                            os_log("✅ AuthenticationView: User authenticated, closing authentication view", log: .default, type: .info)
                            showAuthentication = false
                        }
                    }
                    .onAppear {
                        print("🔘 Button appeared - isLoading: \(authService.isLoading), isFormValid: \(isFormValid)")
                        print("🔘 Button disabled: \(authService.isLoading || !isFormValid)")
                        os_log("🔘 Button appeared - isLoading: %{public}@, isFormValid: %{public}@", log: .default, type: .info, String(authService.isLoading), String(isFormValid))
                    }
                    
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
            .onAppear {
                authService.clearError()
            }
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
        let emailEmpty = email.isEmpty
        let passwordEmpty = password.isEmpty
        let emailValid = authService.validateEmail(email)
        
        print("🔍 Form validation - Email empty: \(emailEmpty), Password empty: \(passwordEmpty), Email valid: \(emailValid)")
        
        guard !emailEmpty && !passwordEmpty else { 
            print("❌ Form invalid: Email or password empty")
            return false 
        }
        guard emailValid else { 
            print("❌ Form invalid: Email format invalid")
            return false 
        }
        
        if isSignUpMode {
            let fullNameEmpty = fullName.isEmpty
            let confirmPasswordEmpty = confirmPassword.isEmpty
            let passwordMatch = password == confirmPassword
            let passwordValidation = authService.validatePassword(password)
            
            print("📝 Sign-up validation - Full name empty: \(fullNameEmpty), Confirm password empty: \(confirmPasswordEmpty), Password match: \(passwordMatch), Password valid: \(passwordValidation.isValid)")
            
            guard !fullNameEmpty && !confirmPasswordEmpty else { 
                print("❌ Sign-up invalid: Full name or confirm password empty")
                return false 
            }
            guard passwordMatch else { 
                print("❌ Sign-up invalid: Passwords don't match")
                return false 
            }
            guard passwordValidation.isValid else { 
                print("❌ Sign-up invalid: Password validation failed")
                return false 
            }
        }
        
        print("✅ Form is valid")
        return true
    }
    
    // MARK: - Actions
    
    private func handleAuthentication() {
        print("🔘 handleAuthentication called - isSignUpMode: \(isSignUpMode)")
        os_log("🔘 handleAuthentication called - isSignUpMode: %{public}@", log: .default, type: .info, String(isSignUpMode))
        print("📧 Email: \(email.maskedEmail)")
        print("🔒 Password length: \(password.count)")
        print("🔄 isLoading: \(authService.isLoading)")
        print("✅ isFormValid: \(isFormValid)")
        
        // Clear any previous errors
        authService.clearError()
        
        Task {
            do {
                if isSignUpMode {
                    print("📝 Starting sign-up process...")
                    os_log("📝 Starting sign-up process...", log: .default, type: .info)
                    try await authService.signUp(
                        email: email,
                        password: password,
                        fullName: fullName.isEmpty ? nil : fullName
                    )
                } else {
                    print("🔐 Starting sign-in process...")
                    os_log("🔐 Starting sign-in process...", log: .default, type: .info)
                    try await authService.signIn(
                        email: email,
                        password: password
                    )
                }
                print("✅ Authentication completed successfully")
                os_log("✅ Authentication completed successfully", log: .default, type: .info)
            } catch {
                // Error is handled by AuthService and displayed in UI
                print("❌ Authentication error: \(error)")
                os_log("❌ Authentication error: %{public}@", log: .default, type: .error, error.localizedDescription)
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
                print("Password reset error: \(error.localizedDescription)")
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
        AuthenticationView(isSignUpMode: .constant(false), showAuthentication: .constant(true))
            .environmentObject(FirebaseAuthService())
    }
}
