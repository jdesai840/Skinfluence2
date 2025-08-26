//
//  User.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import Foundation

// MARK: - App User
struct AppUser: Codable, Identifiable {
    let id: String // Firebase UID
    let email: String?
    let createdAt: Date
    var lastActiveAt: Date
    var profile: SkinProfile?
    var preferences: Preferences
    var consents: UserConsents
    var proStatus: ProStatus
    var scanHistory: [ScanObservations]
    
    init(id: String, email: String? = nil) {
        self.id = id
        self.email = email
        self.createdAt = Date()
        self.lastActiveAt = Date()
        self.profile = nil
        self.preferences = Preferences()
        self.consents = UserConsents()
        self.proStatus = ProStatus()
        self.scanHistory = []
    }
    
    var hasCompletedOnboarding: Bool {
        return profile != nil && consents.hasRequiredConsents
    }
    
    var latestScan: ScanObservations? {
        return scanHistory.last
    }
    
    mutating func updateProfile(_ newProfile: SkinProfile) {
        self.profile = newProfile
        self.lastActiveAt = Date()
    }
    
    mutating func updatePreferences(_ newPreferences: Preferences) {
        self.preferences = newPreferences
        self.lastActiveAt = Date()
    }
    
    mutating func addScanObservations(_ observations: ScanObservations) {
        scanHistory.append(observations)
        self.lastActiveAt = Date()
    }
}

// MARK: - Onboarding State
enum OnboardingStep: String, CaseIterable {
    case ageGate = "age_gate"
    case consents = "consents"
    case retailers = "retailers"
    case skinType = "skin_type"
    case skinConcerns = "skin_concerns"
    case safetyFilters = "safety_filters"
    case budget = "budget"
    case activesComfort = "actives_comfort"
    case scanGuide = "scan_guide"
    case scanCapture = "scan_capture"
    case scanReview = "scan_review"
    case questionnaire = "questionnaire"
    case notificationsPrePrompt = "notifications_pre_prompt"
    case creatorCode = "creator_code"
    case generateReady = "generate_ready"
    case routineProgress = "routine_progress"
    case routineReady = "routine_ready"
    case completed = "completed"
    
    var displayName: String {
        switch self {
        case .ageGate: return "Age Verification"
        case .consents: return "Privacy & Consents"
        case .retailers: return "Retailer Preferences"
        case .skinType: return "Skin Type"
        case .skinConcerns: return "Skin Concerns"
        case .safetyFilters: return "Safety Filters"
        case .budget: return "Budget Selection"
        case .activesComfort: return "Actives Comfort"
        case .scanGuide: return "Scan Guide"
        case .scanCapture: return "Scan Capture"
        case .scanReview: return "Scan Review"
        case .questionnaire: return "Questionnaire"
        case .notificationsPrePrompt: return "Notifications"
        case .creatorCode: return "Creator Code"
        case .generateReady: return "Generate Routine"
        case .routineProgress: return "Building Routine"
        case .routineReady: return "Routine Ready"
        case .completed: return "Complete"
        }
    }
    
    var progress: Double {
        let index = OnboardingStep.allCases.firstIndex(of: self) ?? 0
        return Double(index + 1) / Double(OnboardingStep.allCases.count)
    }
    
    var next: OnboardingStep? {
        let index = OnboardingStep.allCases.firstIndex(of: self) ?? 0
        let nextIndex = index + 1
        guard nextIndex < OnboardingStep.allCases.count else { return nil }
        return OnboardingStep.allCases[nextIndex]
    }
}

// MARK: - App State
struct AppState {
    var isSignedIn: Bool = false
    var user: AppUser?
    var currentOnboardingStep: OnboardingStep?
    var hasCompletedOnboarding: Bool {
        return user?.hasCompletedOnboarding ?? false
    }
    
    mutating func signIn(user: AppUser) {
        self.user = user
        self.isSignedIn = true
        
        if !user.hasCompletedOnboarding {
            self.currentOnboardingStep = .ageGate
        }
    }
    
    mutating func signOut() {
        self.user = nil
        self.isSignedIn = false
        self.currentOnboardingStep = nil
    }
    
    mutating func completeOnboardingStep(_ step: OnboardingStep) {
        self.currentOnboardingStep = step.next
    }
}