//
//  AchivoWidget.swift
//  AchivoWidget
//
//  Created by Deemah Alhazmi on 11/05/2026.
//

import WidgetKit
import SwiftUI

struct AchivoWidgetProvider: AppIntentTimelineProvider {
    
    func placeholder(in context: Context) -> AchivoWidgetEntry {
        AchivoWidgetEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            energy: .sunny,
            message: .init(
                title: "Let’s do one tiny step!",
                body: "Starting is already progress."
            )
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
        
        return AchivoWidgetEntry(
            date: Date(),
            configuration: configuration,
            energy: energy,
            message: message
        )
    }
}

struct AchivoWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let energy: GrowthEnergy
    let message: EnergyNotificationContent
}

struct AchivoWidgetEntryView: View {
    let entry: AchivoWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack {
                Image(entry.energy.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 54, height: 54)
                
                Spacer()
            }
            
            Text(entry.energy.name)
                .font(.headline)
                .foregroundStyle(entry.energy.color)
            
            Text(entry.message.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            Text(entry.message.body)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding()
        .containerBackground(for: .widget) {
            entry.energy.color.opacity(0.12)
        }
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
        .configurationDisplayName("Growth Energy")
        .description("See a daily message from your selected growth character.")
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
        )
    )
}
