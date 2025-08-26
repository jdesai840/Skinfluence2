//
//  ProfileStore.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import Foundation
import SwiftUI

// MARK: - Profile Store
@MainActor
final class ProfileStore: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isLoading: Bool = false
    @Published var lastSavedDate: Date?
    
    // MARK: - Private Properties
    private let userDefaultsKey = "currentUser"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init() {
        setupEncoders()
    }
    
    // MARK: - Setup
    private func setupEncoders() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Profile Management
    
    /// Saves the user profile with validation and persistence
    func saveProfile(_ user: AppUser) async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Validate the profile data
        try validateProfile(user)
        
        // Simulate network delay for better UX feedback
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Save to UserDefaults (Phase 1 implementation)
        try saveToUserDefaults(user)
        
        // Update last saved date
        lastSavedDate = Date()
        
        // Log analytics event
        await logProfileUpdateEvent(user)
    }
    
    /// Loads the current user profile from persistent storage
    func loadProfile() throws -> AppUser? {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return nil
        }
        
        let user = try decoder.decode(AppUser.self, from: data)
        return user
    }
    
    /// Updates specific profile preferences without full save
    func updatePreferences(_ preferences: Preferences, for user: inout AppUser) throws {
        user.updatePreferences(preferences)
        try saveToUserDefaults(user)
        lastSavedDate = Date()
    }
    
    /// Updates skin profile without full save
    func updateSkinProfile(_ profile: SkinProfile, for user: inout AppUser) throws {
        user.updateProfile(profile)
        try saveToUserDefaults(user)
        lastSavedDate = Date()
    }
    
    /// Clears all profile data
    func clearProfile() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        lastSavedDate = nil
    }
    
    // MARK: - Validation
    private func validateProfile(_ user: AppUser) throws {
        // Validate required consents
        guard user.consents.hasRequiredConsents else {
            throw ProfileStoreError.missingRequiredConsents
        }
        
        // Validate skin profile if present
        if let profile = user.profile {
            try validateSkinProfile(profile)
        }
        
        // Validate preferences
        try validatePreferences(user.preferences)
    }
    
    private func validateSkinProfile(_ profile: SkinProfile) throws {
        // Skin profile validation logic
        if profile.lastUpdated > Date() {
            throw ProfileStoreError.invalidTimestamp
        }
    }
    
    private func validatePreferences(_ preferences: Preferences) throws {
        // Validate retailer order
        guard !preferences.retailerOrder.isEmpty else {
            throw ProfileStoreError.invalidRetailerOrder
        }
        
        // Validate budget tier
        guard BudgetTier.allCases.contains(preferences.budgetTier) else {
            throw ProfileStoreError.invalidBudgetTier
        }
        
        // Validate safety flags are reasonable
        let safetyFlags = preferences.safety.asFlagSet()
        guard safetyFlags.count <= SafetyToggles.allFlags.count else {
            throw ProfileStoreError.invalidSafetyFlags
        }
    }
    
    // MARK: - Persistence
    private func saveToUserDefaults(_ user: AppUser) throws {
        let data = try encoder.encode(user)
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }
    
    // MARK: - Analytics
    private func logProfileUpdateEvent(_ user: AppUser) async {
        // Log profile update for analytics
        let event = ProfileUpdateEvent(
            userId: user.id,
            hasProfile: user.profile != nil,
            budgetTier: user.preferences.budgetTier.rawValue,
            safetyFlags: user.preferences.safety.asFlagSet(),
            retailerCount: user.preferences.retailerOrder.count,
            updatedAt: Date()
        )
        
        // In a real implementation, this would send to analytics service
        print("Profile updated: \(event)")
    }
}

// MARK: - Profile Store Errors
enum ProfileStoreError: Error, LocalizedError {
    case missingRequiredConsents
    case invalidTimestamp
    case invalidRetailerOrder
    case invalidBudgetTier
    case invalidSafetyFlags
    case encodingError
    case decodingError
    case networkError
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .missingRequiredConsents:
            return "Please accept the required privacy and image processing consents."
        case .invalidTimestamp:
            return "Profile contains invalid timestamp data."
        case .invalidRetailerOrder:
            return "Please select at least one preferred retailer."
        case .invalidBudgetTier:
            return "Please select a valid budget preference."
        case .invalidSafetyFlags:
            return "Safety preferences contain invalid options."
        case .encodingError:
            return "Failed to save profile data."
        case .decodingError:
            return "Failed to load profile data."
        case .networkError:
            return "Network error occurred while saving profile."
        case .unknownError:
            return "An unexpected error occurred."
        }
    }
}

// MARK: - Analytics Event Model
struct ProfileUpdateEvent {
    let userId: String
    let hasProfile: Bool
    let budgetTier: String
    let safetyFlags: Set<String>
    let retailerCount: Int
    let updatedAt: Date
}