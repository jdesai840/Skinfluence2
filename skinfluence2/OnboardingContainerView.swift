//
//  OnboardingContainerView.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import SwiftUI
import AVFoundation
import UserNotifications

enum SkinGoal: String, CaseIterable {
    case clearBreakouts = "Clear breakouts" 
    case fadeDarkSpots = "Fade dark spots"
    case calmRedness = "Calm redness"
    case smoothTexture = "Smooth texture"
    case glowBrighten = "Glow/brighten"
    case antiAging = "Anti-aging"
    
    var icon: String {
        switch self {
        case .clearBreakouts: return "✨"
        case .fadeDarkSpots: return "🌙"
        case .calmRedness: return "🌸"
        case .smoothTexture: return "🪶"
        case .glowBrighten: return "☀️"
        case .antiAging: return "⏰"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .clearBreakouts: return .green.opacity(0.7)
        case .fadeDarkSpots: return .purple.opacity(0.7)
        case .calmRedness: return .pink.opacity(0.7)
        case .smoothTexture: return Theme.peach.opacity(0.7)
        case .glowBrighten: return .yellow.opacity(0.7)
        case .antiAging: return Color(.systemPurple).opacity(0.7)
        }
    }
}

struct OnboardingContainerView: View {
    let onComplete: () -> Void
    
    @State private var currentStep: OnboardingStep = .ageGate
    @State private var showContent = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Theme.background,
                        Theme.background.opacity(0.95),
                        Theme.peach.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    // Progress indicator
                    progressIndicator
                        .padding(.top, Theme.spacing20)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.easeIn(duration: 0.4), value: showContent)
                    
                    // Step content
                    stepContent
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.6), value: showContent)
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            showContent = true
        }
    }
    
    private var progressIndicator: some View {
        HStack(spacing: Theme.spacing8) {
            ForEach(OnboardingStep.allCases.dropLast(), id: \.self) { step in
                Circle()
                    .fill(stepIndex(step) <= currentStepIndex ? Theme.primary : Theme.text.opacity(0.2))
                    .frame(width: 8, height: 8)
                    .scaleEffect(step == currentStep ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
        .padding(.horizontal, Theme.spacing32)
    }
    
    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case .ageGate:
            AgeGateStepView(onNext: goToNextStep)
        case .consents:
            ConsentsStepView(onNext: goToNextStep)
        case .retailers:
            GoalPickerView(onNext: goToNextStep)
        case .skinType:
            SkinTypeView(onNext: goToNextStep)
        case .skinConcerns:
            SkinConcernsView(onNext: goToNextStep)
        case .safetyFilters:
            SafetyFiltersView(onNext: goToNextStep)
        case .budget:
            BudgetEffortView(onNext: goToNextStep)
        case .activesComfort:
            ActivesComfortView(onNext: goToNextStep)
        case .scanGuide:
            ScanGuideStepView(onNext: goToNextStep)
        case .scanCapture:
            ScanCaptureStepView(onNext: goToNextStep)
        case .scanReview:
            ScanReviewStepView(onNext: goToNextStep)
        case .questionnaire:
            QuestionnaireStepView(onNext: goToNextStep)
        case .notificationsPrePrompt:
            NotificationsPrePromptView(onNext: goToNextStep)
        case .creatorCode:
            CreatorCodeView(onNext: goToNextStep)
        case .generateReady:
            GenerateReadyView(onNext: goToNextStep)
        case .routineProgress:
            RoutineProgressView(onNext: goToNextStep)
        case .routineReady:
            RoutineReadyView(onComplete: onComplete)
        case .completed:
            EmptyView()
        }
    }
    
    private var currentStepIndex: Int {
        stepIndex(currentStep)
    }
    
    private func stepIndex(_ step: OnboardingStep) -> Int {
        OnboardingStep.allCases.firstIndex(of: step) ?? 0
    }
    
    private func goToNextStep() {
        HapticFeedback.light()
        
        if let nextStep = currentStep.next {
            withAnimation(.easeInOut(duration: 0.5)) {
                currentStep = nextStep
            }
        } else {
            // Onboarding complete
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            HapticFeedback.success()
            onComplete()
        }
    }
}

// MARK: - Individual Step Views (Placeholder implementations)

struct AgeGateStepView: View {
    let onNext: () -> Void
    
    @State private var birthDate = Date()
    @State private var showingDatePicker = false
    @State private var privacyPolicyConsent = false
    @State private var imageProcessingConsent = false
    
    private var isValidAge: Bool {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        return (ageComponents.year ?? 0) >= 16
    }
    
    private var canContinue: Bool {
        isValidAge && privacyPolicyConsent && imageProcessingConsent
    }
    
    private var ageText: String {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        let age = ageComponents.year ?? 0
        return age > 0 ? "\(age) years old" : "Select your birth date"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing32) {
                Spacer(minLength: Theme.spacing20)
                
                // Header
                VStack(spacing: Theme.spacing20) {
                    Text("🎂")
                        .font(.system(size: 80))
                    
                    Text("How old are you?")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundColor(Theme.text)
                        .multilineTextAlignment(.center)
                    
                    Text("We need to make sure you're 16 or older to use Skinfluence")
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.spacing20)
                }
                
                // Date picker button
                VStack(spacing: Theme.spacing16) {
                    Button(action: {
                        showingDatePicker = true
                        HapticFeedback.light()
                    }) {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Theme.primary)
                            
                            Text(birthDate == Date() ? "Select Date" : birthDate.formatted(date: .abbreviated, time: .omitted))
                                .font(Theme.bodyFont)
                                .foregroundColor(birthDate == Date() ? Theme.text.opacity(0.5) : Theme.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(Theme.primary)
                        }
                        .padding(Theme.spacing16)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                                .stroke(Theme.primary.opacity(0.2), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
                        .shadow(color: Theme.shadowColor, radius: 2, y: 1)
                    }
                    .padding(.horizontal, Theme.spacing24)
                    
                    if birthDate != Date() {
                        Text(ageText)
                            .font(Theme.headlineFont)
                            .foregroundColor(isValidAge ? .green : .red)
                            .padding(.top, Theme.spacing8)
                    }
                    
                    if !isValidAge && birthDate != Date() {
                        Text("You must be at least 16 years old to continue")
                            .font(Theme.captionFont)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Theme.spacing24)
                    }
                }
                
                // Consent checkboxes
                if isValidAge {
                    VStack(spacing: Theme.spacing20) {
                        Text("We also need your consent for:")
                            .font(Theme.bodyFont)
                            .foregroundColor(Theme.text.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Theme.spacing24)
                        
                        VStack(spacing: Theme.spacing16) {
                            // Privacy Policy consent
                            consentCheckbox(
                                isChecked: $privacyPolicyConsent,
                                title: "Privacy Policy",
                                description: "I have read and agree to the Privacy Policy",
                                isRequired: true
                            )
                            
                            // Image processing consent
                            consentCheckbox(
                                isChecked: $imageProcessingConsent,
                                title: "Facial Image Processing",
                                description: "I consent to optional facial image processing for personalized recommendations",
                                isRequired: true
                            )
                        }
                        .padding(.horizontal, Theme.spacing24)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.easeInOut(duration: 0.4), value: isValidAge)
                }
                
                Spacer(minLength: Theme.spacing32)
                
                // Continue button
                Button(action: {
                    saveDataAndContinue()
                }) {
                    Text("Continue")
                        .font(Theme.headlineFont)
                        .fontWeight(.semibold)
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
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                }
                .disabled(!canContinue)
                .opacity(canContinue ? 1.0 : 0.5)
                .padding(.horizontal, Theme.spacing24)
                .buttonStyle(PressedButtonStyle())
                
                Spacer(minLength: Theme.spacing20)
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheetView(birthDate: $birthDate, isPresented: $showingDatePicker)
        }
    }
    
    private func consentCheckbox(isChecked: Binding<Bool>, title: String, description: String, isRequired: Bool) -> some View {
        Button(action: {
            isChecked.wrappedValue.toggle()
            HapticFeedback.light()
        }) {
            HStack(alignment: .top, spacing: Theme.spacing12) {
                Image(systemName: isChecked.wrappedValue ? "checkmark.square.fill" : "square")
                    .font(.title2)
                    .foregroundColor(isChecked.wrappedValue ? Theme.primary : Theme.text.opacity(0.4))
                
                VStack(alignment: .leading, spacing: Theme.spacing4) {
                    HStack {
                        Text(title)
                            .font(Theme.bodyFont)
                            .fontWeight(.medium)
                            .foregroundColor(Theme.text)
                        
                        if isRequired {
                            Text("Required")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Theme.primary.opacity(0.2))
                                .foregroundColor(Theme.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        
                        Spacer()
                    }
                    
                    Text(description)
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            .padding(Theme.spacing16)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                    .stroke(isChecked.wrappedValue ? Theme.primary.opacity(0.3) : Theme.text.opacity(0.2), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
            .shadow(color: Theme.shadowColor.opacity(0.1), radius: 2, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func saveDataAndContinue() {
        guard canContinue else { return }
        
        HapticFeedback.success()
        
        // Save birth date and consents to UserDefaults
        UserDefaults.standard.set(birthDate, forKey: "userBirthDate")
        UserDefaults.standard.set(privacyPolicyConsent, forKey: "privacyPolicyConsent")
        UserDefaults.standard.set(imageProcessingConsent, forKey: "imageProcessingConsent")
        UserDefaults.standard.set(Date(), forKey: "consentTimestamp")
        
        onNext()
    }
}

struct DatePickerSheetView: View {
    @Binding var birthDate: Date
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: Theme.spacing20) {
                Text("Select Your Birth Date")
                    .font(Theme.headlineFont)
                    .foregroundColor(Theme.text)
                    .padding(.top, Theme.spacing20)
                
                DatePicker(
                    "",
                    selection: $birthDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding(.horizontal, Theme.spacing24)
                
                Button("Done") {
                    isPresented = false
                    HapticFeedback.success()
                    dismiss()
                }
                .font(Theme.headlineFont)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Theme.primary)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
                .padding(.horizontal, Theme.spacing24)
                .padding(.bottom, Theme.spacing32)
                
                Spacer()
            }
            .background(Theme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                        HapticFeedback.success()
                        dismiss()
                    }
                    .foregroundColor(Theme.primary)
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.height(400)])
        .presentationDragIndicator(.visible)
    }
}

struct ConsentsStepView: View {
    let onNext: () -> Void
    @State private var showContent = false
    @State private var heartScale: CGFloat = 1.0
    @State private var shieldScale: CGFloat = 1.0
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing32) {
                Spacer(minLength: Theme.spacing32)
                
                // Trust icons with animations
                HStack(spacing: Theme.spacing24) {
                    // Heart icon
                    Image(systemName: "heart.fill")
                        .font(.system(size: 35, weight: .light))
                        .foregroundColor(.pink.opacity(0.8))
                        .scaleEffect(heartScale)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: heartScale)
                    
                    // Shield icon
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 35, weight: .light))
                        .foregroundColor(Theme.primary)
                        .scaleEffect(shieldScale)
                        .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(0.3), value: shieldScale)
                }
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.8), value: showContent)
                
                // Main heading
                VStack(spacing: Theme.spacing16) {
                    Text("We care about you ♡")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundColor(Theme.text)
                        .multilineTextAlignment(.center)
                    
                    Text("Your privacy & trust are our top priorities")
                        .font(Theme.headlineFont)
                        .foregroundColor(Theme.text.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.spacing20)
                }
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.6).delay(0.3), value: showContent)
                
                // Trust points
                VStack(spacing: Theme.spacing20) {
                    trustPoint(
                        icon: "lock.shield.fill",
                        title: "Your data stays yours",
                        description: "We never sell or share your personal information. Ever.",
                        color: .green
                    )
                    
                    trustPoint(
                        icon: "eye.slash.fill",
                        title: "Photos processed privately",
                        description: "All image analysis happens securely on our servers and images are deleted after processing.",
                        color: Theme.secondary
                    )
                    
                    trustPoint(
                        icon: "heart.text.square.fill",
                        title: "Made with love for you",
                        description: "We're a small team genuinely passionate about helping you feel confident in your skin.",
                        color: .pink
                    )
                }
                .padding(.horizontal, Theme.spacing24)
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.6).delay(0.6), value: showContent)
                
                // Reassuring message
                VStack(spacing: Theme.spacing12) {
                    Text("✨ You're in safe hands")
                        .font(Theme.bodyFont)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("Join thousands of others on their skincare journey with complete peace of mind")
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.spacing32)
                }
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.6).delay(0.9), value: showContent)
                
                Spacer(minLength: Theme.spacing32)
                
                // Continue button
                Button(action: {
                    HapticFeedback.success()
                    onNext()
                }) {
                    HStack {
                        Text("I trust you, let's continue")
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
                            colors: [Theme.primary, Theme.secondary, .pink.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
                    .shadow(
                        color: Theme.primary.opacity(0.4),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                }
                .padding(.horizontal, Theme.spacing24)
                .buttonStyle(PressedButtonStyle())
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.6).delay(1.2), value: showContent)
                
                Spacer(minLength: Theme.spacing20)
            }
        }
        .onAppear {
            showContent = true
            heartScale = 1.1
            shieldScale = 1.1
        }
    }
    
    private func trustPoint(icon: String, title: String, description: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: Theme.spacing16) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: Theme.spacing4) {
                Text(title)
                    .font(Theme.bodyFont)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.text)
                
                Text(description)
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.text.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(Theme.spacing16)
        .background(Color.white.opacity(0.7))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
        .shadow(color: Theme.shadowColor.opacity(0.1), radius: 3, y: 2)
    }
}

