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
            return try JSONDecoder().decode([WidgetGoalProgress].self, from: data)
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
    
    var body: some View {
        if entry.goals.count == 1, let goal = entry.goals.first {
            singleGoalView(goal)
        } else if entry.goals.count > 1 {
            multipleGoalsView
        } else {
            emptyWidgetView
        }
    }
    
    // MARK: - One Goal Widget
    
    private func singleGoalView(_ goal: WidgetGoalProgress) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(goal.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    Text("\(goal.completedTaskCount) of \(goal.tasks.count) tasks")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(goal.energy.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 42, height: 42)
            }
            
            HStack(spacing: 8) {
                progressBar(
                    progress: goal.progress,
                    color: goal.energy.color
                )
                
                Text("\(goal.progressPercent)%")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(goal.energy.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(goal.tasks.prefix(3)) { task in
                    taskRow(task)
                }
            }
            
            Spacer(minLength: 0)
            
            Text(entry.message.title)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding()
        .containerBackground(for: .widget) {
            goal.energy.color.opacity(0.12)
        }
    }
    
    // MARK: - Multiple Goals Widget
    
    private var multipleGoalsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Your Goals")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("Progress & tasks")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: 7) {
                ForEach(entry.goals.prefix(3)) { goal in
                    goalProgressRow(goal)
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding()
        .containerBackground(for: .widget) {
            Color.green.opacity(0.10)
        }
    }
    
    private func goalProgressRow(_ goal: WidgetGoalProgress) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            
            HStack(spacing: 6) {
                Circle()
                    .fill(goal.energy.color)
                    .frame(width: 8, height: 8)
                
                Text(goal.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Spacer()
                
                Text("\(goal.completedTaskCount)/\(goal.tasks.count)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(goal.energy.color)
            }
            
            progressBar(
                progress: goal.progress,
                color: goal.energy.color
            )
        }
    }
    
    // MARK: - Task Row
    
    private func taskRow(_ task: WidgetTaskProgress) -> some View {
        HStack(spacing: 6) {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.caption2)
                .foregroundStyle(task.isCompleted ? .green : .secondary)
            
            Text(task.title)
                .font(.caption2)
                .foregroundStyle(task.isCompleted ? .secondary : .primary)
                .lineLimit(1)
        }
    }
    
    // MARK: - Empty Widget
    
    private var emptyWidgetView: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Image(entry.energy.assetName)
                .resizable()
                .scaledToFit()
                .frame(width: 54, height: 54)
            
            Text("No goals yet")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("Start with one small goal today.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .containerBackground(for: .widget) {
            entry.energy.color.opacity(0.12)
        }
    }
    
    // MARK: - Progress Bar
    
    private func progressBar(progress: Double, color: Color) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                
                Capsule()
                    .fill(color)
                    .frame(
                        width: geometry.size.width * min(max(progress, 0), 1)
                    )
            }
        }
        .frame(height: 7)
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
            .systemMedium
        ])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
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
