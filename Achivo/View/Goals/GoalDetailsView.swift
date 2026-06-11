//
//  GoalDetailsView.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 17/05/2026.
//

import SwiftUI
import SwiftData
import WidgetKit

struct GoalDetailsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    
    @Query(sort: \Goal.createdAt, order: .reverse)
    private var goals: [Goal]
    
    @State private var earnedBadge: AchievementBadge?
    
    @State private var isEditing: Bool
    @State private var editTitle: String
    @State private var editSubGoal: String
    @State private var editDurationDays: Int
    @State private var editEnergy: GrowthEnergy
    
    let goal: Goal
    
    init(goal: Goal, startInEditMode: Bool = false) {
        self.goal = goal
        
        _isEditing = State(initialValue: startInEditMode)
        _editTitle = State(initialValue: goal.title)
        _editSubGoal = State(initialValue: goal.subGoal)
        _editDurationDays = State(initialValue: goal.durationDays)
        _editEnergy = State(initialValue: goal.selectedEnergy)
    }
    
    private var energy: GrowthEnergy {
        isEditing ? editEnergy : goal.selectedEnergy
    }
    
    private var progress: Double {
        min(max(goal.progress, 0), 1)
    }
    
    private var progressPercent: Int {
        Int(progress * 100)
    }
    
    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    heroCard
                    progressCard
                    quickStatsGrid
                    
                    if isEditing {
                        editGoalCard
                    } else {
                        boostButton
                        goalInfoCard
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 20)
                .padding(.bottom, 140)
            }
        }
        .navigationTitle(isEditing ? "Edit Goal" : "Goal Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(colorScheme, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if isEditing {
                        cancelEditing()
                    } else {
                        startEditing()
                    }
                } label: {
                    Text(isEditing ? "Cancel" : "Edit")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.green)
                }
            }
        }
        .overlay {
            if let earnedBadge {
                BadgeCelebrationPopup(badge: earnedBadge) {
                    self.earnedBadge = nil
                }
            }
        }
    }
}

// MARK: - Colors

private extension GoalDetailsView {
    
    var primaryTextColor: Color {
        colorScheme == .dark
        ? Color(red: 1.0, green: 0.98, blue: 0.92)
        : .black
    }
    
    var secondaryTextColor: Color {
        colorScheme == .dark
        ? Color(red: 0.94, green: 0.90, blue: 0.82)
        : .black.opacity(0.58)
    }
    
    var cardBackgroundColor: Color {
        colorScheme == .dark
        ? Color(red: 0.22, green: 0.22, blue: 0.19)
        : Color.white.opacity(0.86)
    }
    
    var cardBorderColor: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.35)
        : energy.color.opacity(0.18)
    }
    
    var trackColor: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.30)
        : Color.gray.opacity(0.14)
    }
    
    var editFieldBackgroundColor: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.12)
        : Color.white.opacity(0.72)
    }
    
    var editFieldBorderColor: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.30)
        : Color.black.opacity(0.14)
    }
    
    var dividerColor: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.35)
        : Color.black.opacity(0.12)
    }
    
    var iconBackgroundColor: Color {
        colorScheme == .dark
        ? energy.color.opacity(0.28)
        : energy.color.opacity(0.12)
    }
}

// MARK: - UI

private extension GoalDetailsView {
    
    var heroCard: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(energy.color.opacity(colorScheme == .dark ? 0.22 : 0.16))
                    .frame(width: 150, height: 150)
                
