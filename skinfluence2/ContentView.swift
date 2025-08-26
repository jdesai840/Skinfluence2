//
//  ContentView.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/23/25.
//

import SwiftUI

// Debug shake gesture extension
extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
            action()
        }
    }
}

extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

struct ContentView: View {
    @State private var showLaunch = true
    @State private var showGetStarted = false
    @State private var showSignIn = false
    @State private var showOnboarding = false
    @StateObject private var authService = AuthService.shared
    
    private var hasCompletedOnboarding: Bool {
        UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    private var hasSkippedToMain: Bool {
        UserDefaults.standard.bool(forKey: "hasSkippedToMain")
    }
    
    private var isGuestMode: Bool {
        UserDefaults.standard.bool(forKey: "isGuestMode")
    }
    
    // Debug function to reset onboarding state
    private func resetOnboardingState() {
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "hasSkippedToMain")
        UserDefaults.standard.removeObject(forKey: "isGuestMode")
    }
    
    var body: some View {
        ToastContainer {
            if showLaunch {
                LaunchView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
                            withAnimation(.easeOut(duration: 0.6)) {
                                showLaunch = false
                                // Show onboarding if never completed OR if in guest mode (to prompt sign-in)
                                if !hasCompletedOnboarding && !hasSkippedToMain {
                                    showGetStarted = true
                                } else if isGuestMode {
                                    // Guest users should see sign-in prompt on next launch
                                    showSignIn = true
                                }
                            }
                        }
                    }
            } else if showGetStarted {
                GetStartedView(
                    onGetStarted: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showGetStarted = false
                            showSignIn = true
                        }
                    },
                    onSkip: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showGetStarted = false
                        }
                        UserDefaults.standard.set(true, forKey: "hasSkippedToMain")
                    }
                )
            } else if showSignIn {
                SignInView(
                    onSignIn: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showSignIn = false
                            showOnboarding = true
                        }
                        UserDefaults.standard.removeObject(forKey: "isGuestMode")
                    },
                    onCreateAccount: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showSignIn = false
                            showOnboarding = true
                        }
                        UserDefaults.standard.removeObject(forKey: "isGuestMode")
                    },
                    onGuest: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showSignIn = false
                            showOnboarding = true
                        }
                        UserDefaults.standard.set(true, forKey: "isGuestMode")
                    },
                    onSkip: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showSignIn = false
                        }
                        UserDefaults.standard.set(true, forKey: "hasSkippedToMain")
                    }
                )
            } else if showOnboarding {
                OnboardingContainerView(
                    onComplete: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showOnboarding = false
                        }
                    }
                )
            } else {
                MainTabView()
                    .onShake {
                        // Debug: Shake device to reset onboarding
                        resetOnboardingState()
                        showLaunch = true
                    }
            }
        }
        .environmentObject(authService)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}