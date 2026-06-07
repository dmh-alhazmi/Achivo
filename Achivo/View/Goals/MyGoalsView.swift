//
//  MyGoalsView.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 03/05/2026.
//

import SwiftUI
import SwiftData
import WidgetKit

struct MyGoalsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    
    @Query(sort: \Goal.createdAt, order: .reverse)
    private var goals: [Goal]
    
    @State private var showAddGoalView: Bool = false
    @State private var showGrowthEnergiesInfoView: Bool = false
    @State private var earnedBadge: AchievementBadge?
    
    var body: some View {
        NavigationStack {
            ZStack {
                background
                
                if goals.isEmpty {
                    NoGoalsView {
                        showAddGoalView = true
                    }
                    .ignoresSafeArea()
                } else {
                    VStack(spacing: 20) {
                        header
                        goalsList
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 24)
                }
            }
            .onAppear {
                BadgeAwardManager.prepareBadgesIfNeeded(
                    modelContext: modelContext
                )
                
                refreshGoalStatuses()
                updateWidgetGoalsProgress()
            }
            .onChange(of: widgetRefreshToken) {
                refreshGoalStatuses()
                updateWidgetGoalsProgress()
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showAddGoalView) {
                AddGoalView()
            }
            .fullScreenCover(isPresented: $showGrowthEnergiesInfoView) {
                GrowthEnergiesInfoView {
                    showGrowthEnergiesInfoView = false
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
}

// MARK: - Colors

private extension MyGoalsView {
    
    var primaryTextColor: Color {
        colorScheme == .dark
        ? Color(red: 1.0, green: 0.97, blue: 0.90)
        : .black
    }
    
    var secondaryTextColor: Color {
        colorScheme == .dark
        ? Color(red: 0.92, green: 0.88, blue: 0.78)
        : .secondary
    }
}

// MARK: - UI

private extension MyGoalsView {
    
    var background: some View {
        Image("AppBackground")
            .resizable()
            .ignoresSafeArea()
    }
    
    var header: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                
                Button {
                    showGrowthEnergiesInfoView = true
                } label: {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(primaryTextColor)
                }
            }
            
            HStack(spacing: 4) {
                Text("Your")
                    .foregroundStyle(primaryTextColor)
                
                Text("Goals")
                    .foregroundStyle(Color.green)
            }
            .font(.title2)
            .fontWeight(.bold)
            
            Text("Small steps today, big change tomorrow")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(secondaryTextColor)
        }
    }
    
    var goalsList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach(sortedGoals) { goal in
                    NavigationLink {
                        GoalDetailsView(goal: goal)
                    } label: {
                        GoalCardView(
                            goal: goal,
                            allGoals: goals
                        ) { badge in
                            earnedBadge = badge
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 110)
        }
        .overlay(alignment: .bottomTrailing) {
            addButton
                .padding(.trailing, 4)
                .padding(.bottom, 100)
        }
    }
    
    var addButton: some View {
        Button {
            showAddGoalView = true
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 54, height: 54)
                .background(
                    Circle()
                        .fill(Color.green)
                )
                .shadow(color: .black.opacity(0.22), radius: 8, x: 0, y: 5)
        }
    }
    
    var sortedGoals: [Goal] {
        goals.sorted { first, second in
            if goalSortOrder(first) == goalSortOrder(second) {
                return first.createdAt > second.createdAt
            }
            
            return goalSortOrder(first) < goalSortOrder(second)
        }
    }
    
    func goalSortOrder(_ goal: Goal) -> Int {
        switch goal.goalStatus {
        case .active:
            return 0
        case .inactive:
            return 1
        case .finished:
            return 2
        }
    }
    
    var widgetRefreshToken: String {
        goals.map { goal in
            "\(String(describing: goal.persistentModelID))-\(goal.subGoal)-\(goal.completedDays)-\(goal.durationDays)-\(goal.selectedEnergy.rawValue)-\(goal.isActive)-\(goal.isDoneToday)"
        }
        .joined(separator: "|")
    }
    
    private func refreshGoalStatuses() {
        for goal in goals {
            goal.deactivateIfNeeded()
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to refresh goal statuses:", error.localizedDescription)
        }
    }
    
    private func updateWidgetGoalsProgress() {
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
        
        AchivoWidgetSync.saveGoalsForWidget(widgetGoals)
    }
}

// MARK: - Badge Celebration Popup

private struct BadgeCelebrationPopup: View {
    
