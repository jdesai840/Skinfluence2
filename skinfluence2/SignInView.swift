//
//  SignInView.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import SwiftUI

struct SignInView: View {
    let onSignIn: () -> Void
    let onCreateAccount: () -> Void
    let onGuest: () -> Void
    let onSkip: () -> Void
    
    @State private var email = ""
    @State private var password = ""
    @State private var showContent = false
    @State private var showAuthSheet = false
    @State private var sparkleOffset1: CGSize = .zero
    @State private var sparkleOffset2: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Theme.background,
                        Theme.background.opacity(0.95),
                        Theme.peach.opacity(0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Floating sparkles
                sparkleBackground(geometry: geometry)
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Skip button
                        HStack {
                            Spacer()
                            Button("Skip") {
                                HapticFeedback.light()
                                onSkip()
                            }
                            .font(Theme.bodyFont)
                            .foregroundColor(Theme.text.opacity(0.6))
                            .padding(.trailing, Theme.spacing20)
                            .padding(.top, Theme.spacing16)
                        }
                        
                        // Main content
                        VStack(spacing: Theme.spacing32) {
                            Spacer(minLength: Theme.spacing32)
                            
                            // Header
                            VStack(spacing: Theme.spacing20) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 50, weight: .light))
                                    .foregroundColor(Theme.primary)
                                    .scaleEffect(showContent ? 1.0 : 0.8)
                                    .opacity(showContent ? 1.0 : 0.0)
                                
                                VStack(spacing: Theme.spacing8) {
                                    Text("Welcome back")
                                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                                        .foregroundColor(Theme.text)
                                    
                                    Text("Sign in to continue your skincare journey")
                                        .font(Theme.bodyFont)
                                        .foregroundColor(Theme.text.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                }
                                .scaleEffect(showContent ? 1.0 : 0.9)
                                .opacity(showContent ? 1.0 : 0.0)
                            }
                            .animation(.easeOut(duration: 0.8), value: showContent)
                            
                            // Form
                            VStack(spacing: Theme.spacing20) {
                                // Email field
                                VStack(alignment: .leading, spacing: Theme.spacing8) {
                                    Text("Email")
                                        .font(Theme.bodyFont)
                                        .fontWeight(.medium)
                                        .foregroundColor(Theme.text)
                                    
                                    TextField("Enter your email", text: $email)
                                        .textFieldStyle(CustomTextFieldStyle())
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                }
                                
                                // Password field
                                VStack(alignment: .leading, spacing: Theme.spacing8) {
                                    Text("Password")
                                        .font(Theme.bodyFont)
                                        .fontWeight(.medium)
                                        .foregroundColor(Theme.text)
                                    
                                    SecureField("Enter your password", text: $password)
                                        .textFieldStyle(CustomTextFieldStyle())
                                }
                                
                                // Forgot password
                                HStack {
                                    Spacer()
                                    Button("Forgot password?") {
                                        // Handle forgot password
                                    }
                                    .font(Theme.captionFont)
                                    .fontWeight(.medium)
                                    .foregroundColor(Theme.primary)
                                }
                            }
                            .padding(.horizontal, Theme.spacing32)
                            .opacity(showContent ? 1.0 : 0.0)
                            .animation(.easeIn(duration: 0.6).delay(0.3), value: showContent)
                            
                            // Sign in button
                            Button(action: {
                                HapticFeedback.medium()
                                onSignIn()
                            }) {
                                HStack {
                                    Text("Sign In")
                                        .font(Theme.headlineFont)
                                        .fontWeight(.semibold)
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [Theme.primary, Theme.secondary],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
                                .shadow(
                                    color: Theme.primary.opacity(0.3),
                                    radius: 12,
                                    x: 0,
                                    y: 6
                                )
                            }
                            .padding(.horizontal, Theme.spacing32)
                            .buttonStyle(PressedButtonStyle())
                            .opacity(showContent ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 0.6).delay(0.5), value: showContent)
                            
                            // Divider
                            HStack {
                                Rectangle()
                                    .fill(Theme.text.opacity(0.2))
                                    .frame(height: 1)
                                Text("or")
                                    .font(Theme.captionFont)
                                    .foregroundColor(Theme.text.opacity(0.6))
                                Rectangle()
                                    .fill(Theme.text.opacity(0.2))
                                    .frame(height: 1)
                            }
                            .padding(.horizontal, Theme.spacing32)
                            .opacity(showContent ? 1.0 : 0.0)
                            .animation(.easeIn(duration: 0.4).delay(0.7), value: showContent)
                            
