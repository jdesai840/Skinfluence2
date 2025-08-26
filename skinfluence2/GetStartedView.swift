//
//  GetStartedView.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import SwiftUI

struct GetStartedView: View {
    let onGetStarted: () -> Void
    let onSkip: () -> Void
    
    @State private var showContent = false
    @State private var sparkleOffset1: CGSize = .zero
    @State private var sparkleOffset2: CGSize = .zero
    @State private var sparkleOffset3: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Theme.background,
                        Theme.background.opacity(0.95),
                        Theme.peach.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Floating sparkles
                sparkleBackground(geometry: geometry)
                
                VStack {
                    // Skip button
                    HStack {
                        Spacer()
                        Button("Skip") {
                            HapticFeedback.light()
                            onSkip()
                        }
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text.opacity(0.6))
                        .padding(.trailing, Theme.spacing20)
                        .padding(.top, Theme.spacing8)
                    }
                    
                    Spacer()
                    
                    // Main content
                    VStack(spacing: Theme.spacing32) {
                        // Logo and title
                        VStack(spacing: Theme.spacing20) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 80, weight: .light))
                                .foregroundColor(Theme.primary)
                                .scaleEffect(showContent ? 1.0 : 0.8)
                                .opacity(showContent ? 1.0 : 0.0)
                            
                            Text("Skinfluence")
                                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                                .foregroundColor(Theme.text)
                                .scaleEffect(showContent ? 1.0 : 0.8)
                                .opacity(showContent ? 1.0 : 0.0)
                        }
                        .animation(.easeOut(duration: 0.8), value: showContent)
                        
                        // Tagline
                        Text("Personalized routines from creators you trust")
                            .font(Theme.headlineFont)
                            .foregroundColor(Theme.text.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Theme.spacing32)
                            .opacity(showContent ? 1.0 : 0.0)
                            .animation(.easeIn(duration: 0.6).delay(0.3), value: showContent)
                        
                        // Get Started button
                        Button(action: {
                            HapticFeedback.medium()
                            onGetStarted()
                        }) {
                            HStack {
                                Text("Get Started")
                                    .font(Theme.headlineFont)
                                    .fontWeight(.semibold)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [Theme.primary, Theme.secondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
                            .shadow(
                                color: Theme.primary.opacity(0.3),
                                radius: 12,
                                x: 0,
                                y: 6
                            )
                        }
                        .padding(.horizontal, Theme.spacing32)
                        .scaleEffect(showContent ? 1.0 : 0.9)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.6).delay(0.6), value: showContent)
                        .buttonStyle(PressedButtonStyle())
                        
                        // Progress dots
                        progressDots
                            .opacity(showContent ? 1.0 : 0.0)
                            .animation(.easeIn(duration: 0.4).delay(0.8), value: showContent)
                    }
                    
                    Spacer()
                    Spacer()
                }
            }
        }
        .onAppear {
            showContent = true
            startSparkleAnimation()
        }
    }
    
    private var progressDots: some View {
        HStack(spacing: Theme.spacing8) {
            ForEach(0..<7, id: \.self) { index in
                Circle()
                    .fill(index == 0 ? Theme.primary : Theme.text.opacity(0.2))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.top, Theme.spacing20)
    }
    
    private func sparkleBackground(geometry: GeometryProxy) -> some View {
        ZStack {
            // Sparkle 1
            Image(systemName: "sparkles")
                .font(.system(size: 20, weight: .light))
                .foregroundColor(Theme.primary.opacity(0.3))
                .position(x: geometry.size.width * 0.2 + sparkleOffset1.width,
                         y: geometry.size.height * 0.3 + sparkleOffset1.height)
            
            // Sparkle 2
            Image(systemName: "sparkles")
                .font(.system(size: 16, weight: .light))
                .foregroundColor(Theme.secondary.opacity(0.4))
                .position(x: geometry.size.width * 0.8 + sparkleOffset2.width,
                         y: geometry.size.height * 0.25 + sparkleOffset2.height)
            
            // Sparkle 3
            Image(systemName: "sparkles")
                .font(.system(size: 12, weight: .light))
                .foregroundColor(Theme.primary.opacity(0.2))
                .position(x: geometry.size.width * 0.15 + sparkleOffset3.width,
                         y: geometry.size.height * 0.7 + sparkleOffset3.height)
        }
    }
    
    private func startSparkleAnimation() {
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            sparkleOffset1 = CGSize(width: 20, height: -30)
        }
        
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true).delay(0.5)) {
            sparkleOffset2 = CGSize(width: -25, height: 25)
        }
        
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(1)) {
            sparkleOffset3 = CGSize(width: 15, height: -20)
        }
    }
}

// Custom button style for press animation
struct PressedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct GetStartedView_Previews: PreviewProvider {
    static var previews: some View {
        GetStartedView(
            onGetStarted: {},
            onSkip: {}
        )
    }
}