//
//  Product.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import Foundation

// MARK: - Product
struct Product: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let brand: String
    let name: String
    let stepType: String
    let flags: [String]
    let inciHighlights: [String]
    let priceBand: String
    let images: [String]
    let alternatives: [String]?
    
    var displayName: String {
        "\(brand) \(name)"
    }
    
    var hasFlag(_ flag: String) -> Bool {
        flags.contains(flag)
    }
    
    var isPregnancySafe: Bool {
        hasFlag("pregnancy_safe")
    }
    
    var isFragranceFree: Bool {
        hasFlag("fragrance_free")
    }
    
    var isEssentialOilFree: Bool {
        hasFlag("eo_free")
    }
    
    var isAlcoholDenatFree: Bool {
        hasFlag("alcohol_denat_free")
    }
    
    var badges: [String] {
        var badges: [String] = []
        
        if isPregnancySafe {
            badges.append("Pregnancy Safe")
        }
        if isFragranceFree {
            badges.append("Fragrance Free")
        }
        if priceBand == "$" {
            badges.append("Best Value")
        }
        
        return badges
    }
    
    var stepTypeDisplayName: String {
        switch stepType {
        case "cleanser": return "Cleanser"
        case "essence": return "Essence"
        case "serum": return "Serum"
        case "moisturizer": return "Moisturizer"
        case "sunscreen": return "Sunscreen"
        case "retinoid": return "Retinoid"
        case "exfoliant": return "Exfoliant"
        case "mask": return "Mask"
        default: return stepType.capitalized
        }
    }
}

// MARK: - Retail Link
struct RetailLink: Codable, Identifiable {
    let id = UUID()
    let retailer: String
    let url: String
    let price: String?
    let currency: String?
    let inStock: Bool
    
    init(retailer: String, url: String, price: String? = nil, currency: String? = "USD", inStock: Bool = true) {
        self.retailer = retailer
        self.url = url
        self.price = price
        self.currency = currency
        self.inStock = inStock
    }
    
    var displayPrice: String {
        guard let price = price, let currency = currency else {
            return "Check Price"
        }
        return "\(currency == "USD" ? "$" : "")\(price)"
    }
}

// MARK: - Product Extensions
extension Product {
    static let stepTypes = [
        "cleanser", "essence", "serum", "moisturizer", 
        "sunscreen", "retinoid", "exfoliant", "mask"
    ]
    
    static let allFlags = [
        "fragrance_free", "eo_free", "alcohol_denat_free", "pregnancy_safe"
    ]
    
    func matchesPreferences(_ preferences: Preferences) -> Bool {
        let requiredFlags = preferences.safety.asFlagSet()
        return requiredFlags.isSubset(of: Set(flags))
    }
    
    func matchesBudget(_ budgetTier: BudgetTier) -> Bool {
        return budgetTier.priceBands.contains(priceBand)
    }
}