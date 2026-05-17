//
//  AchivoWidget.swift
//  AchivoWidget
//
//  Created by Deemah Alhazmi on 11/05/2026.
//

import WidgetKit
import SwiftUI

struct WidgetGoalProgress: Codable, Identifiable {
    let id: String
    let title: String
    let completedDays: Int
    let durationDays: Int
    let energyRawValue: String
    
    var progress: Double {
        guard durationDays > 0 else { return 0 }
        return Double(completedDays) / Double(durationDays)
    }
    
    var progressPercent: Int {
        Int(progress * 100)
    }
    
    var energy: GrowthEnergy {
        GrowthEnergy(rawValue: energyRawValue) ?? .sunny
    }
}

struct AchivoWidgetProvider: AppIntentTimelineProvider {
    
    func placeholder(in context: Context) -> AchivoWidgetEntry {
        AchivoWidgetEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            energy: .sunny,
            message: .init(
                title: "Let’s do one tiny step!",
                body: "Starting is already progress."
            ),
            goals: [
                WidgetGoalProgress(
                    id: UUID().uuidString,
                    title: "Read a book",
                    completedDays: 3,
                    durationDays: 10,
                    energyRawValue: GrowthEnergy.sunny.rawValue
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
            value: 3,
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
            return []
        }
    }
}

struct AchivoWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let energy: GrowthEnergy
    let message: EnergyNotificationContent
    let goals: [WidgetGoalProgress]
}

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
            
            HStack {
                Image(goal.energy.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 52)
                
                Spacer()
                
                Text("\(goal.progressPercent)%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(goal.energy.color)
            }
            
            Text(goal.title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .lineLimit(1)
            
            progressBar(
                progress: goal.progress,
                color: goal.energy.color
            )
            
            Text("\(goal.completedDays) / \(goal.durationDays) days")
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            Text(entry.message.title)
                .font(.caption)
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
            
            Text("Your Goals")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("Keep growing step by step")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                ForEach(entry.goals.prefix(4)) { goal in
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
                
                Text("\(goal.progressPercent)%")
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
                    .frame(width: geometry.size.width * min(max(progress, 0), 1))
            }
        }
        .frame(height: 7)
    }
}

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
        .description("See your goal progress with your growth energy.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium
        ])
    }
}

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
                energyRawValue: GrowthEnergy.sunny.rawValue
            )
        ]
    )
}
