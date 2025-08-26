//
//  SignInView.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var toastManager: ToastManager
    @State private var showEmailSignIn = false
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Theme.spacing32) {
                    Spacer(minLength: 60)
                    
                    // Header
                    VStack(spacing: Theme.spacing16) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 50, weight: .light))
                            .foregroundColor(Theme.primary)
                        
                        Text("Welcome to Skinfluence")
                            .font(Theme.titleFont)
                            .foregroundColor(Theme.text)
                            .multilineTextAlignment(.center)
                        
                        Text("Get personalized skincare routines inspired by trusted creators, safe for your skin and budget.")
                            .font(Theme.bodyFont)
                            .foregroundColor(Theme.text.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Theme.spacing20)
                    }
                    
                    Spacer(minLength: Theme.spacing32)
                    
                    // Sign In Options
                    VStack(spacing: Theme.spacing16) {
                        // Apple Sign In
                        SignInWithAppleButton(
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: handleAppleSignInResult
                        )
                        .frame(height: 50)
                        .cornerRadius(Theme.cornerRadiusLarge)
                        
                        // Email Sign In Toggle
                        Button(action: {
                            withAnimation(.easeInOut) {
                                showEmailSignIn.toggle()
                            }
                        }) {
                            Text(showEmailSignIn ? "Hide Email Sign In" : "Continue with Email")
                        }
                        .tertiaryStyle()
                        
                        if showEmailSignIn {
                            emailSignInSection
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }
                    }
                    .padding(.horizontal, Theme.spacing20)
                    
                    Spacer(minLength: Theme.spacing32)
                    
                    // Legal
                    VStack(spacing: Theme.spacing8) {
                        Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.text.opacity(0.6))
                            .multilineTextAlignment(.center)
                        
                        Text("This app is not a medical device and does not provide medical advice")
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.text.opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, Theme.spacing20)
                }
            }
            
            if authService.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                    
                    Text("Signing you in...")
                        .foregroundColor(.white)
                        .font(Theme.bodyFont)
                        .padding(.top)
                }
            }
        }
    }
    
    private var emailSignInSection: some View {
        VStack(spacing: Theme.spacing16) {
            VStack(spacing: Theme.spacing12) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(isSignUp ? .newPassword : .password)
            }
            
            HStack(spacing: Theme.spacing12) {
                Button(action: signInWithEmail) {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                }
                .primaryStyle()
                .disabled(email.isEmpty || password.isEmpty)
                
                Button(action: signUpWithEmail) {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                }
                .secondaryStyle()
                .disabled(email.isEmpty || password.isEmpty)
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(Theme.cornerRadiusMedium)
    }
    
    // MARK: - Actions
    private func handleAppleSignInResult(_ result: Result<ASAuthorization, Error>) {
        Task {
            do {
                try await authService.signInWithApple()
                toastManager.show(text: "Welcome to Skinfluence!", style: .success)
            } catch {
                toastManager.show(text: error.localizedDescription, style: .error)
            }
        }
    }
    
    private func signInWithEmail() {
        Task {
            do {
                try await authService.signInWithEmail(email, password: password)
                toastManager.show(text: "Welcome back!", style: .success)
            } catch {
                toastManager.show(text: error.localizedDescription, style: .error)
            }
        }
    }
    
    private func signUpWithEmail() {
        Task {
            do {
                try await authService.signUpWithEmail(email, password: password)
                toastManager.show(text: "Account created! Welcome to Skinfluence!", style: .success)
            } catch {
                toastManager.show(text: error.localizedDescription, style: .error)
            }
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthService.shared)
        .environmentObject(ToastManager())
}