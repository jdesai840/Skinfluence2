//
//  FinalViews.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import SwiftUI

// MARK: - Share Routine View
struct ShareRoutineView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var routineImage: UIImage?
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background
                    .ignoresSafeArea()
                
                VStack(spacing: Theme.spacing24) {
                    // Preview Card
                    routinePreviewCard
                    
                    // Customization Options
                    customizationOptions
                    
                    Spacer()
                    
                    // Share Button
                    shareButton
                }
                .padding()
            }
            .navigationTitle("Share Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.primary)
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let image = routineImage {
                ShareSheet(items: [image, "Check out my personalized skincare routine from Skinfluence! 💅✨"])
            }
        }
    }
    
    private var routinePreviewCard: some View {
        VStack(spacing: Theme.spacing16) {
            Text("Routine Preview")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.text)
            
            // Mock routine card that would be shared
            VStack(spacing: Theme.spacing12) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("My Skincare Routine")
                            .font(Theme.headlineFont)
                            .foregroundColor(Theme.text)
                        
                        Text("Personalized by Skinfluence")
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.text.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "sparkles")
                        .foregroundColor(Theme.primary)
                }
                
                VStack(alignment: .leading, spacing: Theme.spacing8) {
                    routineSection(title: "Morning", steps: ["Cleanser", "Vitamin C", "Moisturizer", "SPF"])
                    routineSection(title: "Evening", steps: ["Cleanser", "Retinoid", "Moisturizer"])
                }
                
                HStack {
                    HStack(spacing: 4) {
                        ForEach(["Pregnancy-Safe", "Fragrance-Free"], id: \.self) { badge in
                            Text(badge)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Theme.primary.opacity(0.2))
                                .foregroundColor(Theme.primary)
                                .cornerRadius(4)
                        }
                    }
                    
                    Spacer()
                    
                    Text("$15-45 range")
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.text.opacity(0.6))
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(Theme.cornerRadiusMedium)
        }
    }
    
    private var customizationOptions: some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            Text("Customize Your Share")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.text)
            
            VStack(spacing: Theme.spacing12) {
                shareOption(icon: "shield.checkered", title: "Include safety badges", subtitle: "Show pregnancy-safe, fragrance-free labels")
                shareOption(icon: "dollarsign.circle", title: "Show price range", subtitle: "Display budget tier information")
                shareOption(icon: "person.crop.circle", title: "Add attribution", subtitle: "Credit trusted creators who inspired routine")
            }
        }
    }
    
    private var shareButton: some View {
        Button(action: shareRoutine) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Share My Routine")
            }
            .frame(maxWidth: .infinity)
        }
        .primaryStyle()
    }
    
    private func routineSection(title: String, steps: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(Theme.bodyFont)
                .foregroundColor(Theme.text)
            
            Text(steps.joined(separator: " • "))
                .font(Theme.captionFont)
                .foregroundColor(Theme.text.opacity(0.7))
        }
    }
    
    private func shareOption(icon: String, title: String, subtitle: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Theme.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.text)
                
                Text(subtitle)
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.text.opacity(0.6))
            }
            
            Spacer()
            
            Toggle("", isOn: .constant(true))
                .toggleStyle(SwitchToggleStyle(tint: Theme.primary))
        }
    }
    
    private func shareRoutine() {
        // In a real app, this would generate the routine image
        // For demo, we'll create a placeholder image
        routineImage = createRoutineImage()
        showingShareSheet = true
    }
    
    private func createRoutineImage() -> UIImage {
        // Mock image creation - in real app would render the routine card
        let size = CGSize(width: 300, height: 400)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        UIColor(Theme.background).setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}