                            // Social sign in buttons
                            VStack(spacing: Theme.spacing16) {
                                // Apple Sign In
                                Button(action: {
                                    HapticFeedback.light()
                                    onSignIn()
                                }) {
                                    HStack {
                                        Image(systemName: "applelogo")
                                            .font(.system(size: 18, weight: .medium))
                                        Text("Continue with Apple")
                                            .font(Theme.bodyFont)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(Theme.text)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                                            .stroke(Theme.text.opacity(0.2), lineWidth: 1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
                                }
                                .buttonStyle(PressedButtonStyle())
                                
                                // Google Sign In
                                Button(action: {
                                    HapticFeedback.light()
                                    onSignIn()
                                }) {
                                    HStack {
                                        Image(systemName: "globe")
                                            .font(.system(size: 18, weight: .medium))
                                        Text("Continue with Google")
                                            .font(Theme.bodyFont)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(Theme.text)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                                            .stroke(Theme.text.opacity(0.2), lineWidth: 1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
                                }
                                .buttonStyle(PressedButtonStyle())
                            }
                            .padding(.horizontal, Theme.spacing32)
                            .opacity(showContent ? 1.0 : 0.0)
                            .animation(.easeIn(duration: 0.4).delay(0.8), value: showContent)
                            
                            // Guest mode and create account
                            VStack(spacing: Theme.spacing16) {
                                // Continue as guest
                                Button(action: {
                                    HapticFeedback.light()
                                    showAuthSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "person.circle")
                                            .font(.system(size: 16, weight: .medium))
                                        Text("Continue as guest")
                                            .font(Theme.bodyFont)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(Theme.primary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Theme.primary.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
                                }
                                .buttonStyle(PressedButtonStyle())
                                
                                // Create account
                                Button(action: {
                                    HapticFeedback.light()
                                    onCreateAccount()
                                }) {
                                    HStack {
                                        Text("Don't have an account?")
                                            .font(Theme.bodyFont)
                                            .foregroundColor(Theme.text.opacity(0.7))
                                        Text("Create one")
                                            .font(Theme.bodyFont)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Theme.primary)
                                    }
                                }
                            }
                            .padding(.horizontal, Theme.spacing32)
                            .opacity(showContent ? 1.0 : 0.0)
                            .animation(.easeIn(duration: 0.4).delay(0.9), value: showContent)
                            
                            Spacer(minLength: Theme.spacing32)
                        }
                    }
                }
            }
        }
        .onAppear {
            showContent = true
            startSparkleAnimation()
        }
        .sheet(isPresented: $showAuthSheet) {
            AuthSheetView(
                onAppleSignIn: {
                    showAuthSheet = false
                    onSignIn()
                },
                onEmailSignIn: {
                    showAuthSheet = false
                    onSignIn()
                },
                onSkip: {
                    showAuthSheet = false
                    onGuest()
                }
            )
            .presentationDetents([.height(400)])
            .presentationDragIndicator(.hidden)
        }
    }
    
    private func sparkleBackground(geometry: GeometryProxy) -> some View {
        ZStack {
            // Sparkle 1
            Image(systemName: "sparkles")
                .font(.system(size: 16, weight: .light))
                .foregroundColor(Theme.primary.opacity(0.2))
                .position(x: geometry.size.width * 0.85 + sparkleOffset1.width,
                         y: geometry.size.height * 0.2 + sparkleOffset1.height)
            
            // Sparkle 2
            Image(systemName: "sparkles")
                .font(.system(size: 12, weight: .light))
                .foregroundColor(Theme.secondary.opacity(0.3))
                .position(x: geometry.size.width * 0.15 + sparkleOffset2.width,
                         y: geometry.size.height * 0.6 + sparkleOffset2.height)
        }
    }
    
    private func startSparkleAnimation() {
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            sparkleOffset1 = CGSize(width: -20, height: 30)
        }
        
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true).delay(0.5)) {
            sparkleOffset2 = CGSize(width: 25, height: -20)
        }
    }
}

// Custom text field style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(Theme.spacing16)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                    .stroke(Theme.text.opacity(0.2), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
            .font(Theme.bodyFont)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(
            onSignIn: {},
            onCreateAccount: {},
            onGuest: {},
            onSkip: {}
        )
    }
}