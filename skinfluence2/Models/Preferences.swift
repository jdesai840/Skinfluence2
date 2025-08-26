//
//  Preferences.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import Foundation

// MARK: - Budget Tier
enum BudgetTier: String, CaseIterable, Codable {
    case value = "value"
    case balanced = "balanced"
    case premium = "premium"
    
    var displayName: String {
        switch self {
        case .value: return "Value"
        case .balanced: return "Balanced"
        case .premium: return "Premium"
        }
    }
    
    var description: String {
        switch self {
        case .value: return "Budget-friendly options"
        case .balanced: return "Quality and value balance"
        case .premium: return "High-end products"
        }
    }
    
    var priceBands: [String] {
        switch self {
        case .value: return ["$"]
        case .balanced: return ["$", "$$"]
        case .premium: return ["$$", "$$$"]
        }
    }
    
    var priceRange: String {
        switch self {
        case .value: return "$5 - $25"
        case .balanced: return "$15 - $60"
        case .premium: return "$50 - $150+"
        }
    }
}

// MARK: - Routine Size
enum RoutineSize: String, CaseIterable, Codable {
    case minimal = "minimal"
    case classic = "classic"
    case maximal = "maximal"
    
    var displayName: String {
        switch self {
        case .minimal: return "Minimal"
        case .classic: return "Classic"
        case .maximal: return "Maximal"
        }
    }
    
    var description: String {
        switch self {
        case .minimal: return "Essentials only, perfect for busy mornings"
        case .classic: return "The sweet spot for most skin"
        case .maximal: return "Full K-beauty inspired routine"
        }
    }
    
    var stepCount: String {
        switch self {
        case .minimal: return "3 steps"
        case .classic: return "5 steps"
        case .maximal: return "7+ steps"
        }
    }
    
    var timeEstimate: String {
        switch self {
        case .minimal: return "5 mins"
        case .classic: return "10 mins"
        case .maximal: return "15 mins"
        }
    }
    
    var emoji: String {
        switch self {
        case .minimal: return "🌸"
        case .classic: return "💫"
        case .maximal: return "🦋"
        }
    }
}

// MARK: - Actives Comfort
enum ActivesComfort: String, CaseIterable, Codable {
    case newbie = "newbie"
    case someExperience = "some_experience"
    case confident = "confident"
    
    var displayName: String {
        switch self {
        case .newbie: return "New to actives"
        case .someExperience: return "Some experience"
        case .confident: return "Confident"
        }
    }
    
    var description: String {
        switch self {
        case .newbie: return "Let's start gentle and build up slowly"
        case .someExperience: return "Ready to explore with guidance"
        case .confident: return "Bring on the powerful ingredients!"
        }
    }
    
    var subtitle: String {
        switch self {
        case .newbie: return "I'm new to actives"
        case .someExperience: return "I've tried a few"
        case .confident: return "I know my skin well"
        }
    }
    
    var examples: String {
        switch self {
        case .newbie: return "Basic moisturizers • Gentle cleansers • Mild exfoliants"
        case .someExperience: return "Retinol • Vitamin C • AHAs/BHAs • Niacinamide"
        case .confident: return "Prescription retinoids • High % acids • Combination actives"
        }
    }
    
    var emoji: String {
        switch self {
        case .newbie: return "🌱"
        case .someExperience: return "🌸"
        case .confident: return "💪"
        }
    }
}

// MARK: - Safety Toggles
struct SafetyToggles: Codable, Equatable {
    var pregnancySafe: Bool
    var fragranceFree: Bool
    var essentialOilFree: Bool
    var alcoholDenatFree: Bool
    
    init(pregnancySafe: Bool = false,
         fragranceFree: Bool = false,
         essentialOilFree: Bool = false,
         alcoholDenatFree: Bool = false) {
        self.pregnancySafe = pregnancySafe
        self.fragranceFree = fragranceFree
        self.essentialOilFree = essentialOilFree
        self.alcoholDenatFree = alcoholDenatFree
    }
    
    func asFlagSet() -> Set<String> {
        var flags: Set<String> = []
        
        if fragranceFree {
            flags.insert("fragrance_free")
        }
        if essentialOilFree {
            flags.insert("eo_free")
        }
        if alcoholDenatFree {
            flags.insert("alcohol_denat_free")
        }
        if pregnancySafe {
            flags.insert("pregnancy_safe")
        }
        
        return flags
    }
    
    static let allFlags = ["fragrance_free", "eo_free", "alcohol_denat_free", "pregnancy_safe"]
}

// MARK: - User Preferences
struct Preferences: Codable, Equatable {
    var budgetTier: BudgetTier
    var routineSize: RoutineSize
    var activesComfort: ActivesComfort
    var safety: SafetyToggles
    var retailerOrder: [String]
    var lastUpdated: Date
    
    init(budgetTier: BudgetTier = .balanced,
         routineSize: RoutineSize = .classic,
         activesComfort: ActivesComfort = .newbie,
         safety: SafetyToggles = SafetyToggles(),
         retailerOrder: [String] = ["Amazon", "Sephora", "Olive Young", "YesStyle", "TikTok Shop"]) {
        self.budgetTier = budgetTier
        self.routineSize = routineSize
        self.activesComfort = activesComfort
        self.safety = safety
        self.retailerOrder = retailerOrder
        self.lastUpdated = Date()
    }
}

// MARK: - User Consents
struct UserConsents: Codable {
    var privacyPolicy: Bool
    var imageProcessing: Bool
    var marketing: Bool
    var consentDate: Date
    
    init(privacyPolicy: Bool = false,
         imageProcessing: Bool = false,
         marketing: Bool = false) {
        self.privacyPolicy = privacyPolicy
        self.imageProcessing = imageProcessing
        self.marketing = marketing
        self.consentDate = Date()
    }
    
    var hasRequiredConsents: Bool {
        return privacyPolicy && imageProcessing
    }
}

// MARK: - Pro Status
struct ProStatus: Codable {
    var isActive: Bool
    var subscriptionType: String? // "monthly", "yearly"
    var expiresAt: Date?
    var tempUntil: Date? // For referral codes
    var purchasedAt: Date?
    
    init() {
        self.isActive = false
        self.subscriptionType = nil
        self.expiresAt = nil
        self.tempUntil = nil
        self.purchasedAt = nil
    }
    
    var hasActiveSubscription: Bool {
        if let tempUntil = tempUntil, tempUntil > Date() {
            return true
        }
        
        if let expiresAt = expiresAt {
            return isActive && expiresAt > Date()
        }
        
        return false
    }
}