    let badge: AchievementBadge
    let onClose: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var popupBackgroundColor: Color {
        colorScheme == .dark
        ? Color(red: 0.22, green: 0.22, blue: 0.19)
        : .white
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
        ZStack {
            Color.black.opacity(0.32)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text("🎉")
                    .font(.system(size: 54))
                
                Image(badge.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 86, height: 86)
                    .padding(16)
                    .background(
                        Circle()
                            .fill(Color.green.opacity(colorScheme == .dark ? 0.22 : 0.12))
                    )
                
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
            .shadow(color: .black.opacity(0.22), radius: 18, x: 0, y: 10)
            .padding(.horizontal, 28)
        }
    }
}

// MARK: - Goal Card

private struct GoalCardView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    
    let goal: Goal
    let allGoals: [Goal]
    let onBadgeEarned: (AchievementBadge) -> Void
    
    private var energy: GrowthEnergy {
        goal.selectedEnergy
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 14) {
                checkButton
                
                VStack(alignment: .leading, spacing: 10) {
                    topRow
                    statusText
                    progressText
                    progressBar
                }
                
                Spacer()
                
                Image(energy.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .opacity(goal.goalStatus == .inactive ? 0.45 : 1)
            }
            
            if goal.goalStatus == .inactive {
                activateButton
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(cardStroke, lineWidth: 1)
        )
        .shadow(
            color: colorScheme == .dark ? .black.opacity(0.18) : .black.opacity(0.06),
            radius: 6,
            x: 0,
            y: 3
        )
        .opacity(goal.goalStatus == .inactive ? 0.82 : 1)
    }
}

// MARK: - Goal Card Colors

private extension GoalCardView {
    
    var primaryTextColor: Color {
        colorScheme == .dark
        ? Color(red: 1.0, green: 0.97, blue: 0.90)
        : .black
    }
    
    var secondaryTextColor: Color {
        colorScheme == .dark
        ? Color(red: 0.92, green: 0.88, blue: 0.78)
        : .secondary
    }
    
    var inactiveTextColor: Color {
        colorScheme == .dark
        ? Color(red: 0.72, green: 0.70, blue: 0.64)
        : .gray
    }
    
    var progressTrackColor: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.24)
        : Color.gray.opacity(0.15)
    }
}

// MARK: - Goal Card UI

private extension GoalCardView {
    
    var checkButton: some View {
        Button {
            toggleToday()
        } label: {
            Image(systemName: checkIcon)
                .font(.title3)
                .foregroundStyle(checkColor)
        }
        .buttonStyle(.plain)
        .disabled(goal.goalStatus != .active)
    }
    
    var checkIcon: String {
        if goal.goalStatus == .finished {
            return "checkmark.seal.fill"
        } else if goal.isDoneToday {
            return "checkmark.square.fill"
        } else {
            return "square"
        }
    }
    
    var checkColor: Color {
        switch goal.goalStatus {
        case .active:
            return goal.isDoneToday ? energy.color : primaryTextColor
        case .inactive:
            return inactiveTextColor
        case .finished:
            return .green
        }
    }
    
    var topRow: some View {
        HStack {
            Text(goal.subGoal)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(goal.goalStatus == .inactive ? inactiveTextColor : primaryTextColor)
                .lineLimit(1)
            
            Spacer()
            
            statusBadge
        }
    }
    
