//
//  OnboardingViews.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import SwiftUI

// MARK: - Questionnaire View
struct QuestionnaireView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var selectedSkinType: SkinProfile.BaseType = .normal
    @State private var isSensitive = false
    @State private var isAcneProne = false
    @State private var hasPigmentation = false
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Theme.spacing24) {
                    // Header
                    VStack(spacing: Theme.spacing16) {
                        Text("Tell Us About Your Skin")
                            .font(Theme.titleFont)
                            .foregroundColor(Theme.text)
                            .multilineTextAlignment(.center)
                        
                        Text("This helps us create your personalized routine. No medical advice - just cosmetic recommendations!")
                            .font(Theme.bodyFont)
                            .foregroundColor(Theme.text.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Skin Type Selection
                    VStack(alignment: .leading, spacing: Theme.spacing16) {
                        Text("What's your primary skin type?")
                            .font(Theme.headlineFont)
                            .foregroundColor(Theme.text)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: Theme.spacing12) {
                            ForEach(SkinType.allCases, id: \.self) { skinType in
                                SkinTypeCard(
                                    skinType: skinType,
                                    isSelected: selectedSkinType == skinType
                                ) {
                                    selectedSkinType = skinType
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Skin Concerns
                    VStack(alignment: .leading, spacing: Theme.spacing16) {
                        Text("Any specific concerns? (Select all that apply)")
                            .font(Theme.headlineFont)
                            .foregroundColor(Theme.text)
                        
                        VStack(spacing: Theme.spacing12) {
                            ConcernToggle(
                                title: "Sensitive skin",
                                description: "Easily irritated by products or weather",
                                isOn: $isSensitive
                            )
                            
                            ConcernToggle(
                                title: "Acne-prone",
                                description: "Regular breakouts or clogged pores",
                                isOn: $isAcneProne
                            )
                            
                            ConcernToggle(
                                title: "Pigmentation concerns",
                                description: "Dark spots, uneven tone, or scarring",
                                isOn: $hasPigmentation
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Complete Button
                    Button(action: completeProfile) {
                        Text("Create My Routine")
                            .frame(maxWidth: .infinity)
                    }
                    .primaryStyle()
                    .padding(.horizontal)
                    .padding(.bottom, Theme.spacing32)
                }
            }
        }
    }
    
    private func completeProfile() {
        // Save profile and move to main app
        // For now, just print the selections
        print("Skin Type: \(selectedSkinType)")
        print("Sensitive: \(isSensitive), Acne: \(isAcneProne), Pigmentation: \(hasPigmentation)")
        
        // In a real app, this would save to the user profile
        // For demo, we'll just continue to main app
    }
}

// MARK: - Skin Types
enum SkinType: String, CaseIterable {
    case oily = "oily"
    case dry = "dry"
    case combination = "combination"
    case normal = "normal"
    
    var displayName: String {
        switch self {
        case .oily: return "Oily"
        case .dry: return "Dry"
        case .combination: return "Combination"
        case .normal: return "Normal"
        }
    }
    
    var description: String {
        switch self {
        case .oily: return "Shiny, enlarged pores"
        case .dry: return "Tight, flaky patches"
        case .combination: return "Oily T-zone, dry cheeks"
        case .normal: return "Balanced, few issues"
        }
    }
    
    var icon: String {
        switch self {
        case .oily: return "drop.fill"
        case .dry: return "leaf.fill"
        case .combination: return "circle.lefthalf.filled"
        case .normal: return "checkmark.circle.fill"
        }
    }
}

// MARK: - Supporting Views
struct SkinTypeCard: View {
    let skinType: SkinType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Theme.spacing12) {
                Image(systemName: skinType.icon)
                    .font(.largeTitle)
                    .foregroundColor(isSelected ? .white : Theme.primary)
                
                VStack(spacing: Theme.spacing8) {
                    Text(skinType.displayName)
                        .font(Theme.headlineFont)
                        .foregroundColor(isSelected ? .white : Theme.text)
                    
                    Text(skinType.description)
                        .font(Theme.captionFont)
                        .foregroundColor(isSelected ? .white.opacity(0.9) : Theme.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(isSelected ? Theme.primary : Color.white)
            .cornerRadius(Theme.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                    .stroke(Theme.primary, lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ConcernToggle: View {
    let title: String
    let description: String
    @Binding var isOn: Bool
    
    var body: some View {
        Button(action: { isOn.toggle() }) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.spacing8) {
                    Text(title)
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text)
                    
                    Text(description)
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: isOn ? "checkmark.square.fill" : "square")
                    .font(.title2)
                    .foregroundColor(isOn ? Theme.primary : Theme.text.opacity(0.4))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(Theme.cornerRadiusMedium)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Budget Selection View
struct BudgetSelectionView: View {
    @State private var selectedBudget: BudgetTier = .balanced
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            VStack(spacing: Theme.spacing32) {
                // Header
                VStack(spacing: Theme.spacing16) {
                    Image(systemName: "dollarsign.circle")
                        .font(.system(size: 50, weight: .light))
                        .foregroundColor(Theme.primary)
                    
                    Text("What's your budget?")
                        .font(Theme.titleFont)
                        .foregroundColor(Theme.text)
                    
                    Text("We'll recommend products that fit your budget range. You can always change this later!")
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Budget Options
                VStack(spacing: Theme.spacing16) {
                    ForEach(BudgetTier.allCases, id: \.self) { budget in
                        BudgetCard(
                            budget: budget,
                            isSelected: selectedBudget == budget
                        ) {
                            selectedBudget = budget
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    print("Selected budget: \(selectedBudget)")
                    // Continue to next step
                }) {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                }
                .primaryStyle()
                .padding(.horizontal)
            }
        }
    }
}


struct BudgetCard: View {
    let budget: BudgetTier
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.spacing8) {
                    Text(budget.displayName)
                        .font(Theme.headlineFont)
                        .foregroundColor(isSelected ? .white : Theme.text)
                    
                    Text(budget.description)
                        .font(Theme.bodyFont)
                        .foregroundColor(isSelected ? .white.opacity(0.9) : Theme.text.opacity(0.8))
                    
                    Text(budget.priceRange)
                        .font(Theme.captionFont)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : Theme.text.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : Theme.primary)
            }
            .padding()
            .background(isSelected ? Theme.primary : Color.white)
            .cornerRadius(Theme.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                    .stroke(Theme.primary, lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuestionnaireView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionnaireView()
            .environmentObject(AuthService.shared)
    }
}

struct BudgetSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetSelectionView()
    }
}