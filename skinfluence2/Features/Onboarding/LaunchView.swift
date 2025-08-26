//
//  LaunchView.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import SwiftUI

struct LaunchView: View {
    @State private var isLoading = true
    @State private var showShimmer = true
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            VStack(spacing: Theme.spacing32) {
                Spacer()
                
                // Logo
                VStack(spacing: Theme.spacing16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(Theme.primary)
                        .opacity(showShimmer ? 0.6 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(), value: showShimmer)
                    
                    Text("Skinfluence")
                        .font(Theme.titleFont)
                        .foregroundColor(Theme.text)
                }
                
                if isLoading {
                    VStack(spacing: Theme.spacing8) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Theme.primary))
                        
                        Text("Loading your skincare journey...")
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.text.opacity(0.7))
                    }
                }
                
                Spacer()
                
                Text("Personalized routines from creators you trust")
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.text.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.spacing32)
            }
        }
        .onAppear {
            startShimmerAnimation()
            simulateLoading()
        }
    }
    
    private func startShimmerAnimation() {
        showShimmer.toggle()
    }
    
    private func simulateLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                isLoading = false
            }
        }
    }
}

#Preview {
    LaunchView()
}