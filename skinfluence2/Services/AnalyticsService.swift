//
//  AnalyticsService.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import Foundation

// MARK: - Analytics Event
struct AnalyticsEvent {
    let name: String
    let properties: [String: Any]
    let timestamp: Date
    
    init(name: String, properties: [String: Any] = [:]) {
        self.name = name
        self.properties = properties
        self.timestamp = Date()
    }
}

// MARK: - Analytics Service
final class AnalyticsService: ObservableObject {
    static let shared = AnalyticsService()
    
    @Published private(set) var isEnabled: Bool = true
    private var eventQueue: [AnalyticsEvent] = []
    
    private init() {
        loadAnalyticsPreference()
    }
    
    // MARK: - Event Tracking
    func track(_ eventName: String, properties: [String: Any] = [:]) {
        guard isEnabled else { return }
        
        var enrichedProperties = properties
        
        // Add standard properties
        enrichedProperties["platform"] = "ios"
        enrichedProperties["app_version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        enrichedProperties["timestamp"] = ISO8601DateFormatter().string(from: Date())
        
        // Add user context if available
        if let user = AuthService.shared.currentUser {
            enrichedProperties["user_id"] = user.id
            enrichedProperties["user_created_at"] = ISO8601DateFormatter().string(from: user.createdAt)
            enrichedProperties["has_pro"] = user.proStatus.hasActiveSubscription
            
            if let profile = user.profile {
                enrichedProperties["skin_type"] = profile.baseType.rawValue
                enrichedProperties["profile_source"] = profile.source
            }
            
            enrichedProperties["budget_tier"] = user.preferences.budgetTier.rawValue
            enrichedProperties["safety_toggles"] = [
                "pregnancy_safe": user.preferences.safety.pregnancySafe,
                "fragrance_free": user.preferences.safety.fragranceFree,
                "eo_free": user.preferences.safety.essentialOilFree,
                "alcohol_denat_free": user.preferences.safety.alcoholDenatFree
            ]
        }
        
        // Add remote config context
        let remoteConfig = RemoteConfigService.shared
        enrichedProperties["catalog_version"] = remoteConfig.catalogVersion
        enrichedProperties["rules_version"] = "mock-1" // TODO: Get from actual rules engine
        
        let event = AnalyticsEvent(name: eventName, properties: enrichedProperties)
        eventQueue.append(event)
        
        // In production, this would send to analytics service
        print("📊 Analytics: \(eventName) - \(enrichedProperties)")
        
        // Flush queue periodically
        if eventQueue.count >= 10 {
            flushEvents()
        }
    }
    
    // MARK: - Specific Event Methods
    func trackAppOpen() {
        track("app_open")
    }
    
    func trackLogin(method: String, success: Bool) {
        track(success ? "login_success" : "login_failure", properties: [
            "method": method
        ])
    }
    
    func trackOnboardingCompleted(duration: TimeInterval) {
        track("onboarding_completed", properties: [
            "duration_seconds": duration
        ])
    }
    
    func trackScanPerformed(confidence: Double, qualityIssues: [String]) {
        track(confidence >= RemoteConfigService.shared.scanConfidenceThreshold ? "scan_success" : "scan_failure", properties: [
            "confidence": confidence,
            "quality_issues": qualityIssues
        ])
    }
    
    func trackRoutineGenerated(profileType: String, budgetTier: String, duration: TimeInterval) {
        track("routine_generated", properties: [
            "profile_type": profileType,
            "budget_tier": budgetTier,
            "generation_duration_ms": duration * 1000
        ])
    }
    
    func trackProductSwap(fromProductId: String, toProductId: String, stepType: String) {
        track("swap_applied", properties: [
            "from_product_id": fromProductId,
            "to_product_id": toProductId,
            "step_type": stepType
        ])
    }
    
    func trackRoutineShare(method: String) {
        track("share_routine", properties: [
            "method": method
        ])
    }
    
    func trackAdherenceLog(moodScore: Double, skinScore: Double) {
        track("adherence_log", properties: [
            "mood_score": moodScore,
            "skin_score": skinScore,
            "average_score": (moodScore + skinScore) / 2.0
        ])
    }
    
    func trackProSubscription(action: String, product: String? = nil) {
        var properties: [String: Any] = ["action": action]
        if let product = product {
            properties["product"] = product
        }
        track("pro_\(action)", properties: properties)
    }
    
    func trackOutboundClick(productId: String, retailer: String, stepType: String) {
        track("outbound_click", properties: [
            "product_id": productId,
            "retailer": retailer,
            "step_type": stepType
        ])
    }
    
    func trackSearch(query: String, resultsCount: Int) {
        track("search_performed", properties: [
            "query": query,
            "results_count": resultsCount,
            "query_length": query.count
        ])
    }
    
    func trackDiscoverImpression(productIds: [String], filters: [String]) {
        track("discover_impression", properties: [
            "product_ids": productIds,
            "filters": filters,
            "product_count": productIds.count
        ])
    }
    
    func trackPreferencesUpdated(changes: [String: Any]) {
        track("profile_saved", properties: changes)
    }
    
    // MARK: - Privacy Controls
    func setAnalyticsEnabled(_ enabled: Bool) {
        isEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "analytics_enabled")
        
        if !enabled {
            eventQueue.removeAll()
        }
        
        track("analytics_opt_out", properties: ["enabled": enabled])
    }
    