struct SkinTypeView: View {
    let onNext: () -> Void
    @State private var selectedType: SkinProfile.BaseType? = nil
    @State private var showContent = false
    
    private var canContinue: Bool {
        selectedType != nil
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing32) {
                Spacer(minLength: Theme.spacing32)
                
                // Header
                VStack(spacing: Theme.spacing20) {
                    Text("🔍")
                        .font(.system(size: 60))
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showContent)
                    
                    Text("What's your skin type?")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundColor(Theme.text)
                        .multilineTextAlignment(.center)
                    
                    Text("Choose the option that best describes your skin")
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.spacing20)
                }
                
                // Skin type options
                VStack(spacing: Theme.spacing16) {
                    ForEach([SkinProfile.BaseType.normal, .oily, .dry, .combination], id: \.self) { type in
                        skinTypeCard(for: type)
                    }
                    
                    // Helper text
                    Text("Not sure? We'll help with a scan later! 🤳✨")
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.text.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.top, Theme.spacing12)
                        .padding(.horizontal, Theme.spacing24)
                }
                
                Spacer(minLength: Theme.spacing32)
                
                // Continue button
                if canContinue {
                    Button(action: {
                        saveTypeAndContinue()
                    }) {
                        Text("Continue")
                            .font(Theme.bodyFont)
                            .fontWeight(.semibold)
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
                                color: Theme.primary.opacity(0.4),
                                radius: 12,
                                x: 0,
                                y: 6
                            )
                    }
                    .padding(.horizontal, Theme.spacing24)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: canContinue)
                }
                
                Spacer(minLength: Theme.spacing20)
            }
        }
        .onAppear {
            showContent = true
        }
    }
    
    private func skinTypeCard(for type: SkinProfile.BaseType) -> some View {
        Button(action: {
            selectedType = type
            HapticFeedback.light()
        }) {
            HStack(spacing: Theme.spacing16) {
                // Icon
                Text(skinTypeIcon(for: type))
                    .font(.system(size: 24))
                
                VStack(alignment: .leading, spacing: Theme.spacing4) {
                    Text(type.displayName)
                        .font(Theme.bodyFont)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.text)
                        .multilineTextAlignment(.leading)
                    
                    Text(type.description)
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: selectedType == type ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(selectedType == type ? Theme.primary : Theme.text.opacity(0.3))
                    .scaleEffect(selectedType == type ? 1.1 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: selectedType)
            }
            .padding(Theme.spacing20)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                    .stroke(
                        selectedType == type ? Theme.primary.opacity(0.4) : Theme.text.opacity(0.1), 
                        lineWidth: selectedType == type ? 2 : 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
            .shadow(
                color: selectedType == type ? Theme.primary.opacity(0.2) : Theme.shadowColor.opacity(0.1), 
                radius: selectedType == type ? 8 : 2, 
                y: selectedType == type ? 4 : 1
            )
            .scaleEffect(selectedType == type ? 1.02 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedType)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, Theme.spacing24)
    }
    
    private func skinTypeIcon(for type: SkinProfile.BaseType) -> String {
        switch type {
        case .oily: return "💧"
        case .combination: return "⚖️"  
        case .dry: return "🏜️"
        case .normal: return "✨"
        }
    }
    
    private func saveTypeAndContinue() {
        guard let selectedType = selectedType else { return }
        
        HapticFeedback.success()
        
        // Save selected skin type to UserDefaults
        UserDefaults.standard.set(selectedType.rawValue, forKey: "userSkinType")
        
        onNext()
    }
}

struct SkinConcernsView: View {
    let onNext: () -> Void
    @State private var selectedConcerns: Set<String> = []
    @State private var showContent = false
    
    private let concerns = [
        ("Sensitive", "sensitive", "🌸", "Easily irritated by products"),
        ("Acne-prone", "acne_prone", "✨", "Frequent breakouts or blemishes"),
        ("Pigmentation-prone", "pigmentation_prone", "🌙", "Dark spots or uneven tone"),
        ("Redness/rosacea-prone", "rosacea_prone", "🌹", "Persistent redness or flushing")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing32) {
                Spacer(minLength: Theme.spacing32)
                
                // Header
                VStack(spacing: Theme.spacing20) {
                    Text("🎯")
                        .font(.system(size: 60))
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showContent)
                    
                    Text("Any specific concerns?")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundColor(Theme.text)
                        .multilineTextAlignment(.center)
                    
                    Text("Select any that apply to you (optional)")
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.spacing20)
                }
                
                // Concerns chips
                VStack(spacing: Theme.spacing16) {
                    ForEach(Array(concerns.enumerated()), id: \.offset) { index, concern in
                        concernChip(
                            title: concern.0,
                            key: concern.1,
                            icon: concern.2,
                            description: concern.3
                        )
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.1), value: showContent)
                    }
                }
                
                Spacer(minLength: Theme.spacing32)
                
                // Continue button (always enabled)
                Button(action: {
                    saveConcernsAndContinue()
                }) {
                    Text("Continue")
                        .font(Theme.bodyFont)
                        .fontWeight(.semibold)
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
                            color: Theme.primary.opacity(0.4),
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                }
                .padding(.horizontal, Theme.spacing24)
                
                Spacer(minLength: Theme.spacing20)
            }
        }
        .onAppear {
            showContent = true
        }
    }
    
    private func concernChip(title: String, key: String, icon: String, description: String) -> some View {
        Button(action: {
            if selectedConcerns.contains(key) {
                selectedConcerns.remove(key)
            } else {
                selectedConcerns.insert(key)
            }
            HapticFeedback.light()
        }) {
            HStack(spacing: Theme.spacing16) {
                // Icon
                Text(icon)
                    .font(.system(size: 24))
                
                VStack(alignment: .leading, spacing: Theme.spacing4) {
                    Text(title)
                        .font(Theme.bodyFont)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.text)
                        .multilineTextAlignment(.leading)
                    
                    Text(description)
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Selection indicator
                if selectedConcerns.contains(key) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(Theme.primary)
                        .scaleEffect(1.1)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Circle()
                        .stroke(Theme.text.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(Theme.spacing20)
            .background(
                selectedConcerns.contains(key) ? 
                Theme.primary.opacity(0.05) : 
                Color.white
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                    .stroke(
                        selectedConcerns.contains(key) ? 
                        Theme.primary.opacity(0.4) : 
                        Theme.text.opacity(0.1), 
                        lineWidth: selectedConcerns.contains(key) ? 2 : 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
            .shadow(
                color: selectedConcerns.contains(key) ? 
                Theme.primary.opacity(0.2) : 
                Theme.shadowColor.opacity(0.1), 
                radius: selectedConcerns.contains(key) ? 8 : 2, 
                y: selectedConcerns.contains(key) ? 4 : 1
            )
            .scaleEffect(selectedConcerns.contains(key) ? 1.02 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedConcerns)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, Theme.spacing24)
    }
    
    private func saveConcernsAndContinue() {
        HapticFeedback.success()
        
        // Save selected concerns to UserDefaults
        UserDefaults.standard.set(selectedConcerns.contains("sensitive"), forKey: "userSkinSensitive")
        UserDefaults.standard.set(selectedConcerns.contains("acne_prone"), forKey: "userSkinAcneProne")
        UserDefaults.standard.set(selectedConcerns.contains("pigmentation_prone"), forKey: "userSkinPigmentationProne")
        UserDefaults.standard.set(selectedConcerns.contains("rosacea_prone"), forKey: "userSkinRosaceaProne")
        
        onNext()
    }
}

struct SafetyFiltersView: View {
    let onNext: () -> Void
    @State private var pregnancySafe = false
    @State private var fragranceFree = false
    @State private var essentialOilFree = false
    @State private var alcoholDenatFree = false
    @State private var showContent = false
    
    private let safetyOptions = [
        ("Pregnancy-safe", "pregnancySafe", "🤱", "Products safe during pregnancy"),
        ("Fragrance-free", "fragranceFree", "🌿", "No added fragrances or perfumes"),
        ("Essential-oil-free", "essentialOilFree", "🚫", "No essential oils"),
        ("Alcohol denat-free", "alcoholDenatFree", "💧", "No drying alcohol")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing32) {
                Spacer(minLength: Theme.spacing32)
                
                // Header
                VStack(spacing: Theme.spacing20) {
                    Text("🛡️")
                        .font(.system(size: 60))
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showContent)
                    
                    Text("Safety preferences")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundColor(Theme.text)
                        .multilineTextAlignment(.center)
                    
                    Text("This just filters products—you're in control. 💕")
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.spacing20)
                }
                
                // Safety toggles
                VStack(spacing: Theme.spacing16) {
                    safetyToggle(
                        title: "Pregnancy-safe",
                        description: "Products safe during pregnancy",
                        icon: "🤱",
                        binding: $pregnancySafe
                    )
                    
                    safetyToggle(
                        title: "Fragrance-free",
                        description: "No added fragrances or perfumes",
                        icon: "🌿",
                        binding: $fragranceFree
                    )
                    
                    safetyToggle(
                        title: "Essential-oil-free", 
                        description: "No essential oils",
                        icon: "🚫",
                        binding: $essentialOilFree
                    )
                    
                    safetyToggle(
                        title: "Alcohol denat-free",
                        description: "No drying alcohol", 
                        icon: "💧",
                        binding: $alcoholDenatFree
                    )
                }
                
                Spacer(minLength: Theme.spacing32)
                
                // Continue button
                Button(action: {
                    saveFiltersAndContinue()
                }) {
                    Text("Continue")
                        .font(Theme.bodyFont)
                        .fontWeight(.semibold)
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
                            color: Theme.primary.opacity(0.4),
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                }
                .padding(.horizontal, Theme.spacing24)
                
                Spacer(minLength: Theme.spacing20)
            }
        }
        .onAppear {
            showContent = true
        }
    }
    
    private func safetyToggle(title: String, description: String, icon: String, binding: Binding<Bool>) -> some View {
        HStack(spacing: Theme.spacing16) {
            // Icon
            Text(icon)
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: Theme.spacing4) {
                Text(title)
                    .font(Theme.bodyFont)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.text)
                    .multilineTextAlignment(.leading)
                
                Text(description)
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.text.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            // Toggle
            Toggle("", isOn: binding)
                .labelsHidden()
                .tint(Theme.primary)
                .scaleEffect(0.8)
                .onChange(of: binding.wrappedValue) { _ in
                    HapticFeedback.light()
                }
        }
        .padding(Theme.spacing20)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                .stroke(Theme.text.opacity(0.1), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
        .shadow(color: Theme.shadowColor.opacity(0.1), radius: 2, y: 1)
        .padding(.horizontal, Theme.spacing24)
    }
    
    private func saveFiltersAndContinue() {
        HapticFeedback.success()
        
        // Save safety preferences to UserDefaults
        UserDefaults.standard.set(pregnancySafe, forKey: "safetyPregnancySafe")
        UserDefaults.standard.set(fragranceFree, forKey: "safetyFragranceFree")
        UserDefaults.standard.set(essentialOilFree, forKey: "safetyEssentialOilFree")
        UserDefaults.standard.set(alcoholDenatFree, forKey: "safetyAlcoholDenatFree")
        
        onNext()
    }
}

