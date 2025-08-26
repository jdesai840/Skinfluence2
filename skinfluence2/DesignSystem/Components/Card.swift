//
//  Card.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import SwiftUI

// MARK: - Card Container
struct Card<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(Theme.spacing20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium, style: .continuous))
            .shadow(color: Theme.shadowColor, radius: Theme.shadowRadius, y: Theme.shadowY)
    }
}

// MARK: - Product Card
struct ProductCard: View {
    let title: String
    let subtitle: String
    let imageName: String?
    let badges: [String]
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Theme.spacing12) {
                HStack {
                    AsyncImage(url: URL(string: imageName ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 60, height: 60)
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
                    
                    VStack(alignment: .leading, spacing: Theme.spacing4) {
                        Text(title)
                            .font(Theme.headlineFont)
                            .foregroundColor(Theme.text)
                            .multilineTextAlignment(.leading)
                        
                        Text(subtitle)
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.text.opacity(0.7))
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                }
                
                if !badges.isEmpty {
                    HStack {
                        ForEach(badges, id: \.self) { badge in
                            Chip(text: badge, style: .success)
                        }
                        Spacer()
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Routine Card
struct RoutineCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: Theme.spacing16) {
                Text(title)
                    .font(Theme.headlineFont)
                    .foregroundColor(Theme.text)
                
                content
            }
        }
    }
}