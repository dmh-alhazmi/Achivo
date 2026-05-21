//
//  AchivoWidgetLiveActivity.swift
//  AchivoWidget
//
//  Created by Deemah Alhazmi on 11/05/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Widget

struct AchivoWidgetLiveActivity: Widget {
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AchivoWidgetAttributes.self) { context in
            
            HStack(spacing: 12) {
                
                Image(context.state.energy.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 54, height: 54)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(context.state.goalTitle)
                        .font(.headline)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    
                    Text("\(context.state.completedTasks) of \(context.state.totalTasks) tasks completed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    progressBar(
                        progress: Double(context.state.safeProgress) / 100,
                        color: context.state.energy.color
                    )
                }
                
                Spacer()
                
                Text("\(context.state.safeProgress)%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(context.state.energy.color)
            }
            .padding()
            .activityBackgroundTint(context.state.energy.color.opacity(0.15))
            .activitySystemActionForegroundColor(context.state.energy.color)
            
        } dynamicIsland: { context in
            
            DynamicIsland {
                
                DynamicIslandExpandedRegion(.leading) {
                    Image(context.state.energy.assetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.safeProgress)%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(context.state.energy.color)
                }
                
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 3) {
                        Text(context.state.goalTitle)
                            .font(.headline)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        
                        Text("\(context.state.completedTasks) / \(context.state.totalTasks) tasks")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    progressBar(
                        progress: Double(context.state.safeProgress) / 100,
                        color: context.state.energy.color
                    )
                    .padding(.horizontal, 4)
                }
                
            } compactLeading: {
                
                Image(context.state.energy.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                
            } compactTrailing: {
                
                Text("\(context.state.safeProgress)%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(context.state.energy.color)
                
            } minimal: {
                
                ZStack {
                    Circle()
                        .stroke(context.state.energy.color.opacity(0.3), lineWidth: 2)
                    
                    Circle()
                        .trim(
                            from: 0,
                            to: Double(context.state.safeProgress) / 100
                        )
                        .stroke(context.state.energy.color, lineWidth: 2)
                        .rotationEffect(.degrees(-90))
                    
                    Image(context.state.energy.assetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }
                .frame(width: 24, height: 24)
            }
            .keylineTint(context.state.energy.color)
        }
    }
    
    // MARK: - Progress Bar
    
    private func progressBar(progress: Double, color: Color) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.25))
                
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

// MARK: - Preview

extension AchivoWidgetAttributes {
    
    fileprivate static var preview: AchivoWidgetAttributes {
        AchivoWidgetAttributes(name: "Achivo Progress")
    }
}

extension AchivoWidgetAttributes.ContentState {
    
    fileprivate static var sunnyProgress: AchivoWidgetAttributes.ContentState {
        AchivoWidgetAttributes.ContentState(
            goalTitle: "Read a book",
            progressPercent: 65,
            completedTasks: 2,
            totalTasks: 3,
            energyRawValue: GrowthEnergy.sunny.rawValue
        )
    }
    
    fileprivate static var fieryProgress: AchivoWidgetAttributes.ContentState {
        AchivoWidgetAttributes.ContentState(
            goalTitle: "Learn Swift",
            progressPercent: 30,
            completedTasks: 1,
            totalTasks: 4,
            energyRawValue: GrowthEnergy.fiery.rawValue
        )
    }
}

#Preview("Notification", as: .content, using: AchivoWidgetAttributes.preview) {
    AchivoWidgetLiveActivity()
} contentStates: {
    AchivoWidgetAttributes.ContentState.sunnyProgress
    AchivoWidgetAttributes.ContentState.fieryProgress
}
