//
//  RoutineViews.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import SwiftUI

// MARK: - Enhanced Routine Home View
struct EnhancedRoutineHomeView: View {
    @State private var selectedTimeOfDay: TimeOfDay = .morning
    @State private var completedSteps: Set<String> = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.spacing24) {
                        // Time Selector
                        timeSelector
                        
                        // Routine Steps
                        routineSteps
                        
                        // Weekly Plan Teaser
                        weeklyPlanCard
                        
                        // Action Buttons
                        actionButtons
                    }
                    .padding()
                }
            }
            .navigationTitle("My Routine")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var timeSelector: some View {
        HStack(spacing: 0) {
            ForEach(TimeOfDay.allCases, id: \.self) { time in
                Button(action: { selectedTimeOfDay = time }) {
                    Text(time.displayName)
                        .font(Theme.bodyFont)
                        .foregroundColor(selectedTimeOfDay == time ? .white : Theme.text)
                        .padding(.vertical, Theme.spacing12)
                        .frame(maxWidth: .infinity)
                        .background(selectedTimeOfDay == time ? Theme.primary : Color.clear)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(Theme.cornerRadiusLarge)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                .stroke(Theme.primary, lineWidth: 1)
        )
    }
    
    private var routineSteps: some View {
        VStack(spacing: Theme.spacing16) {
            ForEach(getMockSteps(), id: \.id) { step in
                RoutineStepCard(
                    step: step,
                    isCompleted: completedSteps.contains(step.id)
                ) {
                    toggleStepCompletion(step.id)
                }
            }
        }
    }
    
    private var weeklyPlanCard: some View {
        Button(action: {
            // Navigate to weekly plan
        }) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.spacing8) {
                    Text("Weekly Plan")
                        .font(Theme.headlineFont)
                        .foregroundColor(Theme.text)
                    
                    Text("Retinoid: Mon, Thu • Exfoliant: Wed • Mask: Fri")
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.text.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "calendar")
                    .foregroundColor(Theme.primary)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Theme.text.opacity(0.4))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(Theme.cornerRadiusMedium)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var actionButtons: some View {
        VStack(spacing: Theme.spacing12) {
            Button(action: {
                // Share routine
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share My Routine")
                }
                .frame(maxWidth: .infinity)
            }
            .secondaryStyle()
            
            Button(action: {
                // Regenerate routine
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Refresh Recommendations")
                }
                .frame(maxWidth: .infinity)
            }
            .primaryStyle()
        }
    }
    
    private func getMockSteps() -> [RoutineStep] {
        switch selectedTimeOfDay {
        case .morning:
            return [
                RoutineStep(id: "am-1", stepType: "Cleanser", productName: "Gentle Cloud Cleanser", brand: "CloudSkin", explanation: "Removes overnight buildup gently", badges: ["Fragrance-Free"]),
                RoutineStep(id: "am-2", stepType: "Essence", productName: "Rice Glow Essence", brand: "GlowLab", explanation: "Hydrates and preps for serums", badges: ["Best Value"]),
                RoutineStep(id: "am-3", stepType: "Serum", productName: "Vitamin C 10%", brand: "BrightLab", explanation: "Brightens and protects from pollution", badges: []),
                RoutineStep(id: "am-4", stepType: "Moisturizer", productName: "Aqua Gel Cream", brand: "AquaK", explanation: "Lightweight hydration", badges: ["Best Value"]),
                RoutineStep(id: "am-5", stepType: "Sunscreen", productName: "UV Shield SPF 50", brand: "SunVeil", explanation: "Essential daily protection", badges: ["Pregnancy-Safe"])
            ]
        case .evening:
            return [
                RoutineStep(id: "pm-1", stepType: "Cleanser", productName: "Gentle Cloud Cleanser", brand: "CloudSkin", explanation: "Removes makeup and daily buildup", badges: ["Fragrance-Free"]),
                RoutineStep(id: "pm-2", stepType: "Essence", productName: "Rice Glow Essence", brand: "GlowLab", explanation: "Prepares skin for treatments", badges: ["Best Value"]),
                RoutineStep(id: "pm-3", stepType: "Treatment", productName: "Retinoid 0.2%", brand: "NightRx", explanation: "Anti-aging and pore refinement", badges: []),
                RoutineStep(id: "pm-4", stepType: "Moisturizer", productName: "Ceramide Barrier Cream", brand: "BarrierFix", explanation: "Repairs and strengthens overnight", badges: ["Fragrance-Free"])
            ]
        }
    }
    
    private func toggleStepCompletion(_ stepId: String) {
        if completedSteps.contains(stepId) {
            completedSteps.remove(stepId)
        } else {
            completedSteps.insert(stepId)
        }
    }
}

