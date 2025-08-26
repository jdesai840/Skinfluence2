//
//  AgeGateView.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import SwiftUI

struct AgeGateView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var toastManager: ToastManager
    @State private var birthDate = Date()
    @State private var showingDatePicker = false
    
    private var isValidAge: Bool {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        return (ageComponents.year ?? 0) >= 16
    }
    
    private var ageText: String {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        let age = ageComponents.year ?? 0
        return age > 0 ? "\(age) years old" : "Select your birth date"
    }
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            VStack(spacing: Theme.spacing32) {
                // Progress indicator
                ProgressView(value: 0.1)
                    .progressViewStyle(LinearProgressViewStyle(tint: Theme.primary))
                    .padding(.horizontal)
                
                Spacer()
                
                // Header
                VStack(spacing: Theme.spacing16) {
                    Image(systemName: "calendar")
                        .font(.system(size: 50, weight: .light))
                        .foregroundColor(Theme.primary)
                    
                    Text("How old are you?")
                        .font(Theme.titleFont)
                        .foregroundColor(Theme.text)
                        .multilineTextAlignment(.center)
                    
                    Text("You must be at least 16 years old to use Skinfluence. We use this to provide age-appropriate skincare recommendations.")
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.spacing20)
                }
                
                // Date Selection
                VStack(spacing: Theme.spacing16) {
                    Button(action: {
                        showingDatePicker = true
                    }) {
                        HStack {
                            Text("Birth Date:")
                                .font(Theme.bodyFont)
                                .foregroundColor(Theme.text)
                            
                            Spacer()
                            
                            Text(birthDate.formatted(date: .abbreviated, time: .omitted))
                                .font(Theme.bodyFont)
                                .foregroundColor(Theme.primary)
                            
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(Theme.primary)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(Theme.cornerRadiusMedium)
                        .shadow(color: Theme.shadowColor, radius: 4, y: 2)
                    }
                    .padding(.horizontal)
                    
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
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Continue Button
                Button(action: continueOnboarding) {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                }
                .primaryStyle()
                .disabled(!isValidAge)
                .opacity(isValidAge ? 1.0 : 0.5)
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePicker(
                "Birth Date",
                selection: $birthDate,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(WheelDatePickerStyle())
            .padding()
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
    
    private func continueOnboarding() {
        guard isValidAge else { return }
        
        HapticFeedback.success()
        
        // Update user with birth date
        if var user = authService.currentUser {
            // In a real app, you'd save birthDate to user profile
            // For now, we'll just continue to next step
            authService.updateUser(user)
        }
        
        toastManager.show(text: "Age verified successfully!", style: .success)
        
        // Navigate to next onboarding step
        AnalyticsService.shared.track(AnalyticsEvents.ageGatePassed)
        NotificationCenter.default.post(name: .onboardingStepCompleted, object: nil)
    }
}

#Preview {
    AgeGateView()
        .environmentObject(AuthService.shared)
        .environmentObject(ToastManager())
}