struct ScanCaptureStepView: View {
    let onNext: () -> Void
    @State private var capturedImages: [UIImage?] = [nil, nil]
    @State private var currentPhotoIndex = 0
    @State private var showCamera = false
    @State private var tempImage: UIImage? = nil
    @State private var showContent = false
    @State private var showPermissionAlert = false
    
    private let photoInstructions = [
        ("Look straight ahead", "Face the camera directly", "👁"),
        ("Turn slightly to the side", "Show your profile for texture analysis", "↗️")
    ]
    
    private var allPhotosCompleted: Bool {
        capturedImages.allSatisfy { $0 != nil }
    }
    
    var body: some View {
        VStack(spacing: Theme.spacing32) {
            Spacer(minLength: Theme.spacing20)
            
            // Progress indicators
            HStack(spacing: Theme.spacing8) {
                ForEach(0..<2, id: \.self) { index in
                    Circle()
                        .fill(index <= currentPhotoIndex ? Theme.primary : Theme.text.opacity(0.2))
                        .frame(width: 12, height: 12)
                        .scaleEffect(index == currentPhotoIndex ? 1.2 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: currentPhotoIndex)
                }
            }
            .opacity(showContent ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: showContent)
            
            // Progress bar
            ProgressView(value: Double(currentPhotoIndex + 1), total: 2.0)
                .progressViewStyle(LinearProgressViewStyle(tint: Theme.primary))
                .scaleEffect(y: 2.0)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .padding(.horizontal, Theme.spacing32)
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showContent)
            
            VStack(spacing: Theme.spacing24) {
                // Current instruction
                VStack(spacing: Theme.spacing12) {
                    Text(photoInstructions[currentPhotoIndex].2)
                        .font(.system(size: 40))
                    
                    Text(photoInstructions[currentPhotoIndex].0)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundColor(Theme.text)
                        .multilineTextAlignment(.center)
                    
                    Text(photoInstructions[currentPhotoIndex].1)
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: showContent)
                
                // Photo preview or placeholder
                GeometryReader { geometry in
                    let photoHeight = min(geometry.size.width * 1.2, 340) // 4:3 aspect ratio with max height
                    
                    RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                        .fill(Theme.text.opacity(0.05))
                        .frame(width: geometry.size.width, height: photoHeight)
                        .overlay {
                            if let image = capturedImages[currentPhotoIndex] {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: photoHeight)
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
                            } else {
                                VStack(spacing: Theme.spacing16) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(Theme.text.opacity(0.3))
                                    
                                    Text("Photo \(currentPhotoIndex + 1) of 2")
                                        .font(Theme.captionFont)
                                        .foregroundColor(Theme.text.opacity(0.5))
                                }
                            }
                        }
                        .frame(height: photoHeight) // Set container height
                }
                .frame(height: min(UIScreen.main.bounds.width * 1.2, 340)) // Match the calculated height
                .overlay {
                        // Face guide overlay
                        RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                            .stroke(
                                style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                            )
                            .foregroundColor(Theme.primary.opacity(0.3))
                    }
                    .padding(.horizontal, Theme.spacing32)
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: showContent)
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: Theme.spacing16) {
                if capturedImages[currentPhotoIndex] == nil {
                    // Take photo button
                    Button(action: {
                        checkCameraPermissionAndLaunch()
                    }) {
                        Text("Take Photo 📸")
                            .font(Theme.bodyFont)
                            .fontWeight(.semibold)
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
                                color: Theme.primary.opacity(0.4),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    }
                    .padding(.horizontal, Theme.spacing24)
                } else {
                    // Retake and Continue buttons
                    HStack(spacing: Theme.spacing12) {
                        Button("Retake") {
                            HapticFeedback.light()
                            capturedImages[currentPhotoIndex] = nil
                        }
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.text.opacity(0.6))
                        .padding(.horizontal, Theme.spacing16)
                        .padding(.vertical, Theme.spacing8)
                        .background(Theme.text.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
                        
                        Spacer()
                        
                        Button(action: {
                            HapticFeedback.success()
                            if currentPhotoIndex < 1 {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    currentPhotoIndex += 1
                                }
                            } else if allPhotosCompleted {
                                // All photos taken, move to review
                                savePhotosAndContinue()
                            }
                        }) {
                            Text(currentPhotoIndex < 1 ? "Next Photo →" : "Review Photos ✨")
                                .font(Theme.bodyFont)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, Theme.spacing20)
                                .padding(.vertical, Theme.spacing12)
                                .background(Theme.primary)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
                        }
                    }
                    .padding(.horizontal, Theme.spacing24)
                }
            }
            .opacity(showContent ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: showContent)
            
            Spacer(minLength: Theme.spacing24)
        }
        .sheet(isPresented: $showCamera) {
            CameraView(image: $tempImage) { capturedImage in
                capturedImages[currentPhotoIndex] = capturedImage
                showCamera = false
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.9).delay(0.2)) {
                showContent = true
            }
        }
        .alert("Camera Access Required", isPresented: $showPermissionAlert) {
            Button("Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable camera access in Settings to take photos for your skin analysis.")
        }
    }
    
    private func savePhotosAndContinue() {
        // For now, just store that photos were captured
        // Later we'll implement actual photo storage
        UserDefaults.standard.set(true, forKey: "hasCompletedScan")
        UserDefaults.standard.set(Date(), forKey: "scanCompletedAt")
        onNext()
    }
    
    private func checkCameraPermissionAndLaunch() {
        #if targetEnvironment(simulator)
            // Skip permission check on simulator
            showCamera = true
            return
        #endif
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // Permission already granted
            HapticFeedback.light()
            showCamera = true
        case .notDetermined:
            // Request permission
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        HapticFeedback.light()
                        showCamera = true
                    } else {
                        showPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            // Permission denied, show alert to go to settings
            showPermissionAlert = true
        @unknown default:
            showPermissionAlert = true
        }
    }
}

