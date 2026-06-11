//
//  AchivoWidget.swift
//  AchivoWidget
//
//  Created by Deemah Alhazmi on 11/05/2026.
//

import WidgetKit
import SwiftUI

// MARK: - Provider

struct AchivoWidgetProvider: AppIntentTimelineProvider {
    
    func placeholder(in context: Context) -> AchivoWidgetEntry {
        AchivoWidgetEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            energy: .sunny,
            message: EnergyNotificationContent(
                title: "Let’s do one tiny step!",
                body: "Starting is already progress."
            ),
            goals: [
                WidgetGoalProgress(
                    id: UUID().uuidString,
                    title: "Read a book",
                    completedDays: 3,
                    durationDays: 10,
                    energyRawValue: GrowthEnergy.sunny.rawValue,
                    tasks: [
                        WidgetTaskProgress(
                            id: UUID().uuidString,
                            title: "Read 5 pages",
                            isCompleted: true
                        ),
                        WidgetTaskProgress(
                            id: UUID().uuidString,
                            title: "Write notes",
                            isCompleted: false
                        ),
                        WidgetTaskProgress(
                            id: UUID().uuidString,
                            title: "Finish chapter",
                            isCompleted: false
                        )
                    ]
                )
            ]
        )
    }
    
    func snapshot(
        for configuration: ConfigurationAppIntent,
        in context: Context
    ) async -> AchivoWidgetEntry {
        makeEntry(configuration: configuration)
    }
    
    func timeline(
        for configuration: ConfigurationAppIntent,
        in context: Context
    ) async -> Timeline<AchivoWidgetEntry> {
        
        let entry = makeEntry(configuration: configuration)
        
        let nextUpdate = Calendar.current.date(
            byAdding: .hour,
            value: 1,
            to: Date()
        ) ?? Date()
        
        return Timeline(
            entries: [entry],
            policy: .after(nextUpdate)
        )
    }
    
    private func makeEntry(
        configuration: ConfigurationAppIntent
    ) -> AchivoWidgetEntry {
        
        let energy = GrowthEnergy(
            rawValue: configuration.growthEnergy
        ) ?? .sunny
        
        let message = energy.notificationMessages.randomElement()
        ?? EnergyNotificationContent(
            title: "Keep growing",
            body: "One small step is enough today."
        )
        
        let goals = loadGoalsProgress()
        
        return AchivoWidgetEntry(
            date: Date(),
            configuration: configuration,
            energy: energy,
            message: message,
            goals: goals
        )
    }
    
    private func loadGoalsProgress() -> [WidgetGoalProgress] {
        let defaults = UserDefaults(suiteName: "group.com.Achivo.widget")
        
        guard let data = defaults?.data(forKey: "widgetGoalsProgress") else {
            return []
        }
        
        do {
            let goals = try JSONDecoder().decode([WidgetGoalProgress].self, from: data)
            
            // Hide completed goals from the widget
            let activeGoals = goals.filter { goal in
                goal.progress < 1.0
            }
            
            return activeGoals
            
        } catch {
            print("Widget decode error:", error.localizedDescription)
            return []
        }
    }
}

// MARK: - Entry

struct AchivoWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let energy: GrowthEnergy
    let message: EnergyNotificationContent
    let goals: [WidgetGoalProgress]
}

// MARK: - Widget View

struct AchivoWidgetEntryView: View {
    let entry: AchivoWidgetEntry
    
    @Environment(\.widgetFamily) private var widgetFamily
    
    var body: some View {
        Group {
            if entry.goals.isEmpty {
                emptyWidgetView
            } else {
                switch widgetFamily {
                case .systemSmall:
                    if let firstGoal = entry.goals.first {
                        smallGoalView(firstGoal)
                    }
                    
                case .systemMedium:
                    goalsListView(limit: 2, showTitle: true)
                    
                case .systemLarge:
                    goalsListView(limit: 4, showTitle: true)
                    
                default:
                    goalsListView(limit: 2, showTitle: true)
                }
            }
        }
    }
    
    // MARK: - Small Widget
    
