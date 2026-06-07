//
//  AddGoalView.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 14/05/2026.
//

import SwiftUI
import SwiftData

struct AddGoalView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showingEnergyInfo: GrowthEnergy?
    @State private var showingCustomDatePicker: Bool = false
    
    @State private var goalTitle: String = ""
    @State private var reminderAction: String = ""
    @State private var selectedDuration: GoalDuration = .oneWeek
    @State private var selectedEnergy: GrowthEnergy = .sunny
    
    @State private var customStartDate: Date = Date()
    @State private var customEndDate: Date = Calendar.current.date(
        byAdding: .day,
        value: 7,
        to: Date()
    ) ?? Date()
    
    @ScaledMetric(relativeTo: .body) private var textFieldMinHeight: CGFloat = 58
    @ScaledMetric(relativeTo: .body) private var durationButtonMinHeight: CGFloat = 38
    
    private var canCreateGoal: Bool {
        !goalTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !reminderAction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var finalDurationDays: Int {
        selectedDuration == .custom ? customDurationDays : selectedDuration.days
    }
    
    private var goalStartDate: Date {
        selectedDuration == .custom ? customStartDate : Date()
    }
    
    private var customDurationDays: Int {
        let start = Calendar.current.startOfDay(for: customStartDate)
        let end = Calendar.current.startOfDay(for: customEndDate)
        
        let days = Calendar.current.dateComponents(
            [.day],
            from: start,
            to: end
        ).day ?? 0
        
        return max(days + 1, 1)
    }
    
    var body: some View {
        ZStack {
            background
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    header
                    goalInputSection
                    durationSection
                    growthModeSection
                    createButton
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 120)
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(item: $showingEnergyInfo) { energy in
            GrowthEnergyInfoSheet(energy: energy)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingCustomDatePicker) {
            CustomDurationSheet(
                startDate: $customStartDate,
                endDate: $customEndDate
            ) {
                selectedDuration = .custom
                showingCustomDatePicker = false
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - UI Sections

private extension AddGoalView {
    
    var backgroundColor: Color {
        Color("background")
    }
    
    var primaryTextColor: Color {
        colorScheme == .dark
        ? /*Color(red: 1.0, green: 0.97, blue: 0.90)*/ .white
        : .black
    }
    
    var secondaryTextColor: Color {
        colorScheme == .dark
        ? /*Color(red: 0.92, green: 0.88, blue: 0.78)*/ .white
        : .black.opacity(0.75)
    }
    
    var placeholderTextColor: Color {
        colorScheme == .dark
        ? Color(red: 0.82, green: 0.78, blue: 0.70)
        : .black.opacity(0.35)
    }
    
    var fieldBackgroundColor: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.18)
        : Color.white.opacity(0.78)
    }
    
    var fieldBorderColor: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.35)
        : Color.black.opacity(0.18)
    }
    
    var unselectedButtonColor: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.18)
        : Color.white.opacity(0.75)
    }
    
    var background: some View {
        backgroundColor
            .ignoresSafeArea()
    }
    
    var header: some View {
        ZStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(primaryTextColor)
                        .accessibilityLabel("Back")
                }
                
                Spacer()
            }
            
            Text("Add new goal")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(primaryTextColor)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
    }
    
    var goalInputSection: some View {
        VStack(spacing: 24) {
            textInput(
                title: "What's your goal?",
                placeholder: "e.g. Learn Swift, Read a Book...",
                text: $goalTitle
            )
            
            textInput(
                title: "What should we remind you to do?",
                placeholder: "e.g. Watch one lesson, Read 10 Pages...",
                text: $reminderAction
            )
        }
    }
    
    var durationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Duration")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(primaryTextColor)
            
            HStack(spacing: 10) {
                ForEach(GoalDuration.allCases) { duration in
                    durationButton(duration)
                }
            }
        }
    }
    
    var growthModeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Pick your growth mode")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(primaryTextColor)
                .fixedSize(horizontal: false, vertical: true)
            
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 14),
                    GridItem(.flexible(), spacing: 14)
                ],
                spacing: 14
            ) {
                ForEach(GrowthEnergy.allCases) { energy in
                    GrowthEnergyMiniCard(
                        energy: energy,
                        isSelected: selectedEnergy == energy
                    ) {
                        selectedEnergy = energy
                    } infoAction: {
                        showingEnergyInfo = energy
                    }
                }
            }
        }
    }
    
    var createButton: some View {
        Button {
            createGoal()
        } label: {
            Text("Create Goal")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .frame(minHeight: 48)
                .background(
                    Capsule()
                        .fill(canCreateGoal ? Color.green : Color.gray.opacity(0.55))
                )
        }
        .disabled(!canCreateGoal)
        .padding(.top, 4)
    }
}

// MARK: - Small Components

private extension AddGoalView {
    
