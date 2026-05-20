//
//  MyGoalsView.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 03/05/2026.
//

import SwiftUI
import SwiftData
import WidgetKit

private struct MyGoalWidgetData: Codable {
    let id: String
    let title: String
    let completedDays: Int
    let durationDays: Int
    let energyRawValue: String
}

struct MyGoalsView: View {
    
    @Environment(\.modelContext) private var modelContext
    
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

// MARK: - UI

private extension MyGoalsView {
    
    var background: some View {
        Color("background")
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
                        .foregroundStyle(.black)
                }
            }
            
            HStack(spacing: 4) {
                Text("Your")
                    .foregroundStyle(.black)
                
                Text("Goals")
                    .foregroundStyle(Color.green)
            }
            .font(.title2)
            .fontWeight(.bold)
            
            Text("Small steps today, big change tomorrow")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
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
                .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 5)
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
            MyGoalWidgetData(
                id: String(describing: goal.persistentModelID),
                title: goal.subGoal,
                completedDays: goal.completedDays,
                durationDays: goal.durationDays,
                energyRawValue: goal.selectedEnergy.rawValue
            )
        }
        
        do {
            let data = try JSONEncoder().encode(widgetGoals)
            
            let defaults = UserDefaults(suiteName: "group.com.Achivo.widget")
            defaults?.set(data, forKey: "widgetGoalsProgress")
            
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Failed to update widget goals:", error.localizedDescription)
        }
    }
}

// MARK: - Badge Celebration Popup

private struct BadgeCelebrationPopup: View {
    
    let badge: AchievementBadge
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.28)
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
                            .fill(Color.green.opacity(0.12))
                    )
                
                VStack(spacing: 6) {
                    Text("New Badge Collected!")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                    
                    Text(badge.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.green)
                    
                    Text(badge.badgeDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
                    .fill(Color.white)
            )
            .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 10)
            .padding(.horizontal, 28)
        }
    }
}

// MARK: - Goal Card

private struct GoalCardView: View {
    
    @Environment(\.modelContext) private var modelContext
    
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
        .opacity(goal.goalStatus == .inactive ? 0.78 : 1)
    }
    
    private var checkButton: some View {
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
    
    private var checkIcon: String {
        if goal.goalStatus == .finished {
            return "checkmark.seal.fill"
        } else if goal.isDoneToday {
            return "checkmark.square.fill"
        } else {
            return "square"
        }
    }
    
    private var checkColor: Color {
        switch goal.goalStatus {
        case .active:
            return goal.isDoneToday ? energy.color : .black
        case .inactive:
            return .gray
        case .finished:
            return .green
        }
    }
    
    private var topRow: some View {
        HStack {
            Text(goal.subGoal)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.black)
                .lineLimit(1)
            
            Spacer()
            
            statusBadge
        }
    }
    
    private var statusBadge: some View {
        Text(statusTitle)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(statusColor.opacity(0.12))
            )
    }
    
    private var statusTitle: String {
        switch goal.goalStatus {
        case .active:
            return goal.isDoneToday ? "Done Today" : "Active"
        case .inactive:
            return "Inactive"
        case .finished:
            return "Finished"
        }
    }
    
    private var statusColor: Color {
        switch goal.goalStatus {
        case .active:
            return energy.color
        case .inactive:
            return .gray
        case .finished:
            return .green
        }
    }
    
    private var statusText: some View {
        Text(statusMessage)
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(2)
    }
    
    private var statusMessage: String {
        switch goal.goalStatus {
        case .active:
            return goal.isDoneToday ? "Great job! Come back tomorrow." : "\(goal.remainingDays) days remaining"
        case .inactive:
            return "Time ended. Activate it to start again."
        case .finished:
            return "Amazing! You completed this goal."
        }
    }
    
    private var progressText: some View {
        Text("\(goal.completedDays) / \(goal.durationDays) Days")
            .font(.caption2)
            .foregroundStyle(goal.goalStatus == .finished ? .green : energy.color)
    }
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.15))
                
                Capsule()
                    .fill(goal.goalStatus == .finished ? Color.green : energy.color)
                    .frame(width: geometry.size.width * min(max(goal.progress, 0), 1))
            }
        }
        .frame(height: 7)
    }
    
    private var activateButton: some View {
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
    
    private var cardBackground: Color {
        switch goal.goalStatus {
        case .active:
            return Color.white.opacity(0.82)
        case .inactive:
            return Color.gray.opacity(0.12)
        case .finished:
            return Color.white.opacity(0.82)
        }
    }
    
    private var cardStroke: Color {
        switch goal.goalStatus {
        case .active:
            return Color.black.opacity(0.12)
        case .inactive:
            return Color.gray.opacity(0.25)
        case .finished:
            return Color.green.opacity(0.28)
        }
    }
    
    private func toggleToday() {
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
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Failed to update goal:", error.localizedDescription)
        }
    }
    
    private func activateAgain() {
        goal.restartGoal()
        
        do {
            try modelContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Failed to activate goal:", error.localizedDescription)
        }
    }
}

#Preview {
    MyGoalsView()
        .modelContainer(
            for: [
                Goal.self,
                AchievementBadge.self
            ],
            inMemory: true
        )
}
