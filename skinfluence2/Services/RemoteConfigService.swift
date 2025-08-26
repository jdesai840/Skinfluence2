//
//  RemoteConfigService.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import Foundation

// MARK: - Remote Config Service
final class RemoteConfigService: ObservableObject {
    static let shared = RemoteConfigService()
    
    @Published private var config: [String: Any] = [:]
    
    private init() {
        loadDefaults()
        // TODO: Initialize Firebase Remote Config in Phase 2
    }
    
    private func loadDefaults() {
        config = [
            "useMockScan": true,
            "useMockRecommend": true,
            "catalogVersion": "v1",
            "enablePro": true,
            "enableSharing": true,
            "enableAdherence": true,
            "maxAlternatives": 3,
            "scanConfidenceThreshold": 0.7
        ]
    }
    
    // MARK: - Feature Flags
    var useMockScan: Bool {
        return config["useMockScan"] as? Bool ?? true
    }
    
    var useMockRecommend: Bool {
        return config["useMockRecommend"] as? Bool ?? true
    }
    
    var catalogVersion: String {
        return config["catalogVersion"] as? String ?? "v1"
    }
    
    var enablePro: Bool {
        return config["enablePro"] as? Bool ?? true
    }
    
    var enableSharing: Bool {
        return config["enableSharing"] as? Bool ?? true
    }
    
    var enableAdherence: Bool {
        return config["enableAdherence"] as? Bool ?? true
    }
    
    var maxAlternatives: Int {
        return config["maxAlternatives"] as? Int ?? 3
    }
    
    var scanConfidenceThreshold: Double {
        return config["scanConfidenceThreshold"] as? Double ?? 0.7
    }
    
    // MARK: - Configuration Updates
    func updateConfig(_ key: String, value: Any) {
        config[key] = value
        objectWillChange.send()
    }
    
    func fetchRemoteConfig() async {
        // TODO: Implement Firebase Remote Config fetch
        // For now, we'll simulate a remote fetch delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
    }
}