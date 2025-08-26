//
//  SkinProfile.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import Foundation

// MARK: - Skin Profile
struct SkinProfile: Codable, Equatable {
    enum BaseType: String, CaseIterable, Codable {
        case oily = "oily"
        case combination = "combination"
        case dry = "dry"
        case normal = "normal"
        
        var displayName: String {
            switch self {
            case .oily: return "Oily"
            case .combination: return "Combination"
            case .dry: return "Dry"
            case .normal: return "Normal"
            }
        }
        
        var description: String {
            switch self {
            case .oily: return "Shiny throughout, enlarged pores"
            case .combination: return "Oily T-zone, dry or normal cheeks"
            case .dry: return "Tight feeling, flaky patches"
            case .normal: return "Balanced, minimal issues"
            }
        }
    }
    
    var baseType: BaseType
    var sensitive: Bool
    var acneProne: Bool
    var pigmentationProne: Bool
    var rosaceaProne: Bool
    var source: String // "questionnaire" | "mixed" | "scan"
    var lastUpdated: Date
    
    init(baseType: BaseType = .normal, 
         sensitive: Bool = false, 
         acneProne: Bool = false, 
         pigmentationProne: Bool = false, 
         rosaceaProne: Bool = false,
         source: String = "questionnaire") {
        self.baseType = baseType
        self.sensitive = sensitive
        self.acneProne = acneProne
        self.pigmentationProne = pigmentationProne
        self.rosaceaProne = rosaceaProne
        self.source = source
        self.lastUpdated = Date()
    }
}

// MARK: - Scan Observations
struct ScanObservations: Codable {
    let oilinessTZone: Double
    let erythema: Double
    let poreVisibility: Double
    let activeLesions: Int
    let postInflammatoryHyperpigmentation: Double
    let textureRoughness: Double
    let confidence: Double
    let capturedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case oilinessTZone = "oiliness_tzone"
        case erythema = "erythema"
        case poreVisibility = "pore_visibility"
        case activeLesions = "active_lesions"
        case postInflammatoryHyperpigmentation = "post_inflammatory_hyperpigmentation"
        case textureRoughness = "texture_roughness"
        case confidence = "confidence"
        case capturedAt = "captured_at"
    }
}

// MARK: - Scan Result
struct ScanResult: Codable {
    let version: String
    let baseType: String
    let modifiers: [String: Bool]
    let observations: ScanObservations
    
    enum CodingKeys: String, CodingKey {
        case version = "version"
        case baseType = "base_type"
        case modifiers = "modifiers"
        case observations = "observations"
    }
    
    func toSkinProfile() -> SkinProfile {
        let type = SkinProfile.BaseType(rawValue: baseType) ?? .normal
        return SkinProfile(
            baseType: type,
            sensitive: modifiers["sensitive"] ?? false,
            acneProne: modifiers["acne_prone"] ?? false,
            pigmentationProne: modifiers["pigmentation_prone"] ?? false,
            rosaceaProne: modifiers["rosacea_prone"] ?? false,
            source: "scan"
        )
    }
}