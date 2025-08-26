//
//  ProductViews.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import SwiftUI

// MARK: - Product Detail View
struct ProductDetailView: View {
    let product: DetailedProduct
    @State private var showingSwapOptions = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.spacing24) {
                        // Product Image
                        productImageSection
                        
                        // Product Info
                        productInfoSection
                        
                        // Ingredients
                        ingredientsSection
                        
                        // Why This Fits
                        explanationSection
                        
                        // Where to Buy
                        whereToBySection
                        
                        // Action Buttons
                        actionButtons
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Theme.text)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Share product
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Theme.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingSwapOptions) {
            SwapOptionsView(currentProduct: product)
        }
    }
    
    private var productImageSection: some View {
        Rectangle()
            .fill(Theme.secondary.opacity(0.2))
            .frame(height: 200)
            .cornerRadius(Theme.cornerRadiusMedium)
            .overlay(
                VStack {
                    Image(systemName: "photo")
                        .font(.system(size: 50))
                        .foregroundColor(Theme.text.opacity(0.4))
                    
                    Text(product.name)
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.text.opacity(0.6))
                }
            )
    }
    
    private var productInfoSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: Theme.spacing8) {
                    Text(product.brand)
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.text.opacity(0.6))
                        .textCase(.uppercase)
                    
                    Text(product.name)
                        .font(Theme.titleFont)
                        .foregroundColor(Theme.text)
                    
                    Text(product.stepType.capitalized)
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(product.price)
                        .font(Theme.headlineFont)
                        .foregroundColor(Theme.text)
                    
                    Text(product.size)
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.text.opacity(0.6))
                }
            }
            
            // Badges
            if !product.badges.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(product.badges, id: \.self) { badge in
                            BadgeView(text: badge, style: badgeStyle(for: badge))
                        }
                    }
                }
            }
        }
    }
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            Text("Key Ingredients")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.text)
            
            VStack(spacing: Theme.spacing12) {
                ForEach(product.keyIngredients, id: \.name) { ingredient in
                    IngredientRow(ingredient: ingredient)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(Theme.cornerRadiusMedium)
    }
    
    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            Text("Why This Fits Your Routine")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.text)
            
            Text(product.explanation)
                .font(Theme.bodyFont)
                .foregroundColor(Theme.text.opacity(0.8))
                .lineSpacing(4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(Theme.cornerRadiusMedium)
    }
    
    private var whereToBySection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            Text("Where to Buy")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.text)
            
            VStack(spacing: Theme.spacing12) {
                ForEach(product.retailerLinks, id: \.retailer) { link in
                    RetailerLinkRow(link: link)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(Theme.cornerRadiusMedium)
    }
    
    private var actionButtons: some View {
        VStack(spacing: Theme.spacing12) {
            Button(action: {
                showingSwapOptions = true
            }) {
                HStack {
                    Image(systemName: "arrow.triangle.swap")
                    Text("View Alternatives")
                }
                .frame(maxWidth: .infinity)
            }
            .secondaryStyle()
            
            Button(action: {
                // Add to routine
            }) {
                Text("Add to My Routine")
                    .frame(maxWidth: .infinity)
            }
            .primaryStyle()
        }
    }
    
    private func badgeStyle(for badge: String) -> BadgeStyle {
        switch badge {
        case "Best Value": return .warning
        case "Pregnancy-Safe": return .success
        case "Fragrance-Free": return .info
        default: return .default
        }
    }
}

// MARK: - Swap Options View
struct SwapOptionsView: View {
    let currentProduct: DetailedProduct
    @Environment(\.dismiss) private var dismiss
    @State private var selectedAlternative: DetailedProduct?
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.spacing24) {
                        // Current Product
                        currentProductSection
                        
                        // Alternatives
                        alternativesSection
                        
                        // Action Buttons
                        actionButtons
                    }
                    .padding()
                }
            }
            .navigationTitle("Swap Options")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.primary)
                }
            }
        }
    }
    
    private var currentProductSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            Text("Current Selection")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.text)
            
            ProductCompactCard(
                product: currentProduct,
                isSelected: selectedAlternative == nil,
                showCheckmark: true
            ) {
                selectedAlternative = nil
            }
        }
    }
    
    private var alternativesSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            HStack {
                Text("Alternatives")
                    .font(Theme.headlineFont)
                    .foregroundColor(Theme.text)
                
                Spacer()
                
                Text("\(getAlternatives().count) options")
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.text.opacity(0.6))
            }
            
            VStack(spacing: Theme.spacing12) {
                ForEach(getAlternatives(), id: \.id) { alternative in
                    ProductCompactCard(
                        product: alternative,
                        isSelected: selectedAlternative?.id == alternative.id,
                        showCheckmark: true
                    ) {
                        selectedAlternative = alternative
                    }
                }
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: Theme.spacing12) {
            if selectedAlternative != nil {
                Button(action: {
                    // Apply swap
                    print("Swapping to: \(selectedAlternative?.name ?? "")")
                    dismiss()
                }) {
                    Text("Apply Swap")
                        .frame(maxWidth: .infinity)
                }
                .primaryStyle()
            }
            
            Button(action: {
                selectedAlternative = nil
            }) {
                Text("Keep Original")
                    .frame(maxWidth: .infinity)
            }
            .secondaryStyle()
        }
    }
    
    private func getAlternatives() -> [DetailedProduct] {
        // Mock alternatives
        return [
            DetailedProduct(
                id: "alt1",
                name: "Alternative Cleanser",
                brand: "AltBrand",
                stepType: "cleanser",
                price: "$16",
                size: "150ml",
                explanation: "Budget-friendly alternative with similar benefits",
                keyIngredients: [
                    KeyIngredient(name: "Glycerin", benefit: "Hydration"),
                    KeyIngredient(name: "Ceramides", benefit: "Barrier repair")
                ],
                badges: ["Best Value", "Fragrance-Free"],
                retailerLinks: [
                    RetailerLink(retailer: "Amazon", price: "$16", inStock: true),
                    RetailerLink(retailer: "Target", price: "$15", inStock: false)
                ]
            ),
            DetailedProduct(
                id: "alt2",
                name: "Premium Cleanser",
                brand: "LuxeBrand",
                stepType: "cleanser",
                price: "$45",
                size: "200ml",
                explanation: "Luxury formula with advanced peptides",
                keyIngredients: [
                    KeyIngredient(name: "Peptides", benefit: "Anti-aging"),
                    KeyIngredient(name: "Hyaluronic Acid", benefit: "Deep hydration")
                ],
                badges: ["Premium", "Fragrance-Free"],
                retailerLinks: [
                    RetailerLink(retailer: "Sephora", price: "$45", inStock: true),
                    RetailerLink(retailer: "Ulta", price: "$43", inStock: true)
                ]
            )
        ]
    }
}

