//
//  CatalogStore.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import Foundation

// MARK: - Catalog Store
final class CatalogStore: ObservableObject {
    static let shared = CatalogStore()
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?
    
    private let remoteConfig = RemoteConfigService.shared
    
    private init() {
        loadCatalog()
    }
    
    // MARK: - Loading
    func loadCatalog() {
        isLoading = true
        error = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let products = try self?.loadCatalogFromBundle() ?? []
                
                DispatchQueue.main.async {
                    self?.products = products
                    self?.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self?.error = error
                    self?.isLoading = false
                }
            }
        }
    }
    
    private func loadCatalogFromBundle() throws -> [Product] {
        guard let url = Bundle.main.url(forResource: "catalog_v1", withExtension: "json") else {
            throw CatalogError.fileNotFound
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        return try decoder.decode([Product].self, from: data)
    }
    
    // MARK: - Product Queries
    func product(by id: String) -> Product? {
        return products.first { $0.id == id }
    }
    
    func products(by stepType: String) -> [Product] {
        return products.filter { $0.stepType == stepType }
    }
    
    func products(by stepType: String, matching preferences: Preferences) -> [Product] {
        let requiredFlags = preferences.safety.asFlagSet()
        return products.filter { product in
            product.stepType == stepType &&
            product.matchesPreferences(preferences) &&
            product.matchesBudget(preferences.budgetTier)
        }
    }
    
    func filteredProducts(stepType: String? = nil,
                         budgetTier: BudgetTier? = nil,
                         requiredFlags: Set<String> = [],
                         searchText: String = "") -> [Product] {
        return products.filter { product in
            // Step type filter
            if let stepType = stepType, product.stepType != stepType {
                return false
            }
            
            // Budget filter
            if let budgetTier = budgetTier, !product.matchesBudget(budgetTier) {
                return false
            }
            
            // Safety flags filter
            if !requiredFlags.isEmpty, !requiredFlags.isSubset(of: Set(product.flags)) {
                return false
            }
            
            // Search text filter
            if !searchText.isEmpty {
                let searchLower = searchText.lowercased()
                return product.brand.lowercased().contains(searchLower) ||
                       product.name.lowercased().contains(searchLower) ||
                       product.inciHighlights.joined().lowercased().contains(searchLower)
            }
            
            return true
        }
    }
    
    func alternatives(for productId: String, matching preferences: Preferences) -> [Product] {
        guard let product = product(by: productId),
              let alternativeIds = product.alternatives else {
            return []
        }
        
        let alternatives = alternativeIds.compactMap { self.product(by: $0) }
        let filteredAlternatives = alternatives.filter { $0.matchesPreferences(preferences) }
        
        // Sort by budget preference and safety match
        return filteredAlternatives.sorted { product1, product2 in
            let budget1Match = product1.matchesBudget(preferences.budgetTier)
            let budget2Match = product2.matchesBudget(preferences.budgetTier)
            
            if budget1Match != budget2Match {
                return budget1Match
            }
            
            // Prefer products with more matching flags
            let flags1Count = Set(product1.flags).intersection(preferences.safety.asFlagSet()).count
            let flags2Count = Set(product2.flags).intersection(preferences.safety.asFlagSet()).count
            
            return flags1Count > flags2Count
        }
    }
    
    // MARK: - Retail Links
    func retailLinks(for productId: String, retailerOrder: [String]) -> [RetailLink] {
        guard let product = product(by: productId) else { return [] }
        
        return retailerOrder.compactMap { retailer in
            // Generate mock retail links
            let baseURL: String
            switch retailer {
            case "Amazon":
                baseURL = "https://amazon.com/dp/"
            case "Sephora":
                baseURL = "https://sephora.com/product/"
            case "Olive Young":
                baseURL = "https://oliveyoung.com/store/goods/"
            case "YesStyle":
                baseURL = "https://yesstyle.com/en/"
            case "TikTok Shop":
                baseURL = "https://shop.tiktok.com/item/"
            default:
                baseURL = "https://example.com/product/"
            }
            
            return RetailLink(
                retailer: retailer,
                url: "\(baseURL)\(productId)",
                price: generateMockPrice(for: product.priceBand),
                currency: "USD",
                inStock: Bool.random()
            )
        }
    }
    
    private func generateMockPrice(for priceBand: String) -> String {
        switch priceBand {
        case "$":
            return String(Int.random(in: 8...25))
        case "$$":
            return String(Int.random(in: 25...60))
        case "$$$":
            return String(Int.random(in: 60...120))
        default:
            return String(Int.random(in: 15...45))
        }
    }
}

// MARK: - Catalog Errors
enum CatalogError: Error, LocalizedError {
    case fileNotFound
    case invalidData
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Catalog file not found"
        case .invalidData:
            return "Invalid catalog data"
        case .networkError:
            return "Network error loading catalog"
        }
    }
}