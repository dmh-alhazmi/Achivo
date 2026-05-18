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
                updateWidgetGoalsProgress()
            }
            .onChange(of: widgetRefreshToken) {
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
                ForEach(goals) { goal in
                    NavigationLink {
                        GoalDetailsView(goal: goal)
                    } label: {
                        GoalCardView(goal: goal)
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
    
    var widgetRefreshToken: String {
        goals.map { goal in
            "\(String(describing: goal.persistentModelID))-\(goal.subGoal)-\(goal.completedDays)-\(goal.durationDays)-\(goal.selectedEnergy.rawValue)"
        }
        .joined(separator: "|")
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

// MARK: - Goal Card

private struct GoalCardView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    let goal: Goal
    
    private var energy: GrowthEnergy {
        goal.selectedEnergy
    }
    
    var body: some View {
        HStack(spacing: 14) {
            checkButton
            
            VStack(alignment: .leading, spacing: 10) {
                topRow
                metaRow
                progressBar
                progressText
            }
            
            Spacer()
            
            Image(energy.assetName)
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.12), lineWidth: 1)
        )
    }
    
    private var checkButton: some View {
        Button {
            toggleToday()
        } label: {
            Image(systemName: goal.isCompletedToday ? "checkmark.square.fill" : "square")
                .font(.title3)
                .foregroundStyle(goal.isCompletedToday ? energy.color : .black)
        }
        .buttonStyle(.plain)
    }
    
    private var topRow: some View {
        HStack {
            Text(goal.subGoal)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.black)
                .lineLimit(1)
            
            Spacer()
            
            Image(systemName: "ellipsis")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var metaRow: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock")
                .font(.caption2)
            
            Text("Every day")
                .font(.caption)
            
            Text("07:00 PM")
                .font(.caption)
        }
        .foregroundStyle(.secondary)
    }
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.15))
                
                Capsule()
                    .fill(energy.color)
                    .frame(width: geometry.size.width * min(max(goal.progress, 0), 1))
            }
        }
        .frame(height: 7)
    }
    
    private var progressText: some View {
        Text("\(goal.completedDays) / \(goal.durationDays) Days")
            .font(.caption2)
            .foregroundStyle(energy.color)
    }
    private func toggleToday() {
            let today = Calendar.current.startOfDay(for: Date())
            
            if goal.isCompletedToday {
                goal.isCompletedToday = false
                goal.completedDays = max(goal.completedDays - 1, 0)
                
                goal.completedDates.removeAll { date in
                    Calendar.current.isDate(date, inSameDayAs: today)
                }
            } else {
                goal.isCompletedToday = true
                goal.completedDays = min(goal.completedDays + 1, goal.durationDays)
                
                let alreadyAdded = goal.completedDates.contains { date in
                    Calendar.current.isDate(date, inSameDayAs: today)
                }
                
                if !alreadyAdded {
                    goal.completedDates.append(today)
                }
            }
            
            do {
                try modelContext.save()
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                print("Failed to update goal:", error.localizedDescription)
            }
        }
//    private func toggleToday() {
//        if goal.isCompletedToday {
//            goal.isCompletedToday = false
//            goal.completedDays = max(goal.completedDays - 1, 0)
//        } else {
//            goal.isCompletedToday = true
//            goal.completedDays = min(goal.completedDays + 1, goal.durationDays)
//        }
//        
//        do {
//            try modelContext.save()
//            WidgetCenter.shared.reloadAllTimelines()
//        } catch {
//            print("Failed to update goal:", error.localizedDescription)
//        }
//    }
}

#Preview {
    MyGoalsView()
        .modelContainer(for: Goal.self, inMemory: true)
}
