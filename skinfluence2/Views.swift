//
//  Views.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import SwiftUI

// MARK: - Launch View
struct LaunchView: View {
    @State private var showLogo = false
    @State private var showCatchphrase = false
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            VStack(spacing: Theme.spacing32) {
                VStack(spacing: Theme.spacing20) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(Theme.primary)
                        .scaleEffect(showLogo ? 1.0 : 0.5)
                        .opacity(showLogo ? 1.0 : 0.0)
                    
                    Text("Skinfluence")
                        .font(Theme.titleFont)
                        .foregroundColor(Theme.text)
                        .scaleEffect(showLogo ? 1.0 : 0.5)
                        .opacity(showLogo ? 1.0 : 0.0)
                }
                .animation(.easeOut(duration: 0.4), value: showLogo)
                
                Text("Personalized routines from creators you trust")
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.text.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .opacity(showCatchphrase ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 1.5), value: showCatchphrase)
            }
        }
        .onAppear {
            showLogo = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showCatchphrase = true
            }
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RoutineHomeView()
                .tabItem {
                    Image(systemName: "list.clipboard")
                    Text("Routine")
                }
                .tag(0)
            
            DiscoverView()
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("Discover")
                }
                .tag(1)
            
            ScanView()
                .tabItem {
                    Image(systemName: "camera.viewfinder")
                    Text("Scan")
                }
                .tag(2)
            
            ProfileTabView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(Theme.primary)
    }
}

// MARK: - Tab Content Views
struct RoutineHomeView: View {
    var body: some View {
        EnhancedRoutineHomeView()
    }
}

struct DiscoverView: View {
    var body: some View {
        EnhancedDiscoverView()
    }
}

struct ScanView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background
                    .ignoresSafeArea()
                
                VStack(spacing: Theme.spacing20) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(Theme.primary)
                    
                    Text("Skin Analysis")
                        .font(Theme.headlineFont)
                        .foregroundColor(Theme.text)
                    
                    Text("Coming Soon")
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text.opacity(0.8))
                }
            }
            .navigationTitle("Scan")
        }
    }
}

struct ProfileTabView: View {
    var body: some View {
        EnhancedProfileView()
    }
}