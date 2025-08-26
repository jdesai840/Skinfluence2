//
//  ConsentsView.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import SwiftUI

struct ConsentsView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var toastManager: ToastManager
    @State private var privacyConsent = false
    @State private var imageProcessingConsent = false
    @State private var marketingConsent = false
    
    private var canContinue: Bool {
        privacyConsent && imageProcessingConsent
    }
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Theme.spacing24) {
                    // Progress indicator
                    ProgressView(value: 0.2)
                        .progressViewStyle(LinearProgressViewStyle(tint: Theme.primary))
                        .padding(.horizontal)
                    
                    // Header
                    VStack(spacing: Theme.spacing16) {
                        Image(systemName: "hand.raised")
                            .font(.system(size: 50, weight: .light))
                            .foregroundColor(Theme.primary)
                        
                        Text("Privacy & Permissions")
                            .font(Theme.titleFont)
                            .foregroundColor(Theme.text)
                            .multilineTextAlignment(.center)
                        
                        Text("We believe in transparency. Here's what we need your permission for:")
                            .font(Theme.bodyFont)
                            .foregroundColor(Theme.text.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Theme.spacing20)
                    }
                    
                    // Consent Items
                    VStack(spacing: Theme.spacing16) {
                        ConsentCard(
                            title: "Privacy Policy",
                            description: "Agree to our privacy policy and terms of service. We keep your data secure and never sell it.",
                            iconName: "shield.checkered",
                            isRequired: true,
                            isChecked: $privacyConsent,
                            linkText: "Read Privacy Policy",
                            action: {
                                // TODO: Open privacy policy in web view
                                print("Open Privacy Policy")
                            }
                        )
                        
                        ConsentCard(
                            title: "Image Processing",
                            description: "Allow us to analyze your facial photos to provide personalized skincare recommendations. Photos are processed securely and deleted after analysis.",
                            iconName: "camera.viewfinder",
                            isRequired: true,
                            isChecked: $imageProcessingConsent,
                            linkText: "Learn More",
                            action: {
                                // TODO: Open image processing details
                                print("Open Image Processing Details")
                            }
                        )
                        
                        ConsentCard(
                            title: "Marketing Communications",
                            description: "Receive helpful skincare tips, product updates, and special offers. You can opt out anytime.",
                            iconName: "envelope",
                            isRequired: false,
                            isChecked: $marketingConsent,
                            linkText: nil,
                            action: nil
                        )
                    }
                    .padding(.horizontal)
                    
                    // Important Notice
                    Card {
                        VStack(alignment: .leading, spacing: Theme.spacing12) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                                Text("Important Notice")
                                    .font(Theme.headlineFont)
                                    .foregroundColor(Theme.text)
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: Theme.spacing8) {
                                Text("• This app is not a medical device")
                                Text("• We do not diagnose or treat skin conditions")
                                Text("• Always consult a dermatologist for medical concerns")
                                Text("• Recommendations are for cosmetic purposes only")
                            }
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.text.opacity(0.8))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Continue Button
                    Button(action: saveConsents) {
                        Text("I Agree & Continue")
                            .frame(maxWidth: .infinity)
                    }
                    .primaryStyle()
                    .disabled(!canContinue)
                    .opacity(canContinue ? 1.0 : 0.5)
                    .padding(.horizontal)
                    .padding(.bottom, Theme.spacing32)
                }
            }
        }
    }
    
    private func saveConsents() {
        guard canContinue else { return }
        
        HapticFeedback.success()
        
        // Update user consents
        if var user = authService.currentUser {
            user.consents = UserConsents(
                privacyPolicy: privacyConsent,
                imageProcessing: imageProcessingConsent,
                marketing: marketingConsent
            )
            authService.updateUser(user)
        }
        
        toastManager.show(text: "Consents saved successfully!", style: .success)
        AnalyticsService.shared.track(AnalyticsEvents.consentGiven, properties: [
            "privacy_policy": privacyConsent,
            "image_processing": imageProcessingConsent,
            "marketing": marketingConsent
        ])
        
        NotificationCenter.default.post(name: .onboardingStepCompleted, object: nil)
    }
}

struct ConsentCard: View {
    let title: String
    let description: String
    let iconName: String
    let isRequired: Bool
    @Binding var isChecked: Bool
    let linkText: String?
    let action: (() -> Void)?
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: Theme.spacing12) {
                HStack(alignment: .top) {
                    Image(systemName: iconName)
                        .font(.title2)
                        .foregroundColor(Theme.primary)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: Theme.spacing8) {
                        HStack {
                            Text(title)
                                .font(Theme.headlineFont)
                                .foregroundColor(Theme.text)
                            
                            if isRequired {
                                Text("Required")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Theme.primary.opacity(0.2))
                                    .foregroundColor(Theme.primary)
                                    .cornerRadius(4)
                            }
                            
                            Spacer()
                        }
                        
                        Text(description)
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.text.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                HStack {
                    if let linkText = linkText, let action = action {
                        Button(action: action) {
                            Text(linkText)
                                .font(Theme.captionFont)
                                .foregroundColor(Theme.primary)
                                .underline()
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        isChecked.toggle()
                        HapticFeedback.light()
                    }) {
                        HStack(spacing: Theme.spacing8) {
                            Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                                .font(.title2)
                                .foregroundColor(isChecked ? Theme.primary : Theme.text.opacity(0.4))
                            
                            Text(isChecked ? "Agreed" : "Agree")
                                .font(Theme.bodyFont)
                                .foregroundColor(isChecked ? Theme.primary : Theme.text)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ConsentsView()
        .environmentObject(AuthService.shared)
        .environmentObject(ToastManager())
}