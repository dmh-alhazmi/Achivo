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
                .presentationDetents([.medium])
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
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - UI Sections

private extension AddGoalView {
    
    var background: some View {
        Color("background")
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
                        .foregroundStyle(.black)
                }
                
                Spacer()
            }
            
            Text("Add new goal")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.black)
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
                .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.24))
            
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
                .foregroundStyle(.black)
            
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
                .frame(width: 170, height: 48)
                .background(
                    Capsule()
                        .fill(canCreateGoal ? Color.green : Color.gray.opacity(0.5))
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
                .foregroundStyle(.black)
            
            TextField(placeholder, text: text)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .frame(height: 58)
                .background(Color.white.opacity(0.78))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black.opacity(0.18), lineWidth: 1)
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
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? .white : .black.opacity(0.75))
                .frame(height: 38)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.green : Color.white.opacity(0.75))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            isSelected ? Color.green : Color.black.opacity(0.18),
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
    
    var body: some View {
        VStack(spacing: 18) {
            Image(energy.assetName)
                .resizable()
                .scaledToFit()
                .frame(height: 110)
            
            Text(energy.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(energy.color)
            
            Text(energy.title)
                .font(.headline)
                .foregroundStyle(.black)
            
            Text(energy.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 24)
            
            VStack(spacing: 8) {
                Text("Best for")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(energy.bestFor)
                    .font(.headline)
                    .foregroundStyle(energy.color)
            }
            .padding(.top, 8)
        }
        .padding()
    }
}

// MARK: - Custom Duration Sheet

private struct CustomDurationSheet: View {
    
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    let onDone: () -> Void
    
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
                .foregroundStyle(.black)
            
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
            
            Text("Your goal will last \(durationDays) days.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Button {
                onDone()
            } label: {
                Text("Done")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        Capsule()
                            .fill(Color.green)
                    )
            }
        }
        .padding(24)
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
