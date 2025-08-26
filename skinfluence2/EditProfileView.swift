//
//  EditProfileView.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import SwiftUI
import Foundation

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authService: AuthService
    @StateObject private var profileStore = ProfileStore()
    
    // Local state for editing
    @State private var displayName: String = ""
    @State private var selectedSkinType: SkinProfile.BaseType = .normal
    @State private var isSensitive: Bool = false
    @State private var isAcneProne: Bool = false
    @State private var isPigmentationProne: Bool = false
    @State private var selectedBudgetTier: BudgetTier = .balanced
    @State private var safetyToggles = SafetyToggles()
    @State private var retailerOrder: [String] = []
    
    // UI state
    @State private var isSaving: Bool = false
    @State private var showingSuccessAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var showingErrorAlert: Bool = false
    
    private let availableRetailers = ["Amazon", "Sephora", "Olive Young", "YesStyle", "TikTok Shop"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.spacing24) {
                        // Basic Information Section
                        basicInformationSection
                        
                        // Skin Profile Section
                        skinProfileSection
                        
                        // Safety Preferences Section
                        safetyPreferencesSection
                        
                        // Budget Selection Section
                        budgetSelectionSection
                        
                        // Retailer Preferences Section
                        retailerPreferencesSection
                        
                        // Save Button
                        saveButton
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Profile")
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
            .onAppear {
                loadCurrentProfile()
            }
            .alert("Profile Updated", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your profile preferences have been saved successfully.")
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .overlay(
                isSaving ? loadingOverlay : nil
            )
        }
    }
    
    // MARK: - Basic Information Section
    private var basicInformationSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            sectionHeader(title: "Basic Information", icon: "person.crop.circle")
            
            VStack(spacing: Theme.spacing12) {
                HStack {
                    Text("Display Name")
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text)
                    
                    Spacer()
                    
                    TextField("Enter your name", text: $displayName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 200)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Email")
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text)
                    
                    Spacer()
                    
                    Text(authService.currentUser?.email ?? "Not available")
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.text.opacity(0.6))
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(Theme.cornerRadiusMedium)
        }
    }
    
    // MARK: - Skin Profile Section
    private var skinProfileSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            sectionHeader(title: "Skin Profile", icon: "face.smiling")
            
            VStack(spacing: Theme.spacing16) {
                // Base Skin Type
                VStack(alignment: .leading, spacing: Theme.spacing8) {
                    Text("Base Skin Type")
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: Theme.spacing8) {
                        ForEach(SkinProfile.BaseType.allCases, id: \.self) { skinType in
                            skinTypeCard(skinType)
                        }
                    }
                }
                
                Divider()
                
                // Modifiers
                VStack(alignment: .leading, spacing: Theme.spacing8) {
                    Text("Additional Characteristics")
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text)
                    
                    VStack(spacing: Theme.spacing8) {
                        toggleRow("Sensitive Skin", isOn: $isSensitive, description: "Reacts easily to new products")
                        toggleRow("Acne-Prone", isOn: $isAcneProne, description: "Frequent breakouts or blackheads")
                        toggleRow("Pigmentation-Prone", isOn: $isPigmentationProne, description: "Dark spots or uneven skin tone")
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(Theme.cornerRadiusMedium)
        }
    }
    
    // MARK: - Safety Preferences Section
    private var safetyPreferencesSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            sectionHeader(title: "Safety Preferences", icon: "shield.checkered")
            
            VStack(spacing: Theme.spacing8) {
                toggleRow("Pregnancy-Safe Only", isOn: $safetyToggles.pregnancySafe, description: "Avoid retinoids, high-dose salicylic acid")
                toggleRow("Fragrance-Free", isOn: $safetyToggles.fragranceFree, description: "No added fragrances or parfum")
                toggleRow("Essential Oil-Free", isOn: $safetyToggles.essentialOilFree, description: "Avoid tea tree, lavender oils")
                toggleRow("Alcohol Denat-Free", isOn: $safetyToggles.alcoholDenatFree, description: "No drying alcohols")
            }
            .padding()
            .background(Color.white)
            .cornerRadius(Theme.cornerRadiusMedium)
        }
    }
    
    // MARK: - Budget Selection Section
    private var budgetSelectionSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            sectionHeader(title: "Budget Preference", icon: "dollarsign.circle")
            
            VStack(spacing: Theme.spacing12) {
                ForEach(BudgetTier.allCases, id: \.self) { tier in
                    budgetTierCard(tier)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(Theme.cornerRadiusMedium)
        }
    }
    
    // MARK: - Retailer Preferences Section
    private var retailerPreferencesSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            sectionHeader(title: "Retailer Preferences", icon: "bag")
            
            VStack(alignment: .leading, spacing: Theme.spacing8) {
                Text("Drag to reorder your preferred retailers")
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.text.opacity(0.7))
                
                ForEach(Array(retailerOrder.enumerated()), id: \.element) { index, retailer in
                    retailerRow(retailer: retailer, index: index)
                }
                .onMove(perform: moveRetailer)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(Theme.cornerRadiusMedium)
        }
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button(action: saveProfile) {
            HStack {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Theme.text))
                        .scaleEffect(0.8)
                }
                Text(isSaving ? "Saving..." : "Save Changes")
            }
            .frame(maxWidth: .infinity)
        }
        .primaryStyle()
        .disabled(isSaving)
        .opacity(isSaving ? 0.7 : 1.0)
    }
    
    // MARK: - Loading Overlay
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: Theme.spacing16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Theme.primary))
                    .scaleEffect(1.2)
                
                Text("Saving Profile...")
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.text)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(Theme.cornerRadiusMedium)
            .shadow(radius: 10)
        }
    }
    
    // MARK: - Helper Views
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Theme.primary)
            
            Text(title)
                .font(Theme.headlineFont)
                .foregroundColor(Theme.text)
            
            Spacer()
        }
    }
    
    private func skinTypeCard(_ skinType: SkinProfile.BaseType) -> some View {
        Button(action: {
            selectedSkinType = skinType
        }) {
            VStack(alignment: .leading, spacing: Theme.spacing8) {
                Text(skinType.displayName)
                    .font(Theme.bodyFont)
                    .foregroundColor(selectedSkinType == skinType ? .white : Theme.text)
                
                Text(skinType.description)
                    .font(Theme.captionFont)
                    .foregroundColor(selectedSkinType == skinType ? .white.opacity(0.8) : Theme.text.opacity(0.6))
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(selectedSkinType == skinType ? Theme.primary : Theme.background)
            .cornerRadius(Theme.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                    .stroke(selectedSkinType == skinType ? Theme.primary : Theme.text.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func toggleRow(_ title: String, isOn: Binding<Bool>, description: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.text)
                
                Text(description)
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.text.opacity(0.6))
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .tint(Theme.primary)
        }
    }
    
    private func budgetTierCard(_ tier: BudgetTier) -> some View {
        Button(action: {
            selectedBudgetTier = tier
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(tier.displayName)
                        .font(Theme.bodyFont)
                        .foregroundColor(selectedBudgetTier == tier ? .white : Theme.text)
                    
                    Text(tier.description)
                        .font(Theme.captionFont)
                        .foregroundColor(selectedBudgetTier == tier ? .white.opacity(0.8) : Theme.text.opacity(0.6))
                    
                    HStack {
                        ForEach(tier.priceBands, id: \.self) { band in
                            Text(band)
                                .font(.caption2)
                                .foregroundColor(selectedBudgetTier == tier ? .white : Theme.primary)
                        }
                    }
                }
                
                Spacer()
                
                if selectedBudgetTier == tier {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(selectedBudgetTier == tier ? Theme.primary : Theme.background)
            .cornerRadius(Theme.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                    .stroke(selectedBudgetTier == tier ? Theme.primary : Theme.text.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func retailerRow(retailer: String, index: Int) -> some View {
        HStack {
            Image(systemName: "line.3.horizontal")
                .foregroundColor(Theme.text.opacity(0.4))
            
            Text("\(index + 1).")
                .font(Theme.captionFont)
                .foregroundColor(Theme.text.opacity(0.6))
                .frame(width: 20)
            
            Text(retailer)
                .font(Theme.bodyFont)
                .foregroundColor(Theme.text)
            
            Spacer()
        }
        .padding(.vertical, Theme.spacing8)
    }
    
    // MARK: - Data Management
    private func loadCurrentProfile() {
        guard let user = authService.currentUser else { return }
        
        // Load basic info
        displayName = user.email?.components(separatedBy: "@").first?.capitalized ?? "User"
        
        // Load skin profile
        if let profile = user.profile {
            selectedSkinType = profile.baseType
            isSensitive = profile.sensitive
            isAcneProne = profile.acneProne
            isPigmentationProne = profile.pigmentationProne
        }
        
        // Load preferences
        selectedBudgetTier = user.preferences.budgetTier
        safetyToggles = user.preferences.safety
        retailerOrder = user.preferences.retailerOrder
    }
    
    private func saveProfile() {
        guard var user = authService.currentUser else {
            errorMessage = "User not found. Please sign in again."
            showingErrorAlert = true
            return
        }
        
        isSaving = true
        
        // Create updated skin profile
        let updatedProfile = SkinProfile(
            baseType: selectedSkinType,
            sensitive: isSensitive,
            acneProne: isAcneProne,
            pigmentationProne: isPigmentationProne,
            source: user.profile?.source ?? "questionnaire"
        )
        
        // Create updated preferences
        let updatedPreferences = Preferences(
            budgetTier: selectedBudgetTier,
            safety: safetyToggles,
            retailerOrder: retailerOrder
        )
        
        // Update user model
        user.updateProfile(updatedProfile)
        user.updatePreferences(updatedPreferences)
        
        // Save via ProfileStore
        Task {
            do {
                try await profileStore.saveProfile(user)
                
                await MainActor.run {
                    authService.updateUser(user)
                    isSaving = false
                    showingSuccessAlert = true
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorMessage = error.localizedDescription
                    showingErrorAlert = true
                }
            }
        }
    }
    
    private func moveRetailer(from source: IndexSet, to destination: Int) {
        retailerOrder.move(fromOffsets: source, toOffset: destination)
    }
}

// MARK: - Preview
struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
            .environmentObject(AuthService.shared)
    }
}