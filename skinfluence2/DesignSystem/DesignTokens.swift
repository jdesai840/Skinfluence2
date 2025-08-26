//
//  DesignTokens.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import SwiftUI

enum Theme {
    // MARK: - Colors
    static let blush = Color(red: 0xF7/255.0, green: 0xD7/255.0, blue: 0xDA/255.0)
    static let peach = Color(red: 0xFF/255.0, green: 0xD9/255.0, blue: 0xC9/255.0)
    static let porcelain = Color(red: 1, green: 0.972, blue: 0.972)
    static let ink = Color(red: 0x1E/255.0, green: 0x1E/255.0, blue: 0x1E/255.0)
    
    // MARK: - Semantic Colors
    static let primary = blush
    static let secondary = peach
    static let background = porcelain
    static let text = ink
    
    // MARK: - Typography
    static let titleFont = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let headlineFont = Font.system(.title2, design: .rounded, weight: .semibold)
    static let bodyFont = Font.system(.body, design: .rounded, weight: .medium)
    static let captionFont = Font.system(.caption, design: .rounded, weight: .regular)
    
    // MARK: - Spacing
    static let spacing2: CGFloat = 2
    static let spacing4: CGFloat = 4
    static let spacing8: CGFloat = 8
    static let spacing12: CGFloat = 12
    static let spacing16: CGFloat = 16
    static let spacing20: CGFloat = 20
    static let spacing24: CGFloat = 24
    static let spacing32: CGFloat = 32
    
    // MARK: - Corner Radius
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 24
    
    // MARK: - Elevation
    static let shadowColor = Color.black.opacity(0.12)
    static let shadowRadius: CGFloat = 12
    static let shadowY: CGFloat = 6
}

// MARK: - Haptic Feedback
enum HapticFeedback {
    static func light() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    static func medium() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    static func success() {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
    }
    
    static func warning() {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.warning)
    }
}