struct ScanReviewStepView: View {
    let onNext: () -> Void
    @State private var isAnalyzing = true
    @State private var showResults = false
    @State private var scanResult: ScanResult?
    @State private var showContent = false
    @State private var shouldApplyResults = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing32) {
                Spacer(minLength: Theme.spacing32)
                
                if isAnalyzing {
                    analyzingView
                } else {
                    resultsView
                }
                
                Spacer(minLength: Theme.spacing24)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.9).delay(0.2)) {
                showContent = true
            }
            startAnalysis()
        }
    }
    
    private var analyzingView: some View {
        VStack(spacing: Theme.spacing32) {
            // Analyzing animation
            VStack(spacing: Theme.spacing20) {
                ZStack {
                    Circle()
                        .stroke(Theme.primary.opacity(0.2), lineWidth: 4)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Theme.primary, lineWidth: 4)
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(isAnalyzing ? 360 : 0))
                        .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: isAnalyzing)
                    
                    Text("🔬")
                        .font(.system(size: 30))
                }
                
                VStack(spacing: Theme.spacing8) {
                    Text("Analyzing your skin...")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundColor(Theme.text)
                    
                    Text("Our AI is examining your photos for personalized insights")
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.spacing20)
                }
            }
            .opacity(showContent ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showContent)
            
            // Fun loading messages
            VStack(spacing: Theme.spacing8) {
                Text("✨ Checking skin texture")
                Text("🔍 Analyzing tone & concerns")
                Text("🎯 Calculating recommendations")
            }
            .font(Theme.captionFont)
            .foregroundColor(Theme.text.opacity(0.5))
            .opacity(showContent ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: showContent)
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: Theme.spacing32) {
            // Header
            VStack(spacing: Theme.spacing20) {
                Text("📊")
                    .font(.system(size: 60))
                    .opacity(showResults ? 1.0 : 0.0)
                    .scaleEffect(showResults ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showResults)
                
                Text("Your Skin Analysis")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundColor(Theme.text)
                    .multilineTextAlignment(.center)
                    .opacity(showResults ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: showResults)
            }
            
            // Results card
            if let result = scanResult {
                VStack(spacing: Theme.spacing20) {
                    // Main skin type
                    HStack {
                        Text("Skin Type:")
                            .font(Theme.bodyFont)
                            .fontWeight(.medium)
                            .foregroundColor(Theme.text.opacity(0.7))
                        
                        Spacer()
                        
                        Text(result.baseType.capitalized)
                            .font(Theme.bodyFont)
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.primary)
                    }
                    
                    Divider()
                        .background(Theme.text.opacity(0.1))
                    
                    // Key observations
                    VStack(alignment: .leading, spacing: Theme.spacing12) {
                        Text("Key Observations:")
                            .font(Theme.bodyFont)
                            .fontWeight(.medium)
                            .foregroundColor(Theme.text.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: Theme.spacing8) {
                            if result.observations.oilinessTZone > 0.4 {
                                observationRow("✓", "T-zone oiliness detected")
                            }
                            if result.modifiers["sensitive"] == true {
                                observationRow("✓", "Some sensitivity detected")
                            }
                            if result.modifiers["pigmentation_prone"] == true {
                                observationRow("✓", "Mild pigmentation areas")
                            }
                            if result.modifiers["acne_prone"] == true {
                                observationRow("✓", "Acne-prone characteristics")
                            }
                            if result.modifiers["rosacea_prone"] == true {
                                observationRow("✓", "Redness patterns observed")
                            }
                        }
                    }
                    
                    Divider()
                        .background(Theme.text.opacity(0.1))
                    
                    // Confidence
                    HStack {
                        Text("Confidence:")
                            .font(Theme.bodyFont)
                            .fontWeight(.medium)
                            .foregroundColor(Theme.text.opacity(0.7))
                        
                        Spacer()
                        
                        Text("\(Int(result.observations.confidence * 100))% accurate")
                            .font(Theme.bodyFont)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
                .padding(Theme.spacing20)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
                .shadow(color: Theme.shadowColor.opacity(0.1), radius: 4, y: 2)
                .padding(.horizontal, Theme.spacing24)
                .opacity(showResults ? 1.0 : 0.0)
                .offset(y: showResults ? 0 : 20)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showResults)
            }
            
            // Apply results section
            VStack(spacing: Theme.spacing20) {
                VStack(spacing: Theme.spacing12) {
                    Text("Apply scan results to my profile? 🎯")
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundColor(Theme.text)
                        .multilineTextAlignment(.center)
                    
                    Text("This will update your skin type and concerns based on the scan")
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.spacing20)
                }
                
                HStack(spacing: Theme.spacing12) {
                    Button(action: {
                        HapticFeedback.light()
                        shouldApplyResults = false
                        saveResultsAndContinue()
                    }) {
                        Text("Keep My Answers")
                            .font(Theme.captionFont)
                            .fontWeight(.medium)
                            .foregroundColor(Theme.text.opacity(0.6))
                            .padding(.horizontal, Theme.spacing20)
                            .padding(.vertical, Theme.spacing12)
                            .background(Theme.text.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
                    }
                    
                    Button(action: {
                        HapticFeedback.success()
                        shouldApplyResults = true
                        saveResultsAndContinue()
                    }) {
                        Text("Apply Results ✨")
                            .font(Theme.bodyFont)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, Theme.spacing24)
                            .padding(.vertical, Theme.spacing12)
                            .background(
                                LinearGradient(
                                    colors: [Theme.primary, Theme.secondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
                            .shadow(
                                color: Theme.primary.opacity(0.3),
                                radius: 6,
                                x: 0,
                                y: 3
                            )
                    }
                }
            }
            .opacity(showResults ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: showResults)
        }
    }
    
    private func observationRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: Theme.spacing8) {
            Text(icon)
                .font(Theme.captionFont)
                .foregroundColor(.green)
            
            Text(text)
                .font(Theme.captionFont)
                .foregroundColor(Theme.text.opacity(0.6))
            
            Spacer()
        }
    }
    
    private func startAnalysis() {
        // Simulate analysis delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            loadMockScanResults()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isAnalyzing = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showResults = true
                }
            }
        }
    }
    
    private func loadMockScanResults() {
        // Load from scan_mock.json
        guard let path = Bundle.main.path(forResource: "scan_mock", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let result = try? JSONDecoder().decode(ScanResult.self, from: data) else {
            // Fallback mock data
            let mockObservations = ScanObservations(
                oilinessTZone: 0.62,
                erythema: 0.18,
                poreVisibility: 0.55,
                activeLesions: 1,
                postInflammatoryHyperpigmentation: 0.4,
                textureRoughness: 0.3,
                confidence: 0.84,
                capturedAt: Date()
            )
            
            scanResult = ScanResult(
                version: "1.0",
                baseType: "combination",
                modifiers: ["sensitive": true, "acne_prone": false, "pigmentation_prone": true, "rosacea_prone": false],
                observations: mockObservations
            )
            return
        }
        
        scanResult = result
    }
    
    private func saveResultsAndContinue() {
        guard let result = scanResult else { return }
        
        if shouldApplyResults {
            // Check if user had previous answers
            let hadPreviousAnswers = UserDefaults.standard.object(forKey: "userSkinType") != nil
            
            // Convert scan result to skin profile
            let scanProfile = result.toSkinProfile()
            
            // Save scan-based profile
            UserDefaults.standard.set(scanProfile.baseType.rawValue, forKey: "userSkinType")
            UserDefaults.standard.set(scanProfile.sensitive, forKey: "skinConcernSensitive")
            UserDefaults.standard.set(scanProfile.acneProne, forKey: "skinConcernAcne")
            UserDefaults.standard.set(scanProfile.pigmentationProne, forKey: "skinConcernPigmentation")
            UserDefaults.standard.set(scanProfile.rosaceaProne, forKey: "skinConcernRosacea")
            
            // Set source based on whether user had previous answers
            let source = hadPreviousAnswers ? "mixed" : "scan"
            UserDefaults.standard.set(source, forKey: "skinProfileSource")
        } else {
            // Keep questionnaire answers, just mark that scan was completed
            UserDefaults.standard.set("questionnaire", forKey: "skinProfileSource")
        }
        
        UserDefaults.standard.set(true, forKey: "useMockScanData")
        onNext()
    }
}

struct QuestionnaireStepView: View {
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: Theme.spacing32) {
            Spacer()
            
            Text("Quick Questions")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.text)
                .multilineTextAlignment(.center)
            
            Button("Continue (Placeholder)", action: onNext)
                .font(Theme.headlineFont)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Theme.primary)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
                .padding(.horizontal, Theme.spacing32)
            
            Spacer()
        }
    }
}

struct BudgetEffortView: View {
    let onNext: () -> Void
    @State private var selectedBudget: BudgetTier? = nil
    @State private var selectedRoutine: RoutineSize? = nil
    @State private var showContent = false
    