    var statusBadge: some View {
        Text(statusTitle)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(statusColor.opacity(colorScheme == .dark ? 0.22 : 0.12))
            )
    }
    
    var statusTitle: String {
        switch goal.goalStatus {
        case .active:
            return goal.isDoneToday ? "Done Today" : "Active"
        case .inactive:
            return "Inactive"
        case .finished:
            return "Finished"
        }
    }
    
    var statusColor: Color {
        switch goal.goalStatus {
        case .active:
            return energy.color
        case .inactive:
            return inactiveTextColor
        case .finished:
            return .green
        }
    }
    
    var statusText: some View {
        Text(statusMessage)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(goal.goalStatus == .inactive ? inactiveTextColor : secondaryTextColor)
            .lineLimit(2)
    }
    
    var statusMessage: String {
        switch goal.goalStatus {
        case .active:
            return goal.isDoneToday ? "Great job! Come back tomorrow." : "\(goal.remainingDays) days remaining"
        case .inactive:
            return "Time ended. Activate it to start again."
        case .finished:
            return "Amazing! You completed this goal."
        }
    }
    
    var progressText: some View {
        Text("\(goal.completedDays) / \(goal.durationDays) Days")
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(goal.goalStatus == .finished ? .green : energy.color)
    }
    
    var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(progressTrackColor)
                
                Capsule()
                    .fill(goal.goalStatus == .finished ? Color.green : energy.color)
                    .frame(width: geometry.size.width * min(max(goal.progress, 0), 1))
            }
        }
        .frame(height: 7)
    }
    
    var activateButton: some View {
        Button {
            activateAgain()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.clockwise")
                
                Text("Activate Again")
                    .fontWeight(.bold)
            }
            .font(.subheadline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                Capsule()
                    .fill(energy.color)
            )
        }
        .buttonStyle(.plain)
    }
    
    var cardBackground: Color {
        switch goal.goalStatus {
        case .active:
            return colorScheme == .dark
            ? Color(red: 0.22, green: 0.22, blue: 0.19)
            : Color.white.opacity(0.82)
            
        case .inactive:
            return colorScheme == .dark
            ? Color(red: 0.18, green: 0.18, blue: 0.16)
            : Color.gray.opacity(0.12)
            
        case .finished:
            return colorScheme == .dark
            ? Color(red: 0.20, green: 0.23, blue: 0.18)
            : Color.white.opacity(0.82)
        }
    }
    
    var cardStroke: Color {
        switch goal.goalStatus {
        case .active:
            return colorScheme == .dark
            ? Color.white.opacity(0.28)
            : Color.black.opacity(0.12)
            
        case .inactive:
            return colorScheme == .dark
            ? Color.white.opacity(0.18)
            : Color.gray.opacity(0.25)
            
        case .finished:
            return Color.green.opacity(colorScheme == .dark ? 0.45 : 0.28)
        }
    }
}

// MARK: - Goal Card Logic

private extension GoalCardView {
    
    func toggleToday() {
        guard goal.goalStatus == .active else { return }
        
        if goal.isDoneToday {
            goal.uncheckToday()
        } else {
            goal.checkToday()
            
            let earnedBadges = BadgeAwardManager.awardBadgesIfNeeded(
                afterUpdating: goal,
                allGoals: allGoals,
                modelContext: modelContext
            )
            
            if let firstBadge = earnedBadges.first {
                onBadgeEarned(firstBadge)
            }
        }
        
        do {
            try modelContext.save()
            syncWidgetAfterGoalChange()
        } catch {
            print("Failed to update goal:", error.localizedDescription)
        }
    }
    
    func activateAgain() {
        goal.restartGoal()
        
        do {
            try modelContext.save()
            syncWidgetAfterGoalChange()
        } catch {
            print("Failed to activate goal:", error.localizedDescription)
        }
    }
    
    func syncWidgetAfterGoalChange() {
        let widgetGoals = allGoals.map { goal in
            WidgetGoalProgress(
                id: String(describing: goal.persistentModelID),
                title: goal.subGoal,
                completedDays: goal.completedDays,
                durationDays: goal.durationDays,
                energyRawValue: goal.selectedEnergy.rawValue,
                tasks: []
            )
        }
        
        AchivoWidgetSync.saveGoalsForWidget(widgetGoals)
    }
}

// MARK: - Preview

#Preview {
    MyGoalsView()
        .modelContainer(sampleContainer)
}

@MainActor
private var sampleContainer: ModelContainer {
    do {
        let container = try ModelContainer(
            for: Goal.self, AchievementBadge.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        let context = container.mainContext
        
        let goal1 = Goal(
            title: "Reading Habit",
            subGoal: "Read 10 pages",
            durationDays: 10,
            selectedEnergy: .bluey,
            completedDays: 6
        )
        
        let goal2 = Goal(
            title: "Learn Swift",
            subGoal: "Watch one Swift lesson",
            durationDays: 7,
            selectedEnergy: .greeny,
            completedDays: 3
        )
        
        let goal3 = Goal(
            title: "Fitness Goal",
            subGoal: "Walk for 20 minutes",
            durationDays: 14,
            selectedEnergy: .fiery,
            completedDays: 14
        )
        
        let goal4 = Goal(
            title: "Positive Routine",
            subGoal: "Write one grateful thing",
            durationDays: 5,
            selectedEnergy: .sunny,
            completedDays: 1
        )
        
        context.insert(goal1)
        context.insert(goal2)
        context.insert(goal3)
        context.insert(goal4)
        
        return container
        
    } catch {
        fatalError("Failed to create sample container: \(error.localizedDescription)")
    }
}
