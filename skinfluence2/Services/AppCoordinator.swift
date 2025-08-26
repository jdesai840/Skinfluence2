//
//  AppCoordinator.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import SwiftUI

// MARK: - App Views (kept for reference)
enum AppView {
    case launch
    case signIn
    case onboarding
    case main
}

// MARK: - Onboarding Steps (kept for future implementation)
enum OnboardingStep: String, CaseIterable {
    case ageGate = "age_gate"
    case skinType = "skin_type"
    case concerns = "concerns"  
    case budget = "budget"
    case retailers = "retailers"
    case scanGuide = "scan_guide"
    case completed = "completed"
    
    var next: OnboardingStep? {
        let index = OnboardingStep.allCases.firstIndex(of: self) ?? 0
        let nextIndex = index + 1
        guard nextIndex < OnboardingStep.allCases.count else { return nil }
        return OnboardingStep.allCases[nextIndex]
    }
}