    private var canContinue: Bool {
        selectedBudget != nil && selectedRoutine != nil
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing32) {
                Spacer(minLength: Theme.spacing32)
                
                // Header
                VStack(spacing: Theme.spacing20) {
                    Text("💸")
                        .font(.system(size: 60))
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showContent)
                    
                    Text("Budget & Time Preferences")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundColor(Theme.text)
                        .multilineTextAlignment(.center)
                    
                    Text("Let's find products that fit your lifestyle")
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.spacing20)
                }
                
                // Budget Section
                VStack(spacing: Theme.spacing20) {
                    HStack {
                        Text("What's your beauty budget?")
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                            .foregroundColor(Theme.text)
                        Spacer()
                    }
                    .padding(.horizontal, Theme.spacing24)
                    
                    VStack(spacing: Theme.spacing12) {
                        ForEach([BudgetTier.value, .balanced, .premium], id: \.self) { tier in
                            budgetCard(for: tier)
                        }
                    }
                }
                
                // Routine Section
                VStack(spacing: Theme.spacing20) {
                    HStack {
                        Text("How much time for self-care?")
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                            .foregroundColor(Theme.text)
                        Spacer()
                    }
                    .padding(.horizontal, Theme.spacing24)
                    
                    VStack(spacing: Theme.spacing12) {
                        ForEach([RoutineSize.minimal, .classic, .maximal], id: \.self) { routine in
                            routineCard(for: routine)
                        }
                    }
                }
                
                Spacer(minLength: Theme.spacing32)
                
                // Continue button
                if canContinue {
                    Button(action: {
                        saveBudgetEffortAndContinue()
                    }) {
                        Text("Let's find your perfect products! →")
                            .font(Theme.bodyFont)
                            .fontWeight(.semibold)
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
                                color: Theme.primary.opacity(0.4),
                                radius: 12,
                                x: 0,
                                y: 6
                            )
                    }
                    .padding(.horizontal, Theme.spacing24)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: canContinue)
                }
                
                Spacer(minLength: Theme.spacing24)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.9).delay(0.2)) {
                showContent = true
            }
        }
    }
    
    private func budgetCard(for tier: BudgetTier) -> some View {
        Button(action: {
            selectedBudget = tier
            HapticFeedback.light()
        }) {
            HStack(spacing: Theme.spacing16) {
                // Icon
                Text(budgetIcon(for: tier))
                    .font(.system(size: 24))
                
                VStack(alignment: .leading, spacing: Theme.spacing4) {
                    HStack(spacing: Theme.spacing8) {
                        Text(tier.displayName)
                            .font(Theme.bodyFont)
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.text)
                        
                        Text(tier.priceRange)
                            .font(Theme.captionFont)
                            .fontWeight(.medium)
                            .foregroundColor(Theme.primary)
                            .padding(.horizontal, Theme.spacing8)
                            .padding(.vertical, Theme.spacing2)
                            .background(Theme.primary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
                    }
                    
                    Text(tier.description)
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: selectedBudget == tier ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(selectedBudget == tier ? Theme.primary : Theme.text.opacity(0.3))
                    .scaleEffect(selectedBudget == tier ? 1.1 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: selectedBudget)
            }
            .padding(Theme.spacing20)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                    .stroke(
                        selectedBudget == tier ? Theme.primary.opacity(0.4) : Theme.text.opacity(0.1), 
                        lineWidth: selectedBudget == tier ? 2 : 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
            .shadow(
                color: selectedBudget == tier ? Theme.primary.opacity(0.2) : Theme.shadowColor.opacity(0.1), 
                radius: selectedBudget == tier ? 8 : 2, 
                y: selectedBudget == tier ? 4 : 1
            )
            .scaleEffect(selectedBudget == tier ? 1.02 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedBudget)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, Theme.spacing24)
    }
    
    private func routineCard(for routine: RoutineSize) -> some View {
        Button(action: {
            selectedRoutine = routine
            HapticFeedback.light()
        }) {
            HStack(spacing: Theme.spacing16) {
                // Icon
                Text(routine.emoji)
                    .font(.system(size: 24))
                
                VStack(alignment: .leading, spacing: Theme.spacing4) {
                    HStack(spacing: Theme.spacing8) {
                        Text(routine.displayName)
                            .font(Theme.bodyFont)
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.text)
                        
                        Text("\(routine.stepCount) • \(routine.timeEstimate)")
                            .font(Theme.captionFont)
                            .fontWeight(.medium)
                            .foregroundColor(Theme.secondary)
                            .padding(.horizontal, Theme.spacing8)
                            .padding(.vertical, Theme.spacing2)
                            .background(Theme.secondary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
                    }
                    
                    Text(routine.description)
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: selectedRoutine == routine ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(selectedRoutine == routine ? Theme.secondary : Theme.text.opacity(0.3))
                    .scaleEffect(selectedRoutine == routine ? 1.1 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: selectedRoutine)
            }
            .padding(Theme.spacing20)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                    .stroke(
                        selectedRoutine == routine ? Theme.secondary.opacity(0.4) : Theme.text.opacity(0.1), 
                        lineWidth: selectedRoutine == routine ? 2 : 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
            .shadow(
                color: selectedRoutine == routine ? Theme.secondary.opacity(0.2) : Theme.shadowColor.opacity(0.1), 
                radius: selectedRoutine == routine ? 8 : 2, 
                y: selectedRoutine == routine ? 4 : 1
            )
            .scaleEffect(selectedRoutine == routine ? 1.02 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedRoutine)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, Theme.spacing24)
    }
    
    private func budgetIcon(for tier: BudgetTier) -> String {
        switch tier {
        case .value: return "💕"
        case .balanced: return "✨"
        case .premium: return "👑"
        }
    }
    
    private func saveBudgetEffortAndContinue() {
        guard let selectedBudget = selectedBudget,
              let selectedRoutine = selectedRoutine else { return }
        
        HapticFeedback.success()
        
        // Save budget and routine preferences to UserDefaults
        UserDefaults.standard.set(selectedBudget.rawValue, forKey: "userBudgetTier")
        UserDefaults.standard.set(selectedRoutine.rawValue, forKey: "userRoutineSize")
        
        onNext()
    }
}

struct ActivesComfortView: View {
    let onNext: () -> Void
    @State private var selectedComfort: ActivesComfort? = nil
    @State private var showContent = false
    @State private var showInfoTooltip = false
    
    private var canContinue: Bool {
        selectedComfort != nil
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing32) {
                Spacer(minLength: Theme.spacing32)
                
                // Header
                VStack(spacing: Theme.spacing20) {
                    Text("🧪")
                        .font(.system(size: 60))
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showContent)
                    
                    VStack(spacing: Theme.spacing8) {
                        HStack {
                            Text("How comfortable are you with active ingredients?")
                                .font(.system(.title, design: .rounded, weight: .bold))
                                .foregroundColor(Theme.text)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                showInfoTooltip.toggle()
                                HapticFeedback.light()
                            }) {
                                Image(systemName: "info.circle")
                                    .font(.title3)
                                    .foregroundColor(Theme.primary)
                            }
                        }
                        
                        if showInfoTooltip {
                            VStack(spacing: Theme.spacing8) {
                                Text("What are actives? 🤔")
                                    .font(Theme.bodyFont)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Theme.text)
                                
                                Text("Active ingredients like retinol, vitamin C, and acids that actively change your skin")
                                    .font(Theme.captionFont)
                                    .foregroundColor(Theme.text.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(Theme.spacing16)
                            .background(Theme.primary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
                            .transition(.scale.combined(with: .opacity))
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showInfoTooltip)
                        }
                    }
                    
                    Text("This helps us recommend the right strength products for you")
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.spacing20)
                }
                
                // Actives comfort options
                VStack(spacing: Theme.spacing16) {
                    ForEach([ActivesComfort.newbie, .someExperience, .confident], id: \.self) { comfort in
                        activesCard(for: comfort)
                            .opacity(showContent ? 1.0 : 0.0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.8)
                                .delay(Double(ActivesComfort.allCases.firstIndex(of: comfort) ?? 0) * 0.1), 
                                value: showContent
                            )
                    }
                }
                
                Spacer(minLength: Theme.spacing32)
                
                // Continue button
                if canContinue {
                    Button(action: {
                        saveComfortAndContinue()
                    }) {
                        Text("Perfect! Let's scan your skin ✨")
                            .font(Theme.bodyFont)
                            .fontWeight(.semibold)
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
                                color: Theme.primary.opacity(0.4),
                                radius: 12,
                                x: 0,
                                y: 6
                            )
                    }
                    .padding(.horizontal, Theme.spacing24)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: canContinue)
                }
                
                Spacer(minLength: Theme.spacing24)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.9).delay(0.2)) {
                showContent = true
            }
        }
    }
    
    private func activesCard(for comfort: ActivesComfort) -> some View {
        Button(action: {
            selectedComfort = comfort
            HapticFeedback.light()
        }) {
            VStack(spacing: Theme.spacing16) {
                HStack(spacing: Theme.spacing16) {
                    // Icon
                    Text(comfort.emoji)
                        .font(.system(size: 28))
                    
                    VStack(alignment: .leading, spacing: Theme.spacing4) {
                        Text(comfort.subtitle)
                            .font(Theme.bodyFont)
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.text)
                            .multilineTextAlignment(.leading)
                        
                        Text(comfort.description)
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.text.opacity(0.7))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                    
                    // Selection indicator
                    Image(systemName: selectedComfort == comfort ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(selectedComfort == comfort ? comfortAccentColor(for: comfort) : Theme.text.opacity(0.3))
                        .scaleEffect(selectedComfort == comfort ? 1.1 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: selectedComfort)
                }
                
                // Examples
                if selectedComfort == comfort {
                    VStack(spacing: Theme.spacing8) {
                        Divider()
                            .background(Theme.text.opacity(0.1))
                        
                        HStack {
                            Text("Examples:")
                                .font(Theme.captionFont)
                                .fontWeight(.semibold)
                                .foregroundColor(Theme.text.opacity(0.6))
                            Spacer()
                        }
                        
                        Text(comfort.examples)
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.text.opacity(0.6))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedComfort)
                }
            }
            .padding(Theme.spacing20)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                    .stroke(
                        selectedComfort == comfort ? comfortAccentColor(for: comfort).opacity(0.4) : Theme.text.opacity(0.1), 
                        lineWidth: selectedComfort == comfort ? 2 : 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
            .shadow(
                color: selectedComfort == comfort ? comfortAccentColor(for: comfort).opacity(0.2) : Theme.shadowColor.opacity(0.1), 
                radius: selectedComfort == comfort ? 8 : 2, 
                y: selectedComfort == comfort ? 4 : 1
            )
            .scaleEffect(selectedComfort == comfort ? 1.02 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedComfort)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, Theme.spacing24)
    }
    
    private func comfortAccentColor(for comfort: ActivesComfort) -> Color {
        switch comfort {
        case .newbie: return Color.green.opacity(0.8)
        case .someExperience: return Theme.primary
        case .confident: return Color.purple.opacity(0.8)
        }
    }
    
    private func saveComfortAndContinue() {
        guard let selectedComfort = selectedComfort else { return }
        
        HapticFeedback.success()
        
        // Save actives comfort to UserDefaults
        UserDefaults.standard.set(selectedComfort.rawValue, forKey: "userActivesComfort")
        
        onNext()
    }
}

struct GoalPickerView: View {
    let onNext: () -> Void
    @State private var selectedGoals: [SkinGoal] = []
    @State private var showContent = false
    
    private let columns = [
        GridItem(.flexible(), spacing: Theme.spacing16),
        GridItem(.flexible(), spacing: Theme.spacing16)
    ]
    
    private var buttonText: String {
        switch selectedGoals.count {
        case 0: return ""
        case 1: return "Select 2 more..."
        case 2: return "Select 1 more..."
        case 3: return "Perfect priorities! Let's continue →"
        default: return ""
        }
    }
    
