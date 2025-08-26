//
//  Chip.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import SwiftUI

// MARK: - Chip Style
enum ChipStyle {
    case `default`
    case success
    case warning
    case info
    
    var backgroundColor: Color {
        switch self {
        case .default:
            return Theme.background
        case .success:
            return Color.green.opacity(0.1)
        case .warning:
            return Color.orange.opacity(0.1)
        case .info:
            return Theme.secondary.opacity(0.3)
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .default:
            return Theme.text
        case .success:
            return Color.green.opacity(0.8)
        case .warning:
            return Color.orange.opacity(0.8)
        case .info:
            return Theme.text
        }
    }
}

// MARK: - Chip Component
struct Chip: View {
    let text: String
    let style: ChipStyle
    let isSelected: Bool
    let onTap: (() -> Void)?
    
    init(text: String, style: ChipStyle = .default, isSelected: Bool = false, onTap: (() -> Void)? = nil) {
        self.text = text
        self.style = style
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    var body: some View {
        Group {
            if let onTap = onTap {
                Button(action: onTap) {
                    chipContent
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                chipContent
            }
        }
    }
    
    private var chipContent: some View {
        Text(text)
            .font(Theme.captionFont)
            .foregroundColor(isSelected ? Color.white : style.foregroundColor)
            .padding(.vertical, Theme.spacing8)
            .padding(.horizontal, Theme.spacing12)
            .background(isSelected ? Theme.primary : style.backgroundColor)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Theme.primary : style.backgroundColor, lineWidth: 1)
            )
    }
}

// MARK: - Chip Group
struct ChipGroup: View {
    let chips: [String]
    @Binding var selectedChips: Set<String>
    let allowMultipleSelection: Bool
    let style: ChipStyle
    
    init(chips: [String], 
         selectedChips: Binding<Set<String>>, 
         allowMultipleSelection: Bool = true,
         style: ChipStyle = .default) {
        self.chips = chips
        self._selectedChips = selectedChips
        self.allowMultipleSelection = allowMultipleSelection
        self.style = style
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: Theme.spacing8) {
            ForEach(chips, id: \.self) { chip in
                Chip(
                    text: chip,
                    style: style,
                    isSelected: selectedChips.contains(chip)
                ) {
                    if allowMultipleSelection {
                        if selectedChips.contains(chip) {
                            selectedChips.remove(chip)
                        } else {
                            selectedChips.insert(chip)
                        }
                    } else {
                        selectedChips = [chip]
                    }
                    HapticFeedback.light()
                }
            }
        }
    }
}