// MARK: - Supporting Models
enum TimeOfDay: String, CaseIterable {
    case morning = "morning"
    case evening = "evening"
    
    var displayName: String {
        switch self {
        case .morning: return "Morning"
        case .evening: return "Evening"
        }
    }
}

struct RoutineStep {
    let id: String
    let stepType: String
    let productName: String
    let brand: String
    let explanation: String
    let badges: [String]
}

// MARK: - Routine Step Card
struct RoutineStepCard: View {
    let step: RoutineStep
    let isCompleted: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            // Completion Toggle
            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isCompleted ? .green : Theme.text.opacity(0.4))
            }
            .buttonStyle(PlainButtonStyle())
            
            // Product Info
            VStack(alignment: .leading, spacing: Theme.spacing8) {
                HStack {
                    Text("\(step.stepType)")
                        .font(Theme.headlineFont)
                        .foregroundColor(Theme.text)
                    
                    Spacer()
                    
                    // Badges
                    ForEach(step.badges, id: \.self) { badge in
                        Text(badge)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(badgeColor(for: badge))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }
                
                Text("\(step.brand) \(step.productName)")
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.text.opacity(0.8))
                
                Text(step.explanation)
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.text.opacity(0.6))
            }
            
            // Action Buttons
            VStack(spacing: 4) {
                Button(action: {
                    // Show product details
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(Theme.primary)
                }
                
                Button(action: {
                    // Show where to buy
                }) {
                    Image(systemName: "cart")
                        .foregroundColor(Theme.primary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(Theme.cornerRadiusMedium)
        .opacity(isCompleted ? 0.7 : 1.0)
    }
    
    private func badgeColor(for badge: String) -> Color {
        switch badge {
        case "Best Value": return .orange
        case "Pregnancy-Safe": return .green
        case "Fragrance-Free": return .blue
        default: return Theme.primary
        }
    }
}

// MARK: - Weekly Plan View
struct WeeklyPlanView: View {
    private let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.spacing24) {
                        // Header
                        Text("Your weekly plan helps prevent over-exfoliation and ingredient conflicts")
                            .font(Theme.bodyFont)
                            .foregroundColor(Theme.text.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Weekly Calendar
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: Theme.spacing12) {
                            ForEach(weekDays, id: \.self) { day in
                                WeeklyDayCard(
                                    day: day,
                                    treatments: getTreatmentsFor(day)
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Guidelines
                        guidelinesCard
                    }
                }
            }
            .navigationTitle("Weekly Plan")
        }
    }
    
    private var guidelinesCard: some View {
        VStack(alignment: .leading, spacing: Theme.spacing12) {
            Text("Guidelines")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.text)
            
            VStack(alignment: .leading, spacing: Theme.spacing8) {
                GuidelineRow(icon: "moon.fill", text: "Use retinoids only at night")
                GuidelineRow(icon: "sun.max.fill", text: "Always wear SPF when using actives")
                GuidelineRow(icon: "exclamationmark.triangle.fill", text: "Don't stack strong actives")
                GuidelineRow(icon: "calendar.badge.clock", text: "Start slow and build tolerance")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(Theme.cornerRadiusMedium)
        .padding(.horizontal)
    }
    
    private func getTreatmentsFor(_ day: String) -> [String] {
        switch day {
        case "Mon", "Thu": return ["Retinoid"]
        case "Wed": return ["Exfoliant"]
        case "Fri": return ["Mask"]
        default: return []
        }
    }
}

struct WeeklyDayCard: View {
    let day: String
    let treatments: [String]
    
    var body: some View {
        VStack(spacing: Theme.spacing8) {
            Text(day)
                .font(Theme.bodyFont)
                .foregroundColor(Theme.text)
            
            VStack(spacing: 2) {
                ForEach(treatments, id: \.self) { treatment in
                    Text(treatment)
                        .font(.caption2)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(treatmentColor(for: treatment))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            }
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(treatments.isEmpty ? Color.white.opacity(0.5) : Color.white)
        .cornerRadius(Theme.cornerRadiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                .stroke(treatments.isEmpty ? Color.clear : Theme.primary, lineWidth: 1)
        )
    }
    
    private func treatmentColor(for treatment: String) -> Color {
        switch treatment {
        case "Retinoid": return .purple
        case "Exfoliant": return .orange
        case "Mask": return .green
        default: return Theme.primary
        }
    }
}

struct GuidelineRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Theme.primary)
                .frame(width: 20)
            
            Text(text)
                .font(Theme.captionFont)
                .foregroundColor(Theme.text.opacity(0.8))
        }
    }
}

struct EnhancedRoutineHomeView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedRoutineHomeView()
    }
}

struct WeeklyPlanView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyPlanView()
    }
}