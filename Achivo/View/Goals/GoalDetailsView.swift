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
    
    let goal: Goal
    
    private var energy: GrowthEnergy {
        goal.selectedEnergy
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
                    boostButton
                    goalInfoCard
                }
                .padding(.horizontal, 22)
                .padding(.top, 20)
                .padding(.bottom, 140)
            }
        }
        .navigationTitle("Goal Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(colorScheme, for: .navigationBar)
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
                Text(goal.subGoal)
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
            Image(systemName: goal.isFinished ? "checkmark.seal.fill" : "sparkles")
                .font(.caption)
            
            Text(goal.isFinished ? "Goal completed" : "Keep going")
                .font(.caption)
                .fontWeight(.bold)
        }
        .foregroundStyle(goal.isFinished ? .green : energy.color)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill((goal.isFinished ? Color.green : energy.color).opacity(colorScheme == .dark ? 0.22 : 0.13))
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
                    Text(goal.isFinished ? "Goal Completed" : "Boost +1 Day")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(goal.isFinished ? "You finished this journey" : "Use it when you did extra today")
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
        .disabled(goal.isFinished)
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
                title: "Daily task",
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
    
    func boostOneDay() {
        guard !goal.isFinished else { return }
        
        goal.completedDays = min(goal.completedDays + 1, goal.durationDays)
        
        let today = Calendar.current.startOfDay(for: Date())
        
        let alreadyAdded = goal.completedDates.contains { date in
            Calendar.current.isDate(date, inSameDayAs: today)
        }
        
        if !alreadyAdded {
            goal.completedDates.append(today)
        }
        
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
            WidgetCenter.shared.reloadAllTimelines()
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