// MARK: - Adherence Tracking View
struct AdherenceTrackingView: View {
    @State private var moodScore: Double = 3
    @State private var skinScore: Double = 3
    @State private var journalNote: String = ""
    @State private var showingPhotoCapture = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.spacing24) {
                        // Daily Check-in
                        dailyCheckInSection
                        
                        // Progress Chart
                        progressChartSection
                        
                        // Photo Journal
                        photoJournalSection
                        
                        // Recent Entries
                        recentEntriesSection
                    }
                    .padding()
                }
            }
            .navigationTitle("My Progress")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingPhotoCapture) {
            PhotoCaptureView()
        }
    }
    
    private var dailyCheckInSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            Text("How are you feeling today?")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.text)
            
            VStack(spacing: Theme.spacing16) {
                scoreSlider(title: "Overall Mood", score: $moodScore, icon: "face.smiling")
                scoreSlider(title: "Skin Condition", score: $skinScore, icon: "sparkles")
            }
            
            VStack(alignment: .leading, spacing: Theme.spacing8) {
                Text("Notes (optional)")
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.text)
                
                TextField("How did your skin feel today? Any reactions?", text: $journalNote, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }
            
            Button(action: saveEntry) {
                Text("Save Today's Entry")
                    .frame(maxWidth: .infinity)
            }
            .primaryStyle()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(Theme.cornerRadiusMedium)
    }
    
    private var progressChartSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            Text("30-Day Trend")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.text)
            
            // Mock progress chart
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(0..<30, id: \.self) { day in
                    Rectangle()
                        .fill(Theme.primary.opacity(0.7))
                        .frame(width: 8, height: CGFloat.random(in: 20...80))
                        .cornerRadius(4)
                }
            }
            .frame(height: 100)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Average Score")
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.text.opacity(0.6))
                    
                    Text("4.2/5")
                        .font(Theme.headlineFont)
                        .foregroundColor(Theme.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Consistency")
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.text.opacity(0.6))
                    
                    Text("23/30 days")
                        .font(Theme.headlineFont)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(Theme.cornerRadiusMedium)
    }
    
    private var photoJournalSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            HStack {
                Text("Photo Journal")
                    .font(Theme.headlineFont)
                    .foregroundColor(Theme.text)
                
                Spacer()
                
                Button(action: { showingPhotoCapture = true }) {
                    Image(systemName: "camera.fill")
                        .foregroundColor(Theme.primary)
                }
            }
            
            Text("Track your progress with standardized photos. All images stay private on your device.")
                .font(Theme.captionFont)
                .foregroundColor(Theme.text.opacity(0.6))
            
            // Mock photo grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                ForEach(0..<8, id: \.self) { _ in
                    Rectangle()
                        .fill(Theme.secondary.opacity(0.2))
                        .frame(height: 80)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(Theme.text.opacity(0.4))
                        )
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(Theme.cornerRadiusMedium)
    }
    
    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacing16) {
            Text("Recent Entries")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.text)
            
            VStack(spacing: Theme.spacing12) {
                ForEach(getMockEntries(), id: \.date) { entry in
                    AdherenceEntryRow(entry: entry)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(Theme.cornerRadiusMedium)
    }
    
    private func scoreSlider(title: String, score: Binding<Double>, icon: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacing8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Theme.primary)
                
                Text(title)
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.text)
                
                Spacer()
                
                Text(String(format: "%.0f/5", score.wrappedValue))
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.primary)
            }
            
            Slider(value: score, in: 1...5, step: 1)
                .tint(Theme.primary)
        }
    }
    
    private func saveEntry() {
        print("Saving entry - Mood: \(moodScore), Skin: \(skinScore), Note: \(journalNote)")
        // Reset form
        journalNote = ""
    }
    
    private func getMockEntries() -> [MockAdherenceEntry] {
        return [
            MockAdherenceEntry(date: "Today", moodScore: 4, skinScore: 4, note: "Skin feeling smooth and hydrated"),
            MockAdherenceEntry(date: "Yesterday", moodScore: 3, skinScore: 5, note: "Great day! No irritation"),
            MockAdherenceEntry(date: "2 days ago", moodScore: 4, skinScore: 3, note: nil)
        ]
    }
}

