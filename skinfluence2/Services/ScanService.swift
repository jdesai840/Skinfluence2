//
//  ScanService.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import Foundation
import AVFoundation
import UIKit

// MARK: - Scan Service
final class ScanService: ObservableObject {
    @Published var isCapturing: Bool = false
    @Published var capturedImage: UIImage?
    @Published var scanResult: ScanResult?
    @Published var qualityIssues: [ScanQualityIssue] = []
    
    private let remoteConfig = RemoteConfigService.shared
    
    // MARK: - Scan Quality Issues
    enum ScanQualityIssue {
        case poorLighting
        case blurryImage
        case faceNotCentered
        case faceNotDetected
        case makeupDetected
        
        var title: String {
            switch self {
            case .poorLighting: return "Poor Lighting"
            case .blurryImage: return "Image Too Blurry"
            case .faceNotCentered: return "Face Not Centered"
            case .faceNotDetected: return "Face Not Detected"
            case .makeupDetected: return "Makeup Detected"
            }
        }
        
        var suggestion: String {
            switch self {
            case .poorLighting:
                return "Move to a well-lit area or face a window"
            case .blurryImage:
                return "Hold phone steady and tap to focus"
            case .faceNotCentered:
                return "Center your face in the oval guide"
            case .faceNotDetected:
                return "Make sure your face is clearly visible"
            case .makeupDetected:
                return "Please remove makeup for accurate results"
            }
        }
    }
    
    // MARK: - Permissions
    func requestCameraPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    // MARK: - Image Quality Analysis
    func analyzeImageQuality(_ image: UIImage) -> [ScanQualityIssue] {
        var issues: [ScanQualityIssue] = []
        
        // Mock quality analysis - in production this would use Core ML or image processing
        
        // Check for blur (mock)
        if mockIsBlurry(image) {
            issues.append(.blurryImage)
        }
        
        // Check for lighting (mock)
        if mockIsPoorlyLit(image) {
            issues.append(.poorLighting)
        }
        
        // Check for face detection (mock)
        if !mockHasFaceDetected(image) {
            issues.append(.faceNotDetected)
        } else if !mockIsFaceCentered(image) {
            issues.append(.faceNotCentered)
        }
        
        // Check for makeup (mock)
        if mockHasMakeup(image) {
            issues.append(.makeupDetected)
        }
        
        return issues
    }
    
    // MARK: - Scan Classification
    func classifyImage(_ image: UIImage) async throws -> ScanResult {
        isCapturing = true
        defer { isCapturing = false }
        
        if remoteConfig.useMockScan {
            return try loadMockScanResult()
        } else {
            // TODO: Implement actual GPT-5 classification in Phase 2
            return try await performRemoteScanClassification(image)
        }
    }
    
    private func loadMockScanResult() throws -> ScanResult {
        guard let url = Bundle.main.url(forResource: "scan_mock", withExtension: "json") else {
            throw ScanError.mockDataNotFound
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        
        // Set up date formatter for ISO 8601 dates
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        var result = try decoder.decode(ScanResult.self, from: data)
        
        // Update captured_at to current time
        var observations = result.observations
        let mirror = Mirror(reflecting: observations)
        
        // Create new observations with current timestamp
        result = ScanResult(
            version: result.version,
            baseType: result.baseType,
            modifiers: result.modifiers,
            observations: ScanObservations(
                oilinessTZone: observations.oilinessTZone,
                erythema: observations.erythema,
                poreVisibility: observations.poreVisibility,
                activeLesions: observations.activeLesions,
                postInflammatoryHyperpigmentation: observations.postInflammatoryHyperpigmentation,
                textureRoughness: observations.textureRoughness,
                confidence: observations.confidence,
                capturedAt: Date()
            )
        )
        
        return result
    }
    
    private func performRemoteScanClassification(_ image: UIImage) async throws -> ScanResult {
        // TODO: Implement actual API call to GPT-5 endpoint
        // For now, simulate with a delay and return mock data
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        return try loadMockScanResult()
    }
    
    // MARK: - Mock Quality Checks
    private func mockIsBlurry(_ image: UIImage) -> Bool {
        // In production, this would use actual image analysis
        return Bool.random()
    }
    
    private func mockIsPoorlyLit(_ image: UIImage) -> Bool {
        // In production, this would analyze image brightness/contrast
        return Bool.random()
    }
    
    private func mockHasFaceDetected(_ image: UIImage) -> Bool {
        // In production, this would use Vision framework face detection
        return !Bool.random() // Usually has face detected
    }
    
    private func mockIsFaceCentered(_ image: UIImage) -> Bool {
        // In production, this would check face position relative to image center
        return Bool.random()
    }
    
    private func mockHasMakeup(_ image: UIImage) -> Bool {
        // In production, this might use ML model to detect makeup
        return Bool.random()
    }
    
    // MARK: - Image Processing
    func processImageForUpload(_ image: UIImage) -> UIImage? {
        // Resize image to optimal dimensions for analysis
        let targetSize = CGSize(width: 512, height: 512)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

// MARK: - Scan Errors
enum ScanError: Error, LocalizedError {
    case cameraPermissionDenied
    case captureSessionError
    case imageProcessingError
    case networkError
    case mockDataNotFound
    case invalidResponse
    case confidenceTooLow
    
    var errorDescription: String? {
        switch self {
        case .cameraPermissionDenied:
            return "Camera permission is required for scanning"
        case .captureSessionError:
            return "Camera capture failed"
        case .imageProcessingError:
            return "Failed to process image"
        case .networkError:
            return "Network error during scan"
        case .mockDataNotFound:
            return "Mock scan data not found"
        case .invalidResponse:
            return "Invalid scan response"
        case .confidenceTooLow:
            return "Scan confidence too low, please try again"
        }
    }
}