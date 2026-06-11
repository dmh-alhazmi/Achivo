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
        completedDays
    }
    
    var totalTaskCount: Int {
        max(durationDays, 0)
    }
    
    var todayCompletedTaskCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var todayTotalTaskCount: Int {
        tasks.count
    }
    
    var progress: Double {
        guard durationDays > 0 else { return 0 }
        
        let safeCompleted = min(max(completedDays, 0), durationDays)
        return Double(safeCompleted) / Double(durationDays)
    }
    
    var progressPercent: Int {
        min(max(Int((progress * 100).rounded()), 0), 100)
    }
    
    var progressText: String {
        "\(completedDays) / \(durationDays)"
    }
    
    var progressStatusText: String {
        if progress >= 1 {
            return "Completed"
        } else if progress >= 0.75 {
            return "Almost there"
        } else if progress >= 0.35 {
            return "In progress"
        } else {
            return "Getting started"
        }
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
    
    var safeCompletedTasks: Int {
        min(max(completedTasks, 0), max(totalTasks, 0))
    }
    
    var safeTotalTasks: Int {
        max(totalTasks, 0)
    }
}

// MARK: - Home Screen Widget Sync

enum AchivoWidgetSync {
    
    static let appGroupID = "group.com.Achivo.widget"
    static let goalsKey = "widgetGoalsProgress"
    
    static func saveGoalsForWidget(_ goals: [WidgetGoalProgress]) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            print("Widget sync error: App Group UserDefaults not found.")
            return
        }
        
        do {
            let data = try JSONEncoder().encode(goals)
            defaults.set(data, forKey: goalsKey)
            defaults.synchronize()
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
            progressPercent: min(max(progressPercent, 0), 100),
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
            progressPercent: min(max(progressPercent, 0), 100),
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