// MARK: - Enhanced Profile/Settings View
struct EnhancedProfileView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var showingEditProfile = false
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.spacing24) {
                        // User Header
                        userHeaderSection
                        
                        // Quick Stats
                        quickStatsSection
                        
                        // Menu Options
                        menuOptionsSection
                        
                        // Pro Section
                        proSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
                .environmentObject(authService)
        }
        .alert("Reset Onboarding", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetOnboardingState()
            }
        } message: {
            Text("This will clear all onboarding progress and restart the flow. The app will restart.")
        }
    }
    
    private var userHeaderSection: some View {
        HStack {
            Circle()
                .fill(Theme.primary.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Text("JD")
                        .font(.title)
                        .foregroundColor(Theme.primary)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(authService.currentUser?.email ?? "User")
                    .font(Theme.headlineFont)
                    .foregroundColor(Theme.text)
                
                Text("Member since \(memberSinceText)")
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.text.opacity(0.6))
                
                HStack {
                    if let skinTypeText = skinTypeText {
                        Text(skinTypeText)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Theme.secondary.opacity(0.3))
                            .foregroundColor(Theme.text)
                            .cornerRadius(4)
                    }
                    
                    Text(budgetTierText)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Theme.primary.opacity(0.2))
                        .foregroundColor(Theme.primary)
                        .cornerRadius(4)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(Theme.cornerRadiusMedium)
    }
    
    private var quickStatsSection: some View {
        HStack {
            statCard(title: "Routine Days", value: "23", subtitle: "This month")
            statCard(title: "Avg Score", value: "4.2", subtitle: "Out of 5")
            statCard(title: "Products", value: "8", subtitle: "In routine")
        }
    }
    
    private var menuOptionsSection: some View {
        VStack(spacing: 0) {
            menuItem(icon: "person.crop.circle", title: "Edit Profile", subtitle: "Update skin type & preferences") {
                showingEditProfile = true
            }
            
            Divider().padding(.leading, 50)
            
            menuItem(icon: "heart.fill", title: "Favorites", subtitle: "Saved products & routines") {
                // View favorites
            }
            
            Divider().padding(.leading, 50)
            
            menuItem(icon: "chart.line.uptrend.xyaxis", title: "Progress", subtitle: "View detailed analytics") {
                // View progress
            }
            
            Divider().padding(.leading, 50)
            
            menuItem(icon: "gear", title: "Settings", subtitle: "Notifications, privacy & more") {
                showingSettings = true
            }
            
            Divider().padding(.leading, 50)
            
            menuItem(icon: "questionmark.circle", title: "Help & Support", subtitle: "FAQs, contact us") {
                // Help
            }
            
            #if DEBUG
            Divider().padding(.leading, 50)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Debug Info")
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.text.opacity(0.5))
                    .padding(.leading, 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("hasCompletedOnboarding: \(UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") ? "true" : "false")")
                    Text("hasSkippedToMain: \(UserDefaults.standard.bool(forKey: "hasSkippedToMain") ? "true" : "false")")
                    Text("isGuestMode: \(UserDefaults.standard.bool(forKey: "isGuestMode") ? "true" : "false")")
                }
                .font(Theme.captionFont)
                .foregroundColor(Theme.text.opacity(0.6))
                .padding(.leading, 50)
            }
            
            menuItem(icon: "arrow.clockwise.circle", title: "Reset Onboarding", subtitle: "Clear all progress & restart") {
                showingResetAlert = true
            }
            #endif
        }
        .background(Color.white)
        .cornerRadius(Theme.cornerRadiusMedium)
    }
    
    private var proSection: some View {
        Button(action: { showingPaywall = true }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("✨ Upgrade to Pro")
                        .font(Theme.headlineFont)
                        .foregroundColor(.white)
                    
                    Text("Advanced filters, unlimited swaps, price alerts")
                        .font(Theme.captionFont)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Theme.primary, Theme.secondary],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(Theme.cornerRadiusMedium)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func statCard(title: String, value: String, subtitle: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title)
                .foregroundColor(Theme.primary)
            
            Text(title)
                .font(Theme.captionFont)
                .foregroundColor(Theme.text)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(Theme.text.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(Theme.cornerRadiusMedium)
    }
    
    private func menuItem(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Theme.primary)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.text)
                    
                    Text(subtitle)
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.text.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Theme.text.opacity(0.4))
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Computed Properties for Dynamic Data
    private var memberSinceText: String {
        guard let user = authService.currentUser else { return "Recently" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: user.createdAt)
    }
    
    private var skinTypeText: String? {
        guard let profile = authService.currentUser?.profile else { return nil }
        
        var text = profile.baseType.displayName
        
        var modifiers: [String] = []
        if profile.sensitive { modifiers.append("Sensitive") }
        if profile.acneProne { modifiers.append("Acne-Prone") }
        if profile.pigmentationProne { modifiers.append("Pigmentation-Prone") }
        
        if !modifiers.isEmpty {
            text += " • " + modifiers.joined(separator: ", ")
        }
        
        return text
    }
    
    private var budgetTierText: String {
        let tier = authService.currentUser?.preferences.budgetTier ?? .balanced
        return "\(tier.displayName) Budget"
    }
    
    #if DEBUG
    private func resetOnboardingState() {
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "hasSkippedToMain")
        UserDefaults.standard.removeObject(forKey: "isGuestMode")
        
        // Force app to restart by posting notification or using exit
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = UIHostingController(rootView: ContentView())
            }
        }
    }
    #endif
}

// MARK: - Supporting Models & Views
struct MockAdherenceEntry {
    let date: String
    let moodScore: Int
    let skinScore: Int
    let note: String?
}

struct AdherenceEntryRow: View {
    let entry: MockAdherenceEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.date)
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.text)
                
                if let note = entry.note {
                    Text(note)
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            VStack {
                Text("\(entry.moodScore + entry.skinScore)/10")
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.primary)
                
                Text("Score")
                    .font(.caption2)
                    .foregroundColor(Theme.text.opacity(0.6))
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Placeholder Views
struct PhotoCaptureView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Photo Capture Coming Soon")
                .font(Theme.headlineFont)
            
            Button("Done") {
                dismiss()
            }
            .primaryStyle()
        }
        .padding()
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Settings Coming Soon")
                    .font(Theme.headlineFont)
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Pro Features Coming Soon")
                    .font(Theme.headlineFont)
            }
            .navigationTitle("Skinfluence Pro")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ShareRoutineView_Previews: PreviewProvider {
    static var previews: some View {
        ShareRoutineView()
    }
}

struct AdherenceTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        AdherenceTrackingView()
    }
}

struct EnhancedProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedProfileView()
            .environmentObject(AuthService.shared)
    }
}