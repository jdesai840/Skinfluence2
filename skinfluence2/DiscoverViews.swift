//
//  DiscoverViews.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import SwiftUI

// MARK: - Enhanced Discover View
struct EnhancedDiscoverView: View {
    @State private var searchText = ""
    @State private var selectedFilters: Set<String> = []
    @State private var showingSearch = false
    
    private let filterOptions = ["For Your Skin", "Fragrance-Free", "Best Value", "Pregnancy-Safe", "K-Beauty"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.spacing24) {
                        // Search Bar
                        searchHeader
                        
                        // Filter Chips
                        filterChips
                        
                        // Featured Section
                        featuredSection
                        
                        // Categories
                        categoriesSection
                        
                        // Product Grid
                        productsGrid
                    }
                    .padding()
                }
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingSearch) {
                SearchView()
            }
        }
    }
    
    private var searchHeader: some View {
        Button(action: { showingSearch = true }) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Theme.text.opacity(0.6))
                
                Text("Search products, brands, ingredients...")
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.text.opacity(0.6))
                
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(Theme.cornerRadiusMedium)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.spacing12) {
                ForEach(filterOptions, id: \.self) { filter in
                    FilterChip(
                        title: filter,
                        isSelected: selectedFilters.contains(filter)
                    ) {
                        if selectedFilters.contains(filter) {
                            selectedFilters.remove(filter)
                        } else {
                            selectedFilters.insert(filter)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            Text("Trending Now")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.text)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.spacing16) {
                    ForEach(getFeaturedProducts(), id: \.id) { product in
                        FeaturedProductCard(product: product)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            Text("Shop by Category")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.text)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: Theme.spacing12) {
                ForEach(ProductCategory.allCases, id: \.self) { category in
                    CategoryCard(category: category)
                }
            }
        }
    }
    
    private var productsGrid: some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            Text("All Products")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.text)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: Theme.spacing16) {
                ForEach(getAllProducts(), id: \.id) { product in
                    ProductGridCard(product: product)
                }
            }
        }
    }
    
    private func getFeaturedProducts() -> [MockProduct] {
        return [
            MockProduct(id: "1", name: "Vitamin C Serum", brand: "BrightLab", category: .serum, price: "$32", image: "serum1", badges: ["Trending"]),
            MockProduct(id: "2", name: "Gentle Cleanser", brand: "CloudSkin", category: .cleanser, price: "$18", image: "cleanser1", badges: ["Best Value"]),
            MockProduct(id: "3", name: "SPF 50 Fluid", brand: "SunVeil", category: .sunscreen, price: "$24", image: "sunscreen1", badges: ["Pregnancy-Safe"])
        ]
    }
    
    private func getAllProducts() -> [MockProduct] {
        return [
            MockProduct(id: "4", name: "Rice Essence", brand: "GlowLab", category: .essence, price: "$16", image: "essence1", badges: ["K-Beauty"]),
            MockProduct(id: "5", name: "Retinoid 0.2%", brand: "NightRx", category: .treatment, price: "$28", image: "retinoid1", badges: []),
            MockProduct(id: "6", name: "Ceramide Cream", brand: "BarrierFix", category: .moisturizer, price: "$35", image: "moisturizer1", badges: ["Fragrance-Free"]),
            MockProduct(id: "7", name: "AHA Exfoliant", brand: "SmoothLab", category: .treatment, price: "$22", image: "exfoliant1", badges: []),
            MockProduct(id: "8", name: "Hydrating Mask", brand: "CalmK", category: .mask, price: "$14", image: "mask1", badges: ["Best Value"]),
            MockProduct(id: "9", name: "Oil Cleanser", brand: "PureOil", category: .cleanser, price: "$26", image: "cleanser2", badges: ["K-Beauty"])
        ]
    }
}

// MARK: - Search View
struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var recentSearches = ["niacinamide", "vitamin c", "retinol", "ceramide"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        TextField("Search products, brands, ingredients...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if !searchText.isEmpty {
                            Button("Clear") {
                                searchText = ""
                            }
                            .foregroundColor(Theme.primary)
                        }
                    }
                    .padding()
                    
                    if searchText.isEmpty {
                        // Recent Searches
                        recentSearchesView
                    } else {
                        // Search Results
                        searchResultsView
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Search")
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
    
    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            Text("Recent Searches")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.text)
                .padding(.horizontal)
            
            ForEach(recentSearches, id: \.self) { search in
                Button(action: {
                    searchText = search
                }) {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(Theme.text.opacity(0.4))
                        
                        Text(search)
                            .font(Theme.bodyFont)
                            .foregroundColor(Theme.text)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.left")
                            .foregroundColor(Theme.text.opacity(0.4))
                    }
                    .padding()
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
            }
        }
    }
    
    private var searchResultsView: some View {
        ScrollView {
            LazyVStack(spacing: Theme.spacing16) {
                ForEach(getSearchResults(), id: \.id) { product in
                    SearchResultCard(product: product)
                }
            }
            .padding()
        }
    }
    
    private func getSearchResults() -> [MockProduct] {
        // Mock search results based on searchText
        return getAllProducts().filter { product in
            product.name.lowercased().contains(searchText.lowercased()) ||
            product.brand.lowercased().contains(searchText.lowercased())
        }
    }
    
    private func getAllProducts() -> [MockProduct] {
        return [
            MockProduct(id: "1", name: "Vitamin C Serum", brand: "BrightLab", category: .serum, price: "$32", image: "serum1", badges: ["Trending"]),
            MockProduct(id: "2", name: "Gentle Cleanser", brand: "CloudSkin", category: .cleanser, price: "$18", image: "cleanser1", badges: ["Best Value"]),
            MockProduct(id: "3", name: "Niacinamide 5%", brand: "BalanceRx", category: .serum, price: "$15", image: "serum2", badges: ["Best Value"]),
            MockProduct(id: "4", name: "Retinol 0.5%", brand: "NightRx", category: .treatment, price: "$28", image: "retinoid1", badges: [])
        ]
    }
}