// MARK: - Supporting Models
struct DetailedProduct: Identifiable, Equatable {
    let id: String
    let name: String
    let brand: String
    let stepType: String
    let price: String
    let size: String
    let explanation: String
    let keyIngredients: [KeyIngredient]
    let badges: [String]
    let retailerLinks: [RetailerLink]
    
    static func == (lhs: DetailedProduct, rhs: DetailedProduct) -> Bool {
        lhs.id == rhs.id
    }
}

struct KeyIngredient {
    let name: String
    let benefit: String
}

struct RetailerLink {
    let retailer: String
    let price: String
    let inStock: Bool
}

// MARK: - Supporting Views
struct BadgeView: View {
    let text: String
    let style: BadgeStyle
    
    var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(style.backgroundColor)
            .foregroundColor(style.textColor)
            .cornerRadius(6)
    }
}

enum BadgeStyle {
    case `default`
    case success
    case warning
    case info
    
    var backgroundColor: Color {
        switch self {
        case .default: return Theme.primary.opacity(0.2)
        case .success: return .green.opacity(0.2)
        case .warning: return .orange.opacity(0.2)
        case .info: return .blue.opacity(0.2)
        }
    }
    
    var textColor: Color {
        switch self {
        case .default: return Theme.primary
        case .success: return .green
        case .warning: return .orange
        case .info: return .blue
        }
    }
}

struct IngredientRow: View {
    let ingredient: KeyIngredient
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(ingredient.name)
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.text)
                
                Text(ingredient.benefit)
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.text.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "info.circle")
                .foregroundColor(Theme.primary)
        }
        .padding(.vertical, 4)
    }
}

struct RetailerLinkRow: View {
    let link: RetailerLink
    
    var body: some View {
        Button(action: {
            // Open retailer link
            print("Opening \(link.retailer)")
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(link.retailer)
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text)
                    
                    HStack {
                        Text(link.price)
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.primary)
                        
                        if !link.inStock {
                            Text("• Out of stock")
                                .font(Theme.captionFont)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .foregroundColor(Theme.primary)
            }
            .padding()
            .background(Theme.background)
            .cornerRadius(Theme.cornerRadiusMedium)
            .opacity(link.inStock ? 1.0 : 0.6)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!link.inStock)
    }
}

struct ProductCompactCard: View {
    let product: DetailedProduct
    let isSelected: Bool
    let showCheckmark: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Rectangle()
                    .fill(Theme.secondary.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .cornerRadius(Theme.cornerRadiusMedium)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(Theme.text.opacity(0.4))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.brand)
                        .font(.caption)
                        .foregroundColor(Theme.text.opacity(0.6))
                        .textCase(.uppercase)
                    
                    Text(product.name)
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text)
                    
                    HStack {
                        Text(product.price)
                            .font(Theme.bodyFont)
                            .foregroundColor(Theme.primary)
                        
                        if product.badges.contains("Best Value") {
                            BadgeView(text: "Best Value", style: .warning)
                        }
                    }
                }
                
                Spacer()
                
                if showCheckmark {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? Theme.primary : Theme.text.opacity(0.4))
                        .font(.title2)
                }
            }
            .padding()
            .background(isSelected ? Theme.primary.opacity(0.1) : Color.white)
            .cornerRadius(Theme.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                    .stroke(isSelected ? Theme.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Sample Data
extension DetailedProduct {
    static let sample = DetailedProduct(
        id: "sample1",
        name: "Gentle Cloud Cleanser",
        brand: "CloudSkin",
        stepType: "cleanser",
        price: "$18",
        size: "150ml",
        explanation: "This gentle gel cleanser is perfect for your combination skin. It removes daily buildup without stripping natural oils, while the fragrance-free formula won't irritate sensitive areas.",
        keyIngredients: [
            KeyIngredient(name: "Glycerin", benefit: "Maintains skin hydration"),
            KeyIngredient(name: "Coco-Glucoside", benefit: "Gentle cleansing"),
            KeyIngredient(name: "Panthenol", benefit: "Soothes and calms")
        ],
        badges: ["Best Value", "Fragrance-Free", "Pregnancy-Safe"],
        retailerLinks: [
            RetailerLink(retailer: "Amazon", price: "$18", inStock: true),
            RetailerLink(retailer: "Target", price: "$17", inStock: true),
            RetailerLink(retailer: "CVS", price: "$19", inStock: false)
        ]
    )
}

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(product: .sample)
    }
}

struct SwapOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        SwapOptionsView(currentProduct: .sample)
    }
}