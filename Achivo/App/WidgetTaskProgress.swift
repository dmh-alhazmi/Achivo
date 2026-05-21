//
//  WidgetTaskProgress.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 20/05/2026.
//

import Foundation
import WidgetKit
import ActivityKit

// MARK: - Home Screen Widget Models

struct WidgetTaskProgress: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let isCompleted: Bool
}

struct WidgetGoalProgress: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let completedDays: Int
    let durationDays: Int
    let energyRawValue: String
    let tasks: [WidgetTaskProgress]
}

// MARK: - Goal Helpers

extension WidgetGoalProgress {
    
    var completedTaskCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var progress: Double {
        if !tasks.isEmpty {
            return Double(completedTaskCount) / Double(tasks.count)
        }
        
        guard durationDays > 0 else { return 0 }
        return Double(completedDays) / Double(durationDays)
    }
    
    var progressPercent: Int {
        min(max(Int(progress * 100), 0), 100)
    }
    
    var energy: GrowthEnergy {
        GrowthEnergy(rawValue: energyRawValue) ?? .sunny
    }
}

// MARK: - Live Activity Attributes

struct AchivoWidgetAttributes: ActivityAttributes {
    
    public struct ContentState: Codable, Hashable {
        var goalTitle: String
        var progressPercent: Int
        var completedTasks: Int
        var totalTasks: Int
        var energyRawValue: String
    }
    
    var name: String
}

// MARK: - Live Activity Helpers

extension AchivoWidgetAttributes.ContentState {
    
    var energy: GrowthEnergy {
        GrowthEnergy(rawValue: energyRawValue) ?? .sunny
    }
    
    var safeProgress: Int {
        min(max(progressPercent, 0), 100)
    }
}

// MARK: - Home Screen Widget Sync

enum AchivoWidgetSync {
    
    static let appGroupID = "group.com.Achivo.widget"
    static let goalsKey = "widgetGoalsProgress"
    
    static func saveGoalsForWidget(_ goals: [WidgetGoalProgress]) {
        let defaults = UserDefaults(suiteName: appGroupID)
        
        do {
            let data = try JSONEncoder().encode(goals)
            defaults?.set(data, forKey: goalsKey)
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Widget sync error:", error.localizedDescription)
        }
    }
}

// MARK: - Dynamic Island / Live Activity Manager

enum AchivoLiveActivityManager {
    
    static func startGoalLiveActivity(
        goalTitle: String,
        progressPercent: Int,
        completedTasks: Int,
        totalTasks: Int,
        energy: GrowthEnergy
    ) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled.")
            return
        }
        
        let attributes = AchivoWidgetAttributes(
            name: "Achivo Progress"
        )
        
        let state = AchivoWidgetAttributes.ContentState(
            goalTitle: goalTitle,
            progressPercent: progressPercent,
            completedTasks: completedTasks,
            totalTasks: totalTasks,
            energyRawValue: energy.rawValue
        )
        
        do {
            _ = try Activity.request(
                attributes: attributes,
                content: ActivityContent(
                    state: state,
                    staleDate: nil
                ),
                pushType: nil
            )
        } catch {
            print("Failed to start Live Activity:", error.localizedDescription)
        }
    }
    
    static func updateGoalLiveActivity(
        goalTitle: String,
        progressPercent: Int,
        completedTasks: Int,
        totalTasks: Int,
        energy: GrowthEnergy
    ) async {
        
        let newState = AchivoWidgetAttributes.ContentState(
            goalTitle: goalTitle,
            progressPercent: progressPercent,
            completedTasks: completedTasks,
            totalTasks: totalTasks,
            energyRawValue: energy.rawValue
        )
        
        for activity in Activity<AchivoWidgetAttributes>.activities {
            await activity.update(
                ActivityContent(
                    state: newState,
                    staleDate: nil
                )
            )
        }
    }
    
    static func endGoalLiveActivity() async {
        for activity in Activity<AchivoWidgetAttributes>.activities {
            await activity.end(
                ActivityContent(
                    state: activity.content.state,
                    staleDate: nil
                ),
                dismissalPolicy: .immediate
            )
        }
    }
}