// MARK: - Supporting Models
struct MockProduct {
    let id: String
    let name: String
    let brand: String
    let category: ProductCategory
    let price: String
    let image: String
    let badges: [String]
}

enum ProductCategory: String, CaseIterable {
    case cleanser = "cleanser"
    case essence = "essence"
    case serum = "serum"
    case moisturizer = "moisturizer"
    case sunscreen = "sunscreen"
    case treatment = "treatment"
    case mask = "mask"
    
    var displayName: String {
        switch self {
        case .cleanser: return "Cleansers"
        case .essence: return "Essences"
        case .serum: return "Serums"
        case .moisturizer: return "Moisturizers"
        case .sunscreen: return "Sunscreen"
        case .treatment: return "Treatments"
        case .mask: return "Masks"
        }
    }
    
    var icon: String {
        switch self {
        case .cleanser: return "drop.fill"
        case .essence: return "sparkles"
        case .serum: return "eyedropper"
        case .moisturizer: return "heart.fill"
        case .sunscreen: return "sun.max.fill"
        case .treatment: return "cross.vial"
        case .mask: return "face.smiling"
        }
    }
}

// MARK: - Supporting Views
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(Theme.captionFont)
                .foregroundColor(isSelected ? .white : Theme.text)
                .padding(.horizontal, Theme.spacing12)
                .padding(.vertical, Theme.spacing8)
                .background(isSelected ? Theme.primary : Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Theme.primary, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FeaturedProductCard: View {
    let product: MockProduct
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing8) {
            // Product Image Placeholder
            Rectangle()
                .fill(Theme.secondary.opacity(0.3))
                .frame(width: 120, height: 120)
                .cornerRadius(Theme.cornerRadiusMedium)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(Theme.text.opacity(0.4))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.brand)
                    .font(.caption)
                    .foregroundColor(Theme.text.opacity(0.6))
                
                Text(product.name)
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.text)
                
                Text(product.price)
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.primary)
            }
        }
        .frame(width: 120)
    }
}

struct CategoryCard: View {
    let category: ProductCategory
    
    var body: some View {
        Button(action: {
            // Navigate to category
        }) {
            HStack {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(Theme.primary)
                
                Text(category.displayName)
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.text)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Theme.text.opacity(0.4))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(Theme.cornerRadiusMedium)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProductGridCard: View {
    let product: MockProduct
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing8) {
            // Product Image
            Rectangle()
                .fill(Theme.secondary.opacity(0.2))
                .frame(height: 120)
                .cornerRadius(Theme.cornerRadiusMedium)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(Theme.text.opacity(0.4))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.brand)
                    .font(.caption)
                    .foregroundColor(Theme.text.opacity(0.6))
                
                Text(product.name)
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.text)
                    .lineLimit(2)
                
                Text(product.price)
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.primary)
                
                // Badges
                if !product.badges.isEmpty {
                    HStack {
                        ForEach(product.badges, id: \.self) { badge in
                            Text(badge)
                                .font(.caption2)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Theme.primary.opacity(0.2))
                                .foregroundColor(Theme.primary)
                                .cornerRadius(4)
                        }
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(Theme.cornerRadiusMedium)
    }
}

struct SearchResultCard: View {
    let product: MockProduct
    
    var body: some View {
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
                
                Text(product.name)
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.text)
                
                HStack {
                    Text(product.price)
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.primary)
                    
                    if !product.badges.isEmpty {
                        ForEach(product.badges, id: \.self) { badge in
                            Text(badge)
                                .font(.caption2)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Theme.primary.opacity(0.2))
                                .foregroundColor(Theme.primary)
                                .cornerRadius(4)
                        }
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                // Add to routine or view details
            }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(Theme.primary)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(Theme.cornerRadiusMedium)
    }
}

struct EnhancedDiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedDiscoverView()
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}