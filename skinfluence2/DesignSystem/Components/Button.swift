//
//  Button.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import SwiftUI

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.bodyFont)
            .foregroundColor(Theme.text)
            .padding(.vertical, Theme.spacing16)
            .padding(.horizontal, Theme.spacing24)
            .background(Theme.primary)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge, style: .continuous))
            .shadow(color: configuration.isPressed ? Theme.shadowColor.opacity(0.05) : Theme.shadowColor, 
                   radius: Theme.shadowRadius, 
                   y: Theme.shadowY)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.bodyFont)
            .foregroundColor(Theme.text)
            .padding(.vertical, Theme.spacing16)
            .padding(.horizontal, Theme.spacing24)
            .background(Theme.secondary)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge, style: .continuous))
            .shadow(color: configuration.isPressed ? Theme.shadowColor.opacity(0.05) : Theme.shadowColor, 
                   radius: Theme.shadowRadius, 
                   y: Theme.shadowY)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Tertiary Button Style
struct TertiaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.bodyFont)
            .foregroundColor(Theme.text)
            .padding(.vertical, Theme.spacing12)
            .padding(.horizontal, Theme.spacing20)
            .background(Theme.background)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge, style: .continuous)
                    .stroke(Theme.primary, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Convenience Extensions
extension Button {
    func primaryStyle() -> some View {
        self.buttonStyle(PrimaryButtonStyle())
    }
    
    func secondaryStyle() -> some View {
        self.buttonStyle(SecondaryButtonStyle())
    }
    
    func tertiaryStyle() -> some View {
        self.buttonStyle(TertiaryButtonStyle())
    }
}