    private func loadAnalyticsPreference() {
        // Analytics enabled by default, user can opt out
        if UserDefaults.standard.object(forKey: "analytics_enabled") != nil {
            isEnabled = UserDefaults.standard.bool(forKey: "analytics_enabled")
        }
    }
    
    // MARK: - Event Flushing
    private func flushEvents() {
        // TODO: In production, send events to analytics service (Mixpanel, Amplitude, etc.)
        // For Phase 1, we just clear the queue
        eventQueue.removeAll()
    }
    
    func flushAllEvents() {
        flushEvents()
    }
}

// MARK: - Analytics Events Constants
enum AnalyticsEvents {
    // App lifecycle
    static let appOpen = "app_open"
    static let appBackground = "app_background"
    static let appForeground = "app_foreground"
    
    // Authentication
    static let loginStart = "login_start"
    static let loginSuccess = "login_success"
    static let loginFailure = "login_failure"
    static let signOut = "sign_out"
    
    // Onboarding
    static let onboardingStarted = "onboarding_started"
    static let onboardingCompleted = "onboarding_completed"
    static let ageGatePassed = "age_gate_passed"
    static let consentGiven = "consent_given"
    static let budgetSet = "budget_set"
    static let safetyTogglesSet = "safety_toggles_saved"
    static let retailerOrderSaved = "retailer_order_saved"
    
    // Scanning
    static let scanGuideViewed = "scan_guide_view"
    static let scanCaptured = "scan_capture"
    static let scanSuccess = "scan_success"
    static let scanFailure = "scan_failure"
    static let scanApplyHints = "scan_apply_hints"
    static let scanIgnoreHints = "scan_ignore_hints"
    
    // Profile & Questionnaire
    static let questionnaireCompleted = "questionnaire_completed"
    static let profileSaved = "profile_saved"
    
    // Routine
    static let routineGenerated = "routine_generated"
    static let stepChecked = "step_checked"
    static let weeklyPlanViewed = "weekly_plan_view"
    
    // Product & Swaps
    static let swapOpened = "swap_open"
    static let swapApplied = "swap_applied"
    static let overrideOriginal = "override_original"
    static let outboundClick = "outbound_click"
    
    // Discovery & Search
    static let discoverImpression = "discover_impression"
    static let discoverOpenProduct = "discover_open_product"
    static let searchPerformed = "search_performed"
    static let searchResultOpen = "search_result_open"
    
    // Sharing
    static let shareRoutine = "share_routine"
    
    // Adherence
    static let adherenceLog = "adherence_log"
    static let photoCaptured = "photo_captured"
    static let vaultOpened = "vault_opened"
    
    // Reminders
    static let reminderSet = "reminder_set"
    static let reminderToggle = "reminder_toggle"
    
    // Pro/Paywall
    static let paywallView = "paywall_view"
    static let proStart = "pro_start"
    static let proRestore = "pro_restore"
    static let proRenew = "pro_renew"
    static let referralRedeemed = "referral_redeemed"
    
    // Settings
    static let settingsOpen = "settings_open"
    static let analyticsOptOut = "analytics_opt_out"
}