    private func smallGoalView(_ goal: WidgetGoalProgress) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack(spacing: 8) {
                Circle()
                    .fill(goal.energy.color)
                    .frame(width: 10, height: 10)
                
                Text(goal.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 0)
            
            Text("\(goal.progressPercent)%")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(goal.energy.color)
                .monospacedDigit()
            
            progressBar(
                progress: goal.progress,
                color: goal.energy.color,
                height: 8
            )
            
            Text(progressLabel(for: goal))
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(goal.energy.color)
                .lineLimit(1)
        }
        .padding()
        .containerBackground(for: .widget) {
            goal.energy.color.opacity(0.12)
        }
    }
    
    // MARK: - Medium / Large Widget
    
    private func goalsListView(limit: Int, showTitle: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            
            if showTitle {
                HStack {
                    Text("Achivo")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("\(entry.goals.count) goals")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            VStack(spacing: 8) {
                ForEach(entry.goals.prefix(limit)) { goal in
                    compactGoalRow(goal)
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(14)
        .containerBackground(for: .widget) {
            Color.green.opacity(0.10)
        }
    }
    
    private func compactGoalRow(_ goal: WidgetGoalProgress) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            
            HStack(spacing: 8) {
                Circle()
                    .fill(goal.energy.color)
                    .frame(width: 10, height: 10)
                
                Text(goal.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                Spacer()
                
                Text("\(goal.progressPercent)%")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(goal.energy.color)
                    .monospacedDigit()
            }
            
            HStack {
                Text(countText(for: goal))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .monospacedDigit()
                
                Spacer()
                
                Text(progressLabel(for: goal))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(goal.energy.color)
                    .lineLimit(1)
            }
            
            progressBar(
                progress: goal.progress,
                color: goal.energy.color,
                height: 8
            )
        }
    }
    
    // MARK: - Empty Widget
    
    private var emptyWidgetView: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Image(entry.energy.assetName)
                .resizable()
                .scaledToFit()
                .frame(width: 54, height: 54)
            
            Text("No active goals")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("Completed goals are hidden from the widget.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding()
        .containerBackground(for: .widget) {
            entry.energy.color.opacity(0.12)
        }
    }
    
    // MARK: - Helpers
    
    private func countText(for goal: WidgetGoalProgress) -> String {
        let totalTasks = goal.tasks.count
        let completedTasks = goal.tasks.filter { $0.isCompleted }.count
        
        if totalTasks > 0 {
            return "\(completedTasks) / \(totalTasks) tasks"
        } else {
            return "\(goal.completedDays) / \(goal.durationDays) days"
        }
    }
    
    private func progressLabel(for goal: WidgetGoalProgress) -> String {
        if goal.progress >= 1 {
            return "Completed"
        } else if goal.progress >= 0.75 {
            return "Almost there"
        } else if goal.progress >= 0.35 {
            return "In progress"
        } else {
            return "Getting started"
        }
    }
    
    private func progressBar(
        progress: Double,
        color: Color,
        height: CGFloat
    ) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.black.opacity(0.08))
                
                Capsule()
                    .fill(color)
                    .frame(
                        width: max(
                            geometry.size.width * min(max(progress, 0), 1),
                            6
                        )
                    )
            }
        }
        .frame(height: height)
    }
}

// MARK: - Widget

struct AchivoWidget: Widget {
    let kind: String = "AchivoWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: AchivoWidgetProvider()
        ) { entry in
            AchivoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Goal Progress")
        .description("See your goal progress and tasks.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge
        ])
    }
}

// MARK: - Preview

#Preview(as: .systemMedium) {
    AchivoWidget()
} timeline: {
    AchivoWidgetEntry(
        date: .now,
        configuration: .sunny,
        energy: .sunny,
        message: EnergyNotificationContent(
            title: "Let’s do one tiny step!",
            body: "Starting is already progress."
        ),
        goals: [
            WidgetGoalProgress(
                id: UUID().uuidString,
                title: "Loose 10 kg",
                completedDays: 6,
                durationDays: 90,
                energyRawValue: GrowthEnergy.sunny.rawValue,
                tasks: []
            ),
            WidgetGoalProgress(
                id: UUID().uuidString,
                title: "Watch friends",
                completedDays: 2,
                durationDays: 3,
                energyRawValue: GrowthEnergy.bluey.rawValue,
                tasks: []
            ),
            WidgetGoalProgress(
                id: UUID().uuidString,
                title: "Read a book",
                completedDays: 1,
                durationDays: 7,
                energyRawValue: GrowthEnergy.sunny.rawValue,
                tasks: []
            )
        ]
    )
}