    func textInput(
        title: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(primaryTextColor)
                .fixedSize(horizontal: false, vertical: true)
            
            TextField(
                "",
                text: text,
                prompt: Text(placeholder)
                    .foregroundStyle(placeholderTextColor),
                axis: .vertical
            )
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(primaryTextColor)
            .tint(Color.green)
            .lineLimit(1...3)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minHeight: textFieldMinHeight)
            .background(fieldBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(fieldBorderColor, lineWidth: 1)
            )
        }
    }
    
    func durationButton(_ duration: GoalDuration) -> some View {
        let isSelected = selectedDuration == duration
        
        return Button {
            if duration == .custom {
                showingCustomDatePicker = true
            } else {
                selectedDuration = duration
            }
        } label: {
            Text(durationTitle(for: duration))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(isSelected ? .white : secondaryTextColor)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .multilineTextAlignment(.center)
                .frame(height: durationButtonMinHeight)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.green : unselectedButtonColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            isSelected ? Color.green : fieldBorderColor,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
    
    func durationTitle(for duration: GoalDuration) -> String {
        if duration == .custom && selectedDuration == .custom {
            return "\(customDurationDays) Days"
        }
        
        return duration.title
    }
}

// MARK: - Logic

private extension AddGoalView {
    
    func createGoal() {
        let goal = Goal(
            title: goalTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            subGoal: reminderAction.trimmingCharacters(in: .whitespacesAndNewlines),
            durationDays: finalDurationDays,
            selectedEnergy: selectedEnergy,
            createdAt: goalStartDate
        )
        
        modelContext.insert(goal)
        
        do {
            try modelContext.save()
            
            Task {
                await AchivoNotificationManager.scheduleDailyNotifications(
                    for: selectedEnergy
                )
            }
            
            router.goToGoals()
            dismiss()
            
        } catch {
            print("Failed to save goal:", error.localizedDescription)
        }
    }
}

// MARK: - Growth Energy Info Sheet

private struct GrowthEnergyInfoSheet: View {
    
    let energy: GrowthEnergy
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var backgroundColor: Color {
        Color("background")
    }
    
    private var primaryTextColor: Color {
        colorScheme == .dark
        ? Color(red: 1.0, green: 0.97, blue: 0.90)
        : .black
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark
        ? Color(red: 0.92, green: 0.88, blue: 0.78)
        : .secondary
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Image(energy.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 120)
                    .accessibilityHidden(true)
                
                Text(energy.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(energy.color)
                    .multilineTextAlignment(.center)
                
                Text(energy.title)
                    .font(.headline)
                    .foregroundStyle(primaryTextColor)
                    .multilineTextAlignment(.center)
                
                Text(energy.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(secondaryTextColor)
                    .padding(.horizontal, 24)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(spacing: 8) {
                    Text("Best for")
                        .font(.caption)
                        .foregroundStyle(secondaryTextColor)
                    
                    Text(energy.bestFor)
                        .font(.headline)
                        .foregroundStyle(energy.color)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 8)
            }
            .padding(24)
        }
        .background(backgroundColor)
        .presentationBackground(backgroundColor)
    }
}

// MARK: - Custom Duration Sheet

private struct CustomDurationSheet: View {
    
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    let onDone: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var backgroundColor: Color {
        Color("background")
    }
    
    private var primaryTextColor: Color {
        colorScheme == .dark
        ? Color(red: 1.0, green: 0.97, blue: 0.90)
        : .black
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark
        ? Color(red: 0.92, green: 0.88, blue: 0.78)
        : .secondary
    }
    
    private var durationDays: Int {
        let start = Calendar.current.startOfDay(for: startDate)
        let end = Calendar.current.startOfDay(for: endDate)
        
        let days = Calendar.current.dateComponents(
            [.day],
            from: start,
            to: end
        ).day ?? 0
        
        return max(days + 1, 1)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            
            Text("Custom duration")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(primaryTextColor)
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(alignment: .leading, spacing: 14) {
                DatePicker(
                    "Start date",
                    selection: $startDate,
                    displayedComponents: .date
                )
                
                DatePicker(
                    "End date",
                    selection: $endDate,
                    in: startDate...,
                    displayedComponents: .date
                )
            }
            .font(.headline)
            .foregroundStyle(primaryTextColor)
            
            Text("Your goal will last \(durationDays) days.")
                .font(.subheadline)
                .foregroundStyle(secondaryTextColor)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            Button {
                onDone()
            } label: {
                Text("Done")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 48)
                    .background(
                        Capsule()
                            .fill(Color.green)
                    )
            }
        }
        .padding(24)
        .background(backgroundColor)
        .presentationBackground(backgroundColor)
        .onChange(of: startDate) { _, newValue in
            if endDate < newValue {
                endDate = newValue
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AddGoalView()
        .environment(AppRouter())
        .modelContainer(for: Goal.self, inMemory: true)
}