    private var canContinue: Bool {
        selectedGoals.count == 3
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing32) {
                Spacer(minLength: Theme.spacing32)
                
                // Header with target icon
                VStack(spacing: Theme.spacing20) {
                    Text("🎯")
                        .font(.system(size: 60))
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .opacity(showContent ? 1.0 : 0.0)
                    
                    VStack(spacing: Theme.spacing12) {
                        Text("What are your top 3 skin goals?")
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundColor(Theme.text)
                            .multilineTextAlignment(.center)
                        
                        Text("Pick your priorities in order (1st, 2nd, 3rd) 💕")
                            .font(Theme.bodyFont)
                            .foregroundColor(Theme.text.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Theme.spacing20)
                    }
                    .scaleEffect(showContent ? 1.0 : 0.9)
                    .opacity(showContent ? 1.0 : 0.0)
                }
                .animation(.easeOut(duration: 0.8), value: showContent)
                
                // Goals grid
                LazyVGrid(columns: columns, spacing: Theme.spacing16) {
                    ForEach(SkinGoal.allCases, id: \.self) { goal in
                        goalCard(goal: goal)
                    }
                }
                .padding(.horizontal, Theme.spacing20)
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.6).delay(0.4), value: showContent)
                
                Spacer(minLength: Theme.spacing32)
                
                // Continue button
                if !selectedGoals.isEmpty {
                    Button(action: {
                        if canContinue {
                            saveGoalsAndContinue()
                        }
                    }) {
                        Text(buttonText)
                            .font(Theme.bodyFont)
                            .fontWeight(.semibold)
                            .foregroundColor(canContinue ? .white : Theme.text.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                canContinue ? 
                                Theme.primary : 
                                Color.clear
                            )
                            .overlay(
                                canContinue ? 
                                nil : 
                                RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                                    .stroke(Theme.text.opacity(0.3), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
                            .shadow(
                                color: canContinue ? Theme.primary.opacity(0.4) : Color.clear,
                                radius: canContinue ? 12 : 0,
                                x: 0,
                                y: canContinue ? 6 : 0
                            )
                    }
                    .disabled(!canContinue)
                    .padding(.horizontal, Theme.spacing24)
                    .buttonStyle(PressedButtonStyle())
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .animation(.easeOut(duration: 0.5), value: selectedGoals.count)
                }
                
                Spacer(minLength: Theme.spacing20)
            }
        }
        .onAppear {
            showContent = true
        }
    }
    
    private func goalCard(goal: SkinGoal) -> some View {
        Button(action: {
            toggleGoalSelection(goal)
        }) {
            ZStack {
                VStack(spacing: Theme.spacing12) {
                    Text(goal.icon)
                        .font(.system(size: 32))
                    
                    Text(goal.rawValue)
                        .font(Theme.bodyFont)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.text)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 120)
                .padding(Theme.spacing16)
                .background(
                    selectedGoals.contains(goal) ? 
                    goal.accentColor.opacity(0.1) : 
                    Color.white.opacity(0.8)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                        .stroke(
                            selectedGoals.contains(goal) ? 
                            goal.accentColor.opacity(0.6) : 
                            Theme.text.opacity(0.2), 
                            lineWidth: selectedGoals.contains(goal) ? 2 : 1
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
                .shadow(
                    color: selectedGoals.contains(goal) ? 
                    goal.accentColor.opacity(0.2) : 
                    Theme.shadowColor.opacity(0.1), 
                    radius: selectedGoals.contains(goal) ? 6 : 3, 
                    y: selectedGoals.contains(goal) ? 4 : 2
                )
                .scaleEffect(selectedGoals.contains(goal) ? 1.02 : 1.0)
                .opacity((selectedGoals.count == 3 && !selectedGoals.contains(goal)) ? 0.5 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: selectedGoals)
                
                // Selection number badge
                if let index = selectedGoals.firstIndex(of: goal) {
                    VStack {
                        HStack {
                            Spacer()
                            Text("\(index + 1)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(goal.accentColor)
                                .clipShape(Circle())
                                .shadow(color: goal.accentColor.opacity(0.4), radius: 4, y: 2)
                        }
                        Spacer()
                    }
                    .padding(Theme.spacing12)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: selectedGoals)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(selectedGoals.count == 3 && !selectedGoals.contains(goal))
    }
    
    private func toggleGoalSelection(_ goal: SkinGoal) {
        HapticFeedback.light()
        
        if let index = selectedGoals.firstIndex(of: goal) {
            // Remove the goal
            selectedGoals.remove(at: index)
        } else if selectedGoals.count < 3 {
            // Add the goal
            selectedGoals.append(goal)
        }
    }
    
    private func saveGoalsAndContinue() {
        guard selectedGoals.count == 3 else { return }
        
        HapticFeedback.success()
        
        // Save selected goals array to UserDefaults
        let goalStrings = selectedGoals.map { $0.rawValue }
        UserDefaults.standard.set(goalStrings, forKey: "primarySkinGoals")
        
        onNext()
    }
}

struct ScanGuideStepView: View {
    let onNext: () -> Void
    @State private var showContent = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing32) {
                Spacer(minLength: Theme.spacing32)
                
                // Header
                VStack(spacing: Theme.spacing20) {
                    Text("📸")
                        .font(.system(size: 60))
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showContent)
                    
                    Text("Let's get your perfect skin scan!")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundColor(Theme.text)
                        .multilineTextAlignment(.center)
                    
                    Text("Quick photos for personalized analysis")
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.spacing20)
                }
                
                // Preparation steps
                VStack(spacing: Theme.spacing16) {
                    preparationCard(
                        icon: "✨",
                        title: "Find Good Lighting",
                        description: "Natural light is best, avoid harsh shadows"
                    )
                    .opacity(showContent ? 1.0 : 0.0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: showContent)
                    
                    preparationCard(
                        icon: "🧼",
                        title: "Clean Face",
                        description: "Remove makeup and cleanse your skin"
                    )
                    .opacity(showContent ? 1.0 : 0.0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showContent)
                    
                    preparationCard(
                        icon: "😊",
                        title: "Relax & Center",
                        description: "Look straight at the camera, neutral expression"
                    )
                    .opacity(showContent ? 1.0 : 0.0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: showContent)
                }
                
                // Pro tip
                VStack(spacing: Theme.spacing12) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.caption)
                            .foregroundColor(Theme.secondary)
                        
                        Text("Pro tip: Morning scans give the best results! 🌅")
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.text.opacity(0.6))
                    }
                    .padding(Theme.spacing16)
                    .background(Theme.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: showContent)
                }
                
                Spacer(minLength: Theme.spacing32)
                
                // Action buttons
                VStack(spacing: Theme.spacing16) {
                    Button(action: {
                        HapticFeedback.success()
                        onNext()
                    }) {
                        Text("I'm ready! Let's scan 📸")
                            .font(Theme.bodyFont)
                            .fontWeight(.semibold)
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
                                color: Theme.primary.opacity(0.4),
                                radius: 12,
                                x: 0,
                                y: 6
                            )
                    }
                    .padding(.horizontal, Theme.spacing24)
                    
                    Button(action: {
                        // Skip to next onboarding step (questionnaire)
                        HapticFeedback.light()
                        // For now, we'll still go to scan capture but could skip entirely
                        onNext()
                    }) {
                        Text("Not ready? Skip for now")
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.text.opacity(0.6))
                    }
                }
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: showContent)
                
                Spacer(minLength: Theme.spacing24)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.9).delay(0.2)) {
                showContent = true
            }
        }
    }
    
    private func preparationCard(icon: String, title: String, description: String) -> some View {
        HStack(spacing: Theme.spacing16) {
            Text(icon)
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: Theme.spacing4) {
                Text(title)
                    .font(Theme.bodyFont)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.text)
                
                Text(description)
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.text.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(Theme.spacing20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
        .shadow(color: Theme.shadowColor.opacity(0.1), radius: 2, y: 1)
        .padding(.horizontal, Theme.spacing24)
    }
}

// MARK: - Camera View
struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    var onCapture: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        
        #if targetEnvironment(simulator)
            // Use photo library on simulator since camera is not available
            picker.sourceType = .photoLibrary
        #else
            // Use camera on physical device
            picker.sourceType = .camera
            picker.cameraDevice = .front // Front camera for selfies
        #endif
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let originalImage = info[.originalImage] as? UIImage {
                // Optimize image for skin analysis
                let optimizedImage = optimizeImageForSkinAnalysis(originalImage)
                parent.image = optimizedImage
                parent.onCapture(optimizedImage)
            }
            picker.dismiss(animated: true)
        }
        
        private func optimizeImageForSkinAnalysis(_ image: UIImage) -> UIImage {
            // Target size for skin analysis (good balance of detail and file size)
            let targetSize = CGSize(width: 1024, height: 1024)
            
            // Calculate scale factor to maintain aspect ratio
            let widthRatio = targetSize.width / image.size.width
            let heightRatio = targetSize.height / image.size.height
            let scaleFactor = min(widthRatio, heightRatio)
            
            let scaledSize = CGSize(
                width: image.size.width * scaleFactor,
                height: image.size.height * scaleFactor
            )
            
            // Create optimized image
            let renderer = UIGraphicsImageRenderer(size: scaledSize)
            let optimizedImage = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: scaledSize))
            }
            
            return optimizedImage
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - NotificationsPrePromptView
struct NotificationsPrePromptView: View {
    let onNext: () -> Void
    @State private var enableMorning = true
    @State private var enableEvening = true
    @State private var showContent = false
    @State private var requestingPermission = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing32) {
                Spacer(minLength: Theme.spacing32)
                
                // Header section
                VStack(spacing: Theme.spacing20) {
                    Text("⏰")
                        .font(.system(size: 60))
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showContent)
                    
                    Text("Stay Consistent with Reminders")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundColor(Theme.text)
                        .multilineTextAlignment(.center)
                    
                    Text("Get gentle reminders to follow your personalized routine")
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.spacing24)
                }
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: showContent)
                
                // Benefits section
                VStack(spacing: Theme.spacing16) {
                    benefitRow(icon: "sun.max.fill", title: "Morning Routine", description: "Start your day with skincare", color: .orange)
                    benefitRow(icon: "moon.fill", title: "Evening Routine", description: "Wind down with your night routine", color: .indigo)
                    benefitRow(icon: "chart.line.uptrend.xyaxis", title: "Track Progress", description: "See your skin improve over time", color: Theme.primary)
                }
                .padding(.horizontal, Theme.spacing24)
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)
                
                Spacer(minLength: Theme.spacing32)
                
                // Action buttons
                VStack(spacing: Theme.spacing16) {
                    Button(action: requestNotificationPermission) {
                        HStack {
                            if requestingPermission {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            
                            Text(requestingPermission ? "Enabling..." : "Enable Notifications")
                                .font(Theme.headlineFont)
                                .fontWeight(.semibold)
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
                            color: Theme.primary.opacity(0.4),
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                    }
                    .disabled(requestingPermission)
                    .buttonStyle(PressedButtonStyle())
                    
                    Button(action: {
                        HapticFeedback.light()
                        onNext()
                    }) {
                        Text("Maybe Later")
                            .font(Theme.bodyFont)
                            .fontWeight(.medium)
                            .foregroundColor(Theme.text.opacity(0.6))
                    }
                }
                .padding(.horizontal, Theme.spacing24)
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.6).delay(0.6), value: showContent)
                
                Spacer(minLength: Theme.spacing20)
            }
        }
        .onAppear {
            showContent = true
        }
    }
    
    private func benefitRow(icon: String, title: String, description: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: Theme.spacing16) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: Theme.spacing4) {
                Text(title)
                    .font(Theme.bodyFont)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.text)
                
                Text(description)
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.text.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(Theme.spacing16)
        .background(Color.white.opacity(0.7))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
        .shadow(color: Theme.shadowColor.opacity(0.1), radius: 3, y: 2)
    }
    
    private func requestNotificationPermission() {
        guard !requestingPermission else { return }
        
        HapticFeedback.success()
        requestingPermission = true
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                requestingPermission = false
                
                if granted {
                    // Schedule sample notifications
                    scheduleRoutineReminders()
                    HapticFeedback.success()
                } else {
                    HapticFeedback.light()
                }
                
                // Continue regardless of permission
                onNext()
            }
        }
    }
    
    private func scheduleRoutineReminders() {
        let center = UNUserNotificationCenter.current()
        
        // Morning reminder
        let morningContent = UNMutableNotificationContent()
        morningContent.title = "Good Morning! ☀️"
        morningContent.body = "Ready to start your skincare routine?"
        morningContent.sound = .default
        
        let morningTrigger = UNCalendarNotificationTrigger(
            dateMatching: DateComponents(hour: 8, minute: 0),
            repeats: true
        )
        
        let morningRequest = UNNotificationRequest(
            identifier: "morning_routine",
            content: morningContent,
            trigger: morningTrigger
        )
        
        // Evening reminder
        let eveningContent = UNMutableNotificationContent()
        eveningContent.title = "Time for Your Evening Routine 🌙"
        eveningContent.body = "Wind down with your personalized skincare routine"
        eveningContent.sound = .default
        
        let eveningTrigger = UNCalendarNotificationTrigger(
            dateMatching: DateComponents(hour: 21, minute: 0),
            repeats: true
        )
        
        let eveningRequest = UNNotificationRequest(
            identifier: "evening_routine",
            content: eveningContent,
            trigger: eveningTrigger
        )
        
        center.add(morningRequest)
        center.add(eveningRequest)
    }
}

