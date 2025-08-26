//
//  AuthSheetView.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import SwiftUI

struct AuthSheetView: View {
    let onAppleSignIn: () -> Void
    let onEmailSignIn: () -> Void
    let onSkip: () -> Void
    
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Theme.text.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, Theme.spacing12)
            
            VStack(spacing: Theme.spacing24) {
                // Header
                VStack(spacing: Theme.spacing8) {
                    Text("Save your progress")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundColor(Theme.text)
                    
                    Text("Create an account to save your personalized routine and preferences")
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.spacing16)
                }
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.5), value: showContent)
                
                // Auth options
                VStack(spacing: Theme.spacing16) {
                    // Sign in with Apple
                    Button(action: {
                        HapticFeedback.medium()
                        onAppleSignIn()
                    }) {
                        HStack(spacing: Theme.spacing12) {
                            Image(systemName: "applelogo")
                                .font(.system(size: 18, weight: .medium))
                            Text("Sign in with Apple")
                                .font(Theme.bodyFont)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
                    }
                    .buttonStyle(PressedButtonStyle())
                    
                    // Continue with email
                    Button(action: {
                        HapticFeedback.light()
                        onEmailSignIn()
                    }) {
                        HStack(spacing: Theme.spacing12) {
                            Image(systemName: "envelope")
                                .font(.system(size: 16, weight: .medium))
                            Text("Continue with email")
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
                .padding(.horizontal, Theme.spacing24)
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.5).delay(0.2), value: showContent)
                
                // Skip option
                Button(action: {
                    HapticFeedback.light()
                    onSkip()
                }) {
                    Text("Skip")
                        .font(Theme.bodyFont)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.text.opacity(0.6))
                }
                .padding(.top, Theme.spacing8)
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.5).delay(0.3), value: showContent)
                
                // Terms
                Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.text.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.spacing32)
                    .padding(.top, Theme.spacing16)
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 0.5).delay(0.4), value: showContent)
            }
            .padding(.top, Theme.spacing24)
            .padding(.bottom, Theme.spacing32)
        }
        .background(
            LinearGradient(
                colors: [
                    Theme.background,
                    Theme.background.opacity(0.98),
                    Theme.peach.opacity(0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear {
            showContent = true
        }
    }
}

struct AuthSheetView_Previews: PreviewProvider {
    static var previews: some View {
        AuthSheetView(
            onAppleSignIn: {},
            onEmailSignIn: {},
            onSkip: {}
        )
    }
}