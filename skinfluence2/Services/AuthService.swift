//
//  AuthService.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import Foundation
import AuthenticationServices

// MARK: - Auth Service
final class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var isSignedIn: Bool = false
    @Published var currentUser: AppUser?
    @Published var isLoading: Bool = false
    
    private init() {
        checkAuthState()
    }
    
    // MARK: - Auth State Management
    func checkAuthState() {
        // TODO: Implement Firebase Auth state listener
        // For Phase 1, we'll use UserDefaults for persistence
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if let userData = UserDefaults.standard.data(forKey: "currentUser"),
               let user = try? JSONDecoder().decode(AppUser.self, from: userData) {
                self?.currentUser = user
                self?.isSignedIn = true
            }
            self?.isLoading = false
        }
    }
    
    // MARK: - Sign In Methods
    func signInWithApple() async throws {
        isLoading = true
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = AppleSignInDelegate { [weak self] result in
                self?.isLoading = false
                
                switch result {
                case .success(let user):
                    self?.currentUser = user
                    self?.isSignedIn = true
                    self?.saveUserToDefaults(user)
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            controller.performRequests()
        }
    }
    
    func signInWithEmail(_ email: String, password: String) async throws {
        isLoading = true
        
        // TODO: Implement Firebase Auth email sign-in
        // For Phase 1, create a mock user
        try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate network delay
        
        let user = AppUser(id: UUID().uuidString, email: email)
        
        DispatchQueue.main.async { [weak self] in
            self?.currentUser = user
            self?.isSignedIn = true
            self?.isLoading = false
            self?.saveUserToDefaults(user)
        }
    }
    
    func signUpWithEmail(_ email: String, password: String) async throws {
        isLoading = true
        
        // TODO: Implement Firebase Auth email sign-up
        // For Phase 1, create a mock user
        try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate network delay
        
        let user = AppUser(id: UUID().uuidString, email: email)
        
        DispatchQueue.main.async { [weak self] in
            self?.currentUser = user
            self?.isSignedIn = true
            self?.isLoading = false
            self?.saveUserToDefaults(user)
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        currentUser = nil
        isSignedIn = false
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    // MARK: - User Management
    func updateUser(_ user: AppUser) {
        currentUser = user
        saveUserToDefaults(user)
    }
    
    func updateUserProfile(_ profile: SkinProfile) {
        guard var user = currentUser else { return }
        user.updateProfile(profile)
        updateUser(user)
    }
    
    func updateUserPreferences(_ preferences: Preferences) {
        guard var user = currentUser else { return }
        user.updatePreferences(preferences)
        updateUser(user)
    }
    
    func updateProStatus(_ proStatus: ProStatus) {
        guard var user = currentUser else { return }
        user.proStatus = proStatus
        updateUser(user)
    }
    
    func addScanObservations(_ observations: ScanObservations) {
        guard var user = currentUser else { return }
        user.addScanObservations(observations)
        updateUser(user)
    }
    
    // MARK: - Profile Helpers
    var hasCompleteProfile: Bool {
        return currentUser?.hasCompletedOnboarding ?? false
    }
    
    var userDisplayName: String {
        guard let user = currentUser else { return "User" }
        return user.email?.components(separatedBy: "@").first?.capitalized ?? "User"
    }
    
    var skinTypeDescription: String? {
        guard let profile = currentUser?.profile else { return nil }
        return profile.baseType.displayName
    }
    
    var budgetTierDescription: String {
        let tier = currentUser?.preferences.budgetTier ?? .balanced
        return tier.displayName
    }
    
    private func saveUserToDefaults(_ user: AppUser) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }
}

// MARK: - Apple Sign In Delegate
class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate {
    private let completion: (Result<AppUser, Error>) -> Void
    
    init(completion: @escaping (Result<AppUser, Error>) -> Void) {
        self.completion = completion
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userID = appleIDCredential.user
            let email = appleIDCredential.email
            
            let user = AppUser(id: userID, email: email)
            completion(.success(user))
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion(.failure(error))
    }
}

// MARK: - Auth Errors
enum AuthError: Error, LocalizedError {
    case userCancelled
    case invalidCredentials
    case networkError
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .userCancelled:
            return "Sign in was cancelled"
        case .invalidCredentials:
            return "Invalid email or password"
        case .networkError:
            return "Network error occurred"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}