// MARK: - CreatorCodeView
struct CreatorCodeView: View {
    let onNext: () -> Void
    @State private var creatorCode = ""
    @State private var showContent = false
    @State private var validatingCode = false
    @State private var isValidCode = false
    @State private var showSuccess = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing32) {
                Spacer(minLength: Theme.spacing32)
                
                // Header section
                VStack(spacing: Theme.spacing20) {
                    Text("🎁")
                        .font(.system(size: 60))
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showContent)
                    
                    Text("Got a Creator Code?")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundColor(Theme.text)
                        .multilineTextAlignment(.center)
                    
                    Text("Enter a referral code from your favorite skincare creator for exclusive perks")
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.spacing24)
                }
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: showContent)
                
                // Code input section
                VStack(spacing: Theme.spacing20) {
                    VStack(alignment: .leading, spacing: Theme.spacing8) {
                        Text("Creator Code")
                            .font(Theme.captionFont)
                            .fontWeight(.medium)
                            .foregroundColor(Theme.text.opacity(0.8))
                            .textCase(.uppercase)
                            .tracking(0.5)
                        
                        HStack {
                            TextField("Enter code", text: $creatorCode)
                                .font(Theme.bodyFont)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.horizontal, Theme.spacing16)
                                .padding(.vertical, Theme.spacing12)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                                        .stroke(
                                            isValidCode ? Color.green : Theme.text.opacity(0.2),
                                            lineWidth: isValidCode ? 2 : 1
                                        )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
                                .textInputAutocapitalization(.characters)
                                .autocorrectionDisabled()
                                .onChange(of: creatorCode) { newValue in
                                    creatorCode = newValue.uppercased()
                                    validateCode()
                                }
                            
                            if validatingCode {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Theme.primary))
                                    .scaleEffect(0.8)
                                    .padding(.trailing, Theme.spacing8)
                            } else if isValidCode {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.green)
                                    .padding(.trailing, Theme.spacing8)
                                    .scaleEffect(showSuccess ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showSuccess)
                            }
                        }
                    }
                    
                    if isValidCode {
                        HStack(spacing: Theme.spacing8) {
                            Image(systemName: "gift.fill")
                                .foregroundColor(.green)
                            Text("Valid code! You'll get special perks from this creator.")
                                .font(Theme.captionFont)
                                .foregroundColor(.green)
                        }
                        .padding(.top, Theme.spacing4)
                        .opacity(showSuccess ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.4), value: showSuccess)
                    }
                }
                .padding(.horizontal, Theme.spacing24)
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)
                
                // Benefits section
                VStack(spacing: Theme.spacing12) {
                    Text("Creator Benefits")
                        .font(Theme.bodyFont)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.text)
                    
                    VStack(spacing: Theme.spacing8) {
                        benefitItem("Exclusive product recommendations")
                        benefitItem("Priority customer support")
                        benefitItem("Early access to new features")
                    }
                }
                .padding(.horizontal, Theme.spacing24)
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.6).delay(0.6), value: showContent)
                
                Spacer(minLength: Theme.spacing32)
                
                // Action buttons
                VStack(spacing: Theme.spacing16) {
                    if !creatorCode.isEmpty && isValidCode {
                        Button(action: {
                            HapticFeedback.success()
                            applyCreatorCode()
                        }) {
                            HStack {
                                Image(systemName: "gift.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Apply Code & Continue")
                                    .font(Theme.headlineFont)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [.green, .green.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
                            .shadow(
                                color: Color.green.opacity(0.4),
                                radius: 12,
                                x: 0,
                                y: 6
                            )
                        }
                        .buttonStyle(PressedButtonStyle())
                    }
                    
                    Button(action: {
                        HapticFeedback.light()
                        onNext()
                    }) {
                        Text("Skip for Now")
                            .font(Theme.bodyFont)
                            .fontWeight(.medium)
                            .foregroundColor(Theme.text.opacity(0.6))
                    }
                }
                .padding(.horizontal, Theme.spacing24)
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.6).delay(0.8), value: showContent)
                
                Spacer(minLength: Theme.spacing20)
            }
        }
        .onAppear {
            showContent = true
        }
    }
    
    private func benefitItem(_ text: String) -> some View {
        HStack(spacing: Theme.spacing8) {
            Image(systemName: "star.fill")
                .font(.system(size: 12))
                .foregroundColor(Theme.primary)
            
            Text(text)
                .font(Theme.captionFont)
                .foregroundColor(Theme.text.opacity(0.7))
            
            Spacer()
        }
    }
    
    private func validateCode() {
        guard !creatorCode.isEmpty else {
            isValidCode = false
            showSuccess = false
            return
        }
        
        validatingCode = true
        showSuccess = false
        
        // Simulate API validation with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            validatingCode = false
            
            // Mock validation logic - real app would validate against server
            let validCodes = ["SKINCARE2025", "GLOW", "CLEAR", "ROUTINE", "BEAUTY"]
            isValidCode = validCodes.contains(creatorCode.uppercased())
            
            if isValidCode {
                showSuccess = true
                HapticFeedback.success()
            } else {
                HapticFeedback.light()
            }
        }
    }
    
    private func applyCreatorCode() {
        // Store the creator code for later use
        UserDefaults.standard.set(creatorCode.uppercased(), forKey: "creator_code")
        UserDefaults.standard.set(Date(), forKey: "creator_code_applied_at")
        
        // Continue to next step
        onNext()
    }
}

// MARK: - GenerateReadyView
struct GenerateReadyView: View {
    let onNext: () -> Void
    @State private var showContent = false
    @State private var showCheckmarks = false
    @State private var pulsingEmoji = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing32) {
                Spacer(minLength: Theme.spacing32)
                
                // Header section
                VStack(spacing: Theme.spacing20) {
                    Text("✨")
                        .font(.system(size: 60))
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .opacity(showContent ? 1.0 : 0.0)
                        .scaleEffect(pulsingEmoji ? 1.1 : 1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showContent)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulsingEmoji)
                    
                    Text("Ready to Build Your Routine")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundColor(Theme.text)
                        .multilineTextAlignment(.center)
                    
                    Text("We'll analyze your skin profile and create a personalized routine just for you")
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.spacing24)
                }
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: showContent)
                
                // Profile summary section
                VStack(spacing: Theme.spacing20) {
                    Text("Your Profile Summary")
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundColor(Theme.text)
                    
                    VStack(spacing: Theme.spacing12) {
                        summaryItem(icon: "face.smiling", title: "Skin Type", value: "Combination", completed: showCheckmarks)
                        summaryItem(icon: "target", title: "Main Goals", value: "Clear breakouts, Fade spots", completed: showCheckmarks)
                        summaryItem(icon: "dollarsign.circle", title: "Budget", value: "Mid-range products", completed: showCheckmarks)
                        summaryItem(icon: "clock", title: "Routine Size", value: "Simple & effective", completed: showCheckmarks)
                        summaryItem(icon: "camera.viewfinder", title: "Skin Analysis", value: "Complete", completed: showCheckmarks)
                    }
                }
                .padding(.horizontal, Theme.spacing24)
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)
                
                // What we'll do section
                VStack(spacing: Theme.spacing16) {
                    Text("What We'll Create For You")
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundColor(Theme.text)
                    
                    VStack(spacing: Theme.spacing12) {
                        featureItem(icon: "list.bullet.rectangle", title: "Morning Routine", description: "3-4 products tailored to your skin")
                        featureItem(icon: "moon.stars", title: "Evening Routine", description: "4-5 products for overnight repair")
                        featureItem(icon: "cart", title: "Product Recommendations", description: "Curated from 1000+ trusted brands")
                        featureItem(icon: "calendar", title: "Usage Schedule", description: "When and how to use each product")
                    }
                }
                .padding(.horizontal, Theme.spacing24)
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.6).delay(0.6), value: showContent)
                
                Spacer(minLength: Theme.spacing32)
                
                // Generate button
                Button(action: {
                    HapticFeedback.success()
                    onNext()
                }) {
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Generate My Routine")
                            .font(Theme.headlineFont)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [Theme.primary, Theme.secondary, .pink.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
                    .shadow(
                        color: Theme.primary.opacity(0.4),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                }
                .padding(.horizontal, Theme.spacing24)
                .buttonStyle(PressedButtonStyle())
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.6).delay(0.8), value: showContent)
                
                Spacer(minLength: Theme.spacing20)
            }
        }
        .onAppear {
            showContent = true
            pulsingEmoji = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showCheckmarks = true
            }
        }
    }
    
    private func summaryItem(icon: String, title: String, value: String, completed: Bool) -> some View {
        HStack(spacing: Theme.spacing12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Theme.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.captionFont)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.text.opacity(0.7))
                
                Text(value)
                    .font(Theme.bodyFont)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.text)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.green)
                .opacity(completed ? 1.0 : 0.0)
                .scaleEffect(completed ? 1.0 : 0.5)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double.random(in: 0...0.4)), value: completed)
        }
        .padding(Theme.spacing16)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                .stroke(Theme.primary.opacity(0.1), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
        .shadow(color: Theme.shadowColor.opacity(0.05), radius: 2, y: 1)
    }
    
    private func featureItem(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: Theme.spacing16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Theme.secondary)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: Theme.spacing4) {
                Text(title)
                    .font(Theme.bodyFont)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.text)
                
                Text(description)
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.text.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(Theme.spacing16)
        .background(Color.white.opacity(0.7))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                .stroke(Theme.secondary.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
        .shadow(color: Theme.shadowColor.opacity(0.1), radius: 3, y: 2)
    }
}