                Image(energy.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 118)
            }
            
            VStack(spacing: 6) {
                Text(isEditing ? editTitle : goal.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(primaryTextColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text("Guided by \(energy.name) • \(energy.title)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            
            statusBadge
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(cardBackgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(cardBorderColor, lineWidth: 1)
        )
    }
    
    var statusBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: isEditing ? "pencil.circle.fill" : goal.isFinished ? "checkmark.seal.fill" : "sparkles")
                .font(.caption)
            
            Text(isEditing ? "Editing goal" : goal.isFinished ? "Goal completed" : "Keep going")
                .font(.caption)
                .fontWeight(.bold)
        }
        .foregroundStyle(isEditing ? Color.orange : goal.isFinished ? .green : energy.color)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(
                    (isEditing ? Color.orange : goal.isFinished ? Color.green : energy.color)
                        .opacity(colorScheme == .dark ? 0.22 : 0.13)
                )
        )
    }
    
    var progressCard: some View {
        HStack(spacing: 18) {
            progressCircle
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Progress")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(primaryTextColor)
                
                Text("\(goal.completedDays) of \(goal.durationDays) days completed")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(secondaryTextColor)
                
                progressBar
                
                Text(goal.isFinished ? "Amazing! You reached your goal." : "\(goal.remainingDays) days remaining")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(goal.isFinished ? .green : energy.color)
            }
            
            Spacer(minLength: 0)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(cardBackgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(cardBorderColor, lineWidth: 1)
        )
    }
    
    var progressCircle: some View {
        ZStack {
            Circle()
                .stroke(trackColor, lineWidth: 10)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    goal.isFinished ? Color.green : energy.color,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 0) {
                Text("\(progressPercent)%")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(primaryTextColor)
                
                Text("done")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(secondaryTextColor)
            }
        }
        .frame(width: 86, height: 86)
    }
    
    var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(trackColor)
                
                Capsule()
                    .fill(goal.isFinished ? Color.green : energy.color)
                    .frame(width: geometry.size.width * progress)
            }
        }
        .frame(height: 8)
    }
    
    var quickStatsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: 12
        ) {
            statCard(
                icon: "calendar",
                title: "Duration",
                value: "\(goal.durationDays) days"
            )
            
            statCard(
                icon: "flag.checkered",
                title: "Completed",
                value: "\(goal.completedDays) days"
            )
            
            statCard(
                icon: "hourglass",
                title: "Remaining",
                value: "\(goal.remainingDays) days"
            )
            
            statCard(
                icon: "leaf.fill",
                title: "Energy",
                value: energy.name
            )
        }
    }
    
    func statCard(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(energy.color)
                .frame(width: 34, height: 34)
                .background(
                    Circle()
                        .fill(iconBackgroundColor)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(secondaryTextColor)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(primaryTextColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(cardBackgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(cardBorderColor, lineWidth: 1)
        )
    }
    
    var boostButton: some View {
        Button {
            boostOneDay()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: goal.isFinished ? "checkmark.circle.fill" : "bolt.fill")
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(goal.isFinished ? "Goal Completed" : "Boost Today")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(goal.isFinished ? "You finished this journey" : "Complete all today’s tasks")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title3)
                    .opacity(goal.isFinished ? 0 : 1)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
            .frame(height: 68)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(goal.isFinished ? Color.gray : energy.color)
            )
            .shadow(
                color: energy.color.opacity(goal.isFinished ? 0 : 0.25),
                radius: 12,
                x: 0,
                y: 8
            )
        }
        .disabled(goal.isFinished || goal.goalStatus != .active)
    }
    
    var goalInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Goal Summary")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(primaryTextColor)
            
            Divider()
                .background(dividerColor)
            
            infoRow(
                icon: "target",
                title: "Main goal",
                value: goal.title
            )
            
            infoRow(
                icon: "checklist",
                title: "Daily tasks",
                value: goal.subGoal
            )
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(cardBackgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(cardBorderColor, lineWidth: 1)
        )
    }
    
    func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(energy.color)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(iconBackgroundColor)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(secondaryTextColor)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(primaryTextColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Edit UI

private extension GoalDetailsView {
    
    var editGoalCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Edit Goal")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(primaryTextColor)
            
            editTextField(
                title: "Main goal",
                text: $editTitle,
                placeholder: "e.g. Learn Swift"
            )
            
            editTextField(
                title: "Daily task",
                text: $editSubGoal,
                placeholder: "e.g. Watch one lesson"
            )
            
            durationEditor
            
            energyEditor
            
            HStack(spacing: 12) {
                Button {
                    cancelEditing()
                } label: {
                    Text("Cancel")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(primaryTextColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            Capsule()
                                .fill(trackColor)
                        )
                }
                
                Button {
                    saveEditing()
                } label: {
                    Text("Save")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            Capsule()
                                .fill(canSaveEdit ? Color.green : Color.gray.opacity(0.55))
                        )
                }
                .disabled(!canSaveEdit)
            }
            .padding(.top, 6)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(cardBackgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(cardBorderColor, lineWidth: 1)
        )
    }
    
    func editTextField(
        title: String,
        text: Binding<String>,
        placeholder: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(secondaryTextColor)
            
            TextField(
                "",
                text: text,
                prompt: Text(placeholder)
                    .foregroundStyle(secondaryTextColor.opacity(0.75))
            )
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(primaryTextColor)
            .tint(Color.green)
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(editFieldBackgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(editFieldBorderColor, lineWidth: 1)
            )
        }
    }
    
    var durationEditor: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Duration")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(secondaryTextColor)
            
            Stepper(
                value: $editDurationDays,
                in: max(goal.completedDays, 1)...365
            ) {
                HStack {
                    Text("\(editDurationDays) days")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(primaryTextColor)
                    
                    Spacer()
                    
                    if goal.completedDays > 0 {
                        Text("Min \(goal.completedDays)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(secondaryTextColor)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(editFieldBackgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(editFieldBorderColor, lineWidth: 1)
            )
        }
    }
    
    var energyEditor: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Growth energy")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(secondaryTextColor)
            
            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 10
            ) {
                ForEach(GrowthEnergy.allCases) { energy in
                    Button {
                        editEnergy = energy
                    } label: {
                        HStack(spacing: 8) {
                            Image(energy.assetName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                            
                            Text(energy.name)
                                .font(.caption)
                                .fontWeight(.bold)
                                .lineLimit(1)
                        }
                        .foregroundStyle(editEnergy == energy ? .white : energy.color)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    editEnergy == energy
                                    ? energy.color
                                    : energy.color.opacity(colorScheme == .dark ? 0.20 : 0.12)
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    editEnergy == energy
                                    ? energy.color
                                    : energy.color.opacity(0.35),
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    var canSaveEdit: Bool {
        !editTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !editSubGoal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Badge Celebration Popup

private struct BadgeCelebrationPopup: View {
    
    let badge: AchievementBadge
    let onClose: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var popupBackgroundColor: Color {
        colorScheme == .dark
        ? Color(red: 0.18, green: 0.18, blue: 0.16)
        : .white
    }
    
    private var primaryTextColor: Color {
        colorScheme == .dark
        ? Color(red: 1.0, green: 0.97, blue: 0.90)
        : .black
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark
        ? Color(red: 0.90, green: 0.86, blue: 0.76)
        : .secondary
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.30)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(badge.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 86, height: 86)
                    .padding(16)
                
                VStack(spacing: 6) {
                    Text("New Badge Collected!")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(primaryTextColor)
                    
                    Text(badge.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.green)
                    
                    Text(badge.badgeDescription)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(secondaryTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
                
                Button {
                    onClose()
                } label: {
                    Text("Yay!")
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
                .padding(.top, 8)
            }
            .padding(24)
            .frame(maxWidth: 310)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(popupBackgroundColor)
            )
            .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 10)
            .padding(.horizontal, 28)
        }
    }
}

// MARK: - Logic

private extension GoalDetailsView {
    
    func startEditing() {
        editTitle = goal.title
        editSubGoal = goal.subGoal
        editDurationDays = max(goal.durationDays, goal.completedDays, 1)
        editEnergy = goal.selectedEnergy
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            isEditing = true
        }
    }
    
    func cancelEditing() {
        editTitle = goal.title
        editSubGoal = goal.subGoal
        editDurationDays = max(goal.durationDays, goal.completedDays, 1)
        editEnergy = goal.selectedEnergy
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            isEditing = false
        }
    }
    
    func saveEditing() {
        let cleanTitle = editTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanSubGoal = editSubGoal.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanTitle.isEmpty, !cleanSubGoal.isEmpty else { return }
        
        goal.title = cleanTitle
        goal.subGoal = cleanSubGoal
        goal.durationDays = max(editDurationDays, goal.completedDays, 1)
        goal.selectedEnergyRawValue = editEnergy.rawValue
        
        do {
            try modelContext.save()
            syncWidgetAfterEditing()
            
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                isEditing = false
            }
        } catch {
            print("Failed to edit goal:", error.localizedDescription)
        }
    }
    
    func syncWidgetAfterEditing() {
        let widgetGoals = goals.map { goal in
            WidgetGoalProgress(
                id: String(describing: goal.persistentModelID),
                title: goal.subGoal,
                completedDays: goal.completedDays,
                durationDays: goal.durationDays,
                energyRawValue: goal.selectedEnergy.rawValue,
                tasks: []
            )
        }
        
        AchivoWidgetDataMapper.syncGoals(goals)
    }
    
    func boostOneDay() {
        guard goal.goalStatus == .active else { return }
        guard !goal.isFinished else { return }
        
        goal.boostOneFullDay()
        
        let earnedBadges = BadgeAwardManager.awardBadgesIfNeeded(
            afterUpdating: goal,
            allGoals: goals,
            modelContext: modelContext
        )
        
        if let firstBadge = earnedBadges.first {
            earnedBadge = firstBadge
        }
        
        do {
            try modelContext.save()
            
            AchivoWidgetDataMapper.syncGoals(goals)
            WidgetCenter.shared.reloadAllTimelines()
            
            Task {
                await AchivoLiveActivityManager.updateGoalLiveActivity(
                    goalTitle: goal.title,
                    progressPercent: Int(goal.progress * 100),
                    completedTasks: goal.completedTaskCount,
                    totalTasks: goal.totalTaskCount,
                    energy: goal.selectedEnergy
                )
            }
            
        } catch {
            print("Failed to boost goal:", error.localizedDescription)
        }
    }
}

#Preview {
    NavigationStack {
        GoalDetailsView(
            goal: Goal(
                title: "Read more books",
                subGoal: "Read 10 pages",
                durationDays: 10,
                selectedEnergy: .bluey,
                completedDays: 6
            )
        )
    }
    .modelContainer(
        for: [
            Goal.self,
            AchievementBadge.self
        ],
        inMemory: true
    )
}
