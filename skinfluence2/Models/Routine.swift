//
//  Routine.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import Foundation

// MARK: - Routine Step
struct RoutineStep: Codable, Identifiable, Equatable {
    let id: String
    let stepType: String
    let productId: String
    let alternatives: [String]
    let explanation: String
    
    var stepTypeDisplayName: String {
        switch stepType {
        case "cleanser": return "Cleanser"
        case "essence": return "Essence"
        case "serum": return "Serum"
        case "serum_or_retinoid": return "Treatment"
        case "moisturizer": return "Moisturizer"
        case "sunscreen": return "Sunscreen"
        case "retinoid": return "Retinoid"
        case "exfoliant": return "Exfoliant"
        case "mask": return "Mask"
        default: return stepType.capitalized
        }
    }
}

// MARK: - Weekly Plan
struct WeeklyPlan: Codable, Equatable {
    let retinoidNights: [String]
    let exfoliantDays: [String]
    let maskDays: [String]
    
    static func template() -> WeeklyPlan {
        WeeklyPlan(
            retinoidNights: ["Mon", "Thu"],
            exfoliantDays: ["Wed"],
            maskDays: ["Fri"]
        )
    }
    
    var allScheduledDays: Set<String> {
        Set(retinoidNights + exfoliantDays + maskDays)
    }
    
    func isScheduledDay(_ day: String, for type: String) -> Bool {
        switch type {
        case "retinoid":
            return retinoidNights.contains(day)
        case "exfoliant":
            return exfoliantDays.contains(day)
        case "mask":
            return maskDays.contains(day)
        default:
            return false
        }
    }
}

// MARK: - Routine
struct Routine: Codable, Equatable {
    let am: [RoutineStep]
    let pm: [RoutineStep]
    let weekly: WeeklyPlan
    let rulesVersion: String
    let catalogVersion: String
    var overrides: [String: String] // stepType -> productId
    let generatedAt: Date
    
    init(am: [RoutineStep], 
         pm: [RoutineStep], 
         weekly: WeeklyPlan = .template(),
         rulesVersion: String = "mock-1",
         catalogVersion: String = "v1",
         overrides: [String: String] = [:]) {
        self.am = am
        self.pm = pm
        self.weekly = weekly
        self.rulesVersion = rulesVersion
        self.catalogVersion = catalogVersion
        self.overrides = overrides
        self.generatedAt = Date()
    }
    
    static let empty = Routine(
        am: [],
        pm: [],
        weekly: .template(),
        rulesVersion: "mock-1",
        catalogVersion: "v1",
        overrides: [:]
    )
    
    func step(for stepType: String, isAM: Bool) -> RoutineStep? {
        let steps = isAM ? am : pm
        return steps.first { $0.stepType == stepType }
    }
    
    func hasOverride(for stepType: String) -> Bool {
        return overrides[stepType] != nil
    }
    
    func effectiveProductId(for stepType: String, isAM: Bool) -> String? {
        if let override = overrides[stepType] {
            return override
        }
        return step(for: stepType, isAM: isAM)?.productId
    }
}

// MARK: - Adherence Entry
struct AdherenceEntry: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let moodScore: Double // 1-5 scale
    let skinScore: Double // 1-5 scale
    let note: String?
    let completedSteps: Set<String> // step IDs that were completed
    
    init(date: Date = Date(),
         moodScore: Double,
         skinScore: Double,
         note: String? = nil,
         completedSteps: Set<String> = []) {
        self.date = date
        self.moodScore = moodScore
        self.skinScore = skinScore
        self.note = note
        self.completedSteps = completedSteps
    }
    
    var averageScore: Double {
        (moodScore + skinScore) / 2.0
    }
}

// MARK: - Routine Template
struct RoutineTemplate: Codable {
    let amSteps: [String]
    let pmSteps: [String]
    let weeklyPlan: WeeklyPlan
    let notes: String
    
    static func defaultTemplate() -> RoutineTemplate {
        return RoutineTemplate(
            amSteps: ["cleanser", "essence", "serum", "moisturizer", "sunscreen"],
            pmSteps: ["cleanser", "essence", "serum_or_retinoid", "moisturizer"],
            weeklyPlan: .template(),
            notes: "Avoid stacking strong AHA/BHA with retinoid on same night. Use vitamin C AM on non-exfoliation days."
        )
    }
}