// MARK: - RoutineProgressView
struct RoutineProgressView: View {
    let onNext: () -> Void
    @State private var currentStep = 0
    @State private var showContent = false
    @State private var progress: Double = 0.0
    
    private let progressSteps = [
        ("Analyzing your skin profile", "👁️", "Understanding your unique skin characteristics..."),
        ("Matching perfect products", "🔍", "Finding products tailored to your needs..."),
        ("Building morning routine", "☀️", "Creating your AM skincare sequence..."),
        ("Building evening routine", "🌙", "Designing your PM repair routine..."),
        ("Optimizing product order", "📋", "Ensuring maximum product effectiveness..."),
        ("Finalizing recommendations", "✨", "Adding finishing touches to your routine...")
    ]
    
    var body: some View {
        VStack(spacing: Theme.spacing32) {
            Spacer(minLength: Theme.spacing32)
            
            // Header
            VStack(spacing: Theme.spacing20) {
                Text("🧬")
                    .font(.system(size: 60))
                    .scaleEffect(showContent ? 1.0 : 0.8)
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showContent)
                
                Text("Building Your Routine")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundColor(Theme.text)
                    .multilineTextAlignment(.center)
                
                Text("Our AI is analyzing your profile to create the perfect skincare routine")
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.text.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.spacing24)
            }
            .opacity(showContent ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.6).delay(0.2), value: showContent)
            
            // Progress bar
            VStack(spacing: Theme.spacing12) {
                HStack {
                    Text("\(Int(progress * 100))%")
                        .font(Theme.bodyFont)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.primary)
                    
                    Spacer()
                    
                    Text("\(currentStep + 1) of \(progressSteps.count)")
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Theme.text.opacity(0.1))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [Theme.primary, Theme.secondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 8)
                            .animation(.easeInOut(duration: 0.8), value: progress)
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal, Theme.spacing24)
            .opacity(showContent ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)
            
            // Current step display
            VStack(spacing: Theme.spacing16) {
                if currentStep < progressSteps.count {
                    let step = progressSteps[currentStep]
                    
                    Text(step.1)
                        .font(.system(size: 40))
                        .scaleEffect(1.2)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentStep)
                    
                    Text(step.0)
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundColor(Theme.text)
                        .multilineTextAlignment(.center)
                    
                    Text(step.2)
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.spacing32)
                }
            }
            .opacity(showContent ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.6).delay(0.6), value: showContent)
            
            Spacer()
            
            // Steps overview
            VStack(spacing: Theme.spacing8) {
                ForEach(0..<progressSteps.count, id: \.self) { index in
                    let step = progressSteps[index]
                    let isCompleted = index < currentStep
                    let isCurrent = index == currentStep
                    
                    HStack(spacing: Theme.spacing12) {
                        // Step indicator
                        ZStack {
                            Circle()
                                .fill(isCompleted ? Color.green : isCurrent ? Theme.primary : Theme.text.opacity(0.2))
                                .frame(width: 24, height: 24)
                            
                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                                    .scaleEffect(isCompleted ? 1.0 : 0.5)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isCompleted)
                            } else if isCurrent {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.6)
                            }
                        }
                        
                        // Step text
                        HStack(spacing: Theme.spacing8) {
                            Text(step.1)
                                .font(.system(size: 16))
                            
                            Text(step.0)
                                .font(Theme.captionFont)
                                .foregroundColor(isCompleted ? .green : isCurrent ? Theme.primary : Theme.text.opacity(0.5))
                                .fontWeight(isCurrent ? .semibold : .regular)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, Theme.spacing24)
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.6).delay(0.8 + Double(index) * 0.1), value: showContent)
                }
            }
            
            Spacer(minLength: Theme.spacing32)
        }
        .onAppear {
            showContent = true
            startProgressAnimation()
        }
    }
    
    private func startProgressAnimation() {
        // Animate through all steps
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 0.8)) {
                if currentStep < progressSteps.count - 1 {
                    currentStep += 1
                    progress = Double(currentStep + 1) / Double(progressSteps.count)
                    
                    // Add haptic feedback for step completion
                    HapticFeedback.light()
                } else {
                    timer.invalidate()
                    // Complete the routine after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        HapticFeedback.success()
                        onNext()
                    }
                }
            }
        }
    }
}

// MARK: - RoutineReadyView
struct RoutineReadyView: View {
    let onComplete: () -> Void
    @State private var showContent = false
    @State private var showConfetti = false
    @State private var sparkleScale: Double = 1.0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Theme.primary.opacity(0.1),
                    Theme.secondary.opacity(0.1),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Theme.spacing32) {
                    Spacer(minLength: Theme.spacing32)
                    
                    // Celebration header
                    VStack(spacing: Theme.spacing20) {
                        ZStack {
                            Text("🎉")
                                .font(.system(size: 60))
                                .scaleEffect(showContent ? 1.0 : 0.8)
                                .opacity(showContent ? 1.0 : 0.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showContent)
                            
                            // Sparkle effects
                            ForEach(0..<8, id: \.self) { index in
                                Text("✨")
                                    .font(.system(size: 20))
                                    .offset(
                                        x: cos(Double(index) * .pi / 4) * 60,
                                        y: sin(Double(index) * .pi / 4) * 60
                                    )
                                    .scaleEffect(sparkleScale)
                                    .opacity(showConfetti ? 1.0 : 0.0)
                                    .animation(
                                        .easeInOut(duration: 1.0)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.1),
                                        value: sparkleScale
                                    )
                            }
                        }
                        
                        Text("Your Routine is Ready!")
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .foregroundColor(Theme.text)
                            .multilineTextAlignment(.center)
                        
                        Text("Congratulations! We've created a personalized skincare routine just for you.")
                            .font(Theme.bodyFont)
                            .foregroundColor(Theme.text.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Theme.spacing24)
                    }
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.8).delay(0.2), value: showContent)
                    
                    // Quick stats
                    HStack(spacing: Theme.spacing20) {
                        statItem(number: "7", label: "Products", color: Theme.primary)
                        statItem(number: "2", label: "Routines", color: Theme.secondary)
                        statItem(number: "98%", label: "Match Score", color: .green)
                    }
                    .padding(.horizontal, Theme.spacing24)
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.8).delay(0.4), value: showContent)
                    
                    // Preview cards
                    VStack(spacing: Theme.spacing16) {
                        routinePreview(
                            title: "Morning Routine",
                            icon: "sun.max.fill",
                            duration: "5-7 minutes",
                            products: ["Gentle Cleanser", "Vitamin C Serum", "Moisturizer", "SPF 30+"],
                            color: .orange
                        )
                        
                        routinePreview(
                            title: "Evening Routine", 
                            icon: "moon.fill",
                            duration: "8-10 minutes",
                            products: ["Oil Cleanser", "Gentle Cleanser", "Retinol Serum", "Night Moisturizer"],
                            color: .indigo
                        )
                    }
                    .padding(.horizontal, Theme.spacing24)
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.8).delay(0.6), value: showContent)
                    
                    // Success message
                    VStack(spacing: Theme.spacing12) {
                        Text("✅ Perfect Match Found!")
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                            .foregroundColor(.green)
                        
                        Text("Your routine is scientifically tailored to your combination skin and specific goals")
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.text.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Theme.spacing32)
                    }
                    .padding(Theme.spacing20)
                    .background(Color.green.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
                    .padding(.horizontal, Theme.spacing24)
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.8).delay(0.8), value: showContent)
                    
                    Spacer(minLength: Theme.spacing32)
                    
                    // Continue to dashboard button
                    Button(action: {
                        HapticFeedback.success()
                        // Mark onboarding as completed
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        onComplete()
                    }) {
                        HStack {
                            Text("View My Routine")
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
                                colors: [Theme.primary, Theme.secondary, .pink.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
                        .shadow(
                            color: Theme.primary.opacity(0.4),
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                    }
                    .padding(.horizontal, Theme.spacing24)
                    .buttonStyle(PressedButtonStyle())
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.8).delay(1.0), value: showContent)
                    
                    Spacer(minLength: Theme.spacing20)
                }
            }
        }
        .onAppear {
            showContent = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showConfetti = true
                sparkleScale = 1.2
                
                // Success haptic feedback
                HapticFeedback.success()
            }
        }
    }
    
    private func statItem(number: String, label: String, color: Color) -> some View {
        VStack(spacing: Theme.spacing8) {
            Text(number)
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundColor(color)
            
            Text(label)
                .font(Theme.captionFont)
                .foregroundColor(Theme.text.opacity(0.7))
                .textCase(.uppercase)
                .tracking(0.5)
        }
        .padding(Theme.spacing16)
        .background(Color.white.opacity(0.8))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
        .shadow(color: Theme.shadowColor.opacity(0.1), radius: 3, y: 2)
    }
    
    private func routinePreview(title: String, icon: String, duration: String, products: [String], color: Color) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundColor(Theme.text)
                    
                    Text(duration)
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                }
                
                Spacer()
                
                Text("\(products.count) products")
                    .font(Theme.captionFont)
                    .foregroundColor(color)
                    .fontWeight(.medium)
                    .padding(.horizontal, Theme.spacing8)
                    .padding(.vertical, Theme.spacing4)
                    .background(color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            VStack(alignment: .leading, spacing: Theme.spacing4) {
                ForEach(products.indices, id: \.self) { index in
                    HStack(spacing: Theme.spacing8) {
                        Text("\(index + 1).")
                            .font(Theme.captionFont)
                            .foregroundColor(color)
                            .fontWeight(.semibold)
                            .frame(width: 20, alignment: .leading)
                        
                        Text(products[index])
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.text.opacity(0.8))
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(Theme.spacing20)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
        .shadow(color: Theme.shadowColor.opacity(0.1), radius: 4, y: 2)
    }
}

struct OnboardingContainerView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingContainerView(onComplete: {})
    }
}
