//
//  RoutineStore.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import Foundation

// MARK: - Routine Store
final class RoutineStore: ObservableObject {
    @Published var currentRoutine: Routine = .empty
    @Published var isGenerating: Bool = false
    @Published var completedSteps: Set<String> = []
    
    private let catalogStore = CatalogStore.shared
    private let remoteConfig = RemoteConfigService.shared
    
    // MARK: - Routine Generation
    func generateRoutine(profile: SkinProfile, preferences: Preferences, creatorSeed: String? = nil) async {
        DispatchQueue.main.async { [weak self] in
            self?.isGenerating = true
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        let routine = await generateMockRoutine(profile: profile, preferences: preferences)
        
        DispatchQueue.main.async { [weak self] in
            self?.currentRoutine = routine
            self?.isGenerating = false
            self?.saveRoutineToDefaults(routine)
        }
    }
    
    private func generateMockRoutine(profile: SkinProfile, preferences: Preferences) async -> Routine {
        let template = RoutineTemplate.defaultTemplate()
        
        // Generate AM steps
        let amSteps = template.amSteps.compactMap { stepType -> RoutineStep? in
            guard let product = selectProduct(for: stepType, preferences: preferences, profile: profile) else {
                return nil
            }
            
            return RoutineStep(
                id: UUID().uuidString,
                stepType: stepType,
                productId: product.id,
                alternatives: product.alternatives ?? [],
                explanation: generateExplanation(for: product, stepType: stepType, profile: profile)
            )
        }
        
        // Generate PM steps
        let pmSteps = template.pmSteps.compactMap { stepType -> RoutineStep? in
            let effectiveStepType: String
            
            // Handle serum_or_retinoid logic
            if stepType == "serum_or_retinoid" {
                // Use retinoid if pregnancy-safe toggle is off and user is not sensitive
                let canUseRetinoid = !preferences.safety.pregnancySafe && !profile.sensitive
                effectiveStepType = canUseRetinoid ? "retinoid" : "serum"
            } else {
                effectiveStepType = stepType
            }
            
            guard let product = selectProduct(for: effectiveStepType, preferences: preferences, profile: profile) else {
                return nil
            }
            
            return RoutineStep(
                id: UUID().uuidString,
                stepType: effectiveStepType,
                productId: product.id,
                alternatives: product.alternatives ?? [],
                explanation: generateExplanation(for: product, stepType: effectiveStepType, profile: profile)
            )
        }
        
        return Routine(
            am: amSteps,
            pm: pmSteps,
            weekly: template.weeklyPlan,
            rulesVersion: "mock-1",
            catalogVersion: remoteConfig.catalogVersion,
            overrides: [:]
        )
    }
    
    private func selectProduct(for stepType: String, preferences: Preferences, profile: SkinProfile) -> Product? {
        let candidates = catalogStore.products(by: stepType, matching: preferences)
        
        if candidates.isEmpty {
            // Fallback to any product of this step type if none match preferences
            return catalogStore.products(by: stepType).first
        }
        
        // Score products based on profile match
        let scoredCandidates = candidates.map { product in
            (product: product, score: scoreProduct(product, for: profile, preferences: preferences))
        }
        
        // Return the highest scoring product
        return scoredCandidates.max(by: { $0.score < $1.score })?.product
    }
    
    private func scoreProduct(_ product: Product, for profile: SkinProfile, preferences: Preferences) -> Double {
        var score: Double = 0.0
        
        // Budget match bonus
        if product.matchesBudget(preferences.budgetTier) {
            score += 10.0
        }
        
        // Safety flags bonus
        let matchingFlags = Set(product.flags).intersection(preferences.safety.asFlagSet()).count
        score += Double(matchingFlags) * 5.0
        
        // Profile-specific bonuses
        if profile.sensitive && product.hasFlag("fragrance_free") {
            score += 3.0
        }
        
        if profile.acneProne && product.inciHighlights.contains(where: { 
            $0.lowercased().contains("niacinamide") || $0.lowercased().contains("salicylic")
        }) {
            score += 3.0
        }
        
        if profile.pigmentationProne && product.inciHighlights.contains(where: {
            $0.lowercased().contains("vitamin c") || $0.lowercased().contains("ascorbic")
        }) {
            score += 3.0
        }
        
        // Price preference
        switch preferences.budgetTier {
        case .value:
            if product.priceBand == "$" { score += 5.0 }
        case .balanced:
            if product.priceBand == "$$" { score += 5.0 }
            else if product.priceBand == "$" { score += 3.0 }
        case .premium:
            if product.priceBand == "$$$" { score += 5.0 }
            else if product.priceBand == "$$" { score += 3.0 }
        }
        
        return score
    }
    
    private func generateExplanation(for product: Product, stepType: String, profile: SkinProfile) -> String {
        var reasons: [String] = []
        
        // Step-specific explanations
        switch stepType {
        case "cleanser":
            reasons.append("Gentle cleansing for your skin type")
        case "essence":
            reasons.append("Hydrates and preps skin")
        case "serum":
            if product.inciHighlights.contains(where: { $0.lowercased().contains("niacinamide") }) {
                reasons.append("Controls oil and minimizes pores")
            } else if product.inciHighlights.contains(where: { $0.lowercased().contains("vitamin c") }) {
                reasons.append("Brightens and evens skin tone")
            } else {
                reasons.append("Targeted treatment for your concerns")
            }
        case "moisturizer":
            reasons.append("Seals in hydration and strengthens barrier")
        case "sunscreen":
            reasons.append("Essential daily protection")
        case "retinoid":
            reasons.append("Anti-aging and pore refinement")
        case "exfoliant":
            reasons.append("Weekly gentle resurfacing")
        default:
            reasons.append("Matches your skin profile")
        }
        
        // Profile-specific additions
        if profile.sensitive && product.isFragranceFree {
            reasons.append("fragrance-free for sensitivity")
        }
        
        if product.priceBand == "$" {
            reasons.append("great value option")
        }
        
        return reasons.joined(separator: ", ").capitalized
    }
    
    // MARK: - Step Management
    func toggleStepCompletion(_ stepId: String) {
        if completedSteps.contains(stepId) {
            completedSteps.remove(stepId)
        } else {
            completedSteps.insert(stepId)
            HapticFeedback.light()
        }
        saveCompletedStepsToDefaults()
    }
    
    func isStepCompleted(_ stepId: String) -> Bool {
        return completedSteps.contains(stepId)
    }
    
    // MARK: - Overrides
    func applyOverride(stepType: String, newProductId: String) {
        var updatedOverrides = currentRoutine.overrides
        updatedOverrides[stepType] = newProductId
        
        currentRoutine = Routine(
            am: currentRoutine.am,
            pm: currentRoutine.pm,
            weekly: currentRoutine.weekly,
            rulesVersion: currentRoutine.rulesVersion,
            catalogVersion: currentRoutine.catalogVersion,
            overrides: updatedOverrides
        )
        
        saveRoutineToDefaults(currentRoutine)
        HapticFeedback.success()
    }
    
    func removeOverride(stepType: String) {
        var updatedOverrides = currentRoutine.overrides
        updatedOverrides.removeValue(forKey: stepType)
        
        currentRoutine = Routine(
            am: currentRoutine.am,
            pm: currentRoutine.pm,
            weekly: currentRoutine.weekly,
            rulesVersion: currentRoutine.rulesVersion,
            catalogVersion: currentRoutine.catalogVersion,
            overrides: updatedOverrides
        )
        
        saveRoutineToDefaults(currentRoutine)
    }
    
    // MARK: - Persistence
    private func saveRoutineToDefaults(_ routine: Routine) {
        if let encoded = try? JSONEncoder().encode(routine) {
            UserDefaults.standard.set(encoded, forKey: "currentRoutine")
        }
    }
    
    private func saveCompletedStepsToDefaults() {
        let stepsArray = Array(completedSteps)
        UserDefaults.standard.set(stepsArray, forKey: "completedSteps")
    }
    
    func loadRoutineFromDefaults() {
        if let data = UserDefaults.standard.data(forKey: "currentRoutine"),
           let routine = try? JSONDecoder().decode(Routine.self, from: data) {
            currentRoutine = routine
        }
        
        if let stepsArray = UserDefaults.standard.array(forKey: "completedSteps") as? [String] {
            completedSteps = Set(stepsArray)
        }
    }
}