//
//  Goal.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 03/05/2026.
//

import Foundation
import SwiftData

@Model
final class Goal {
    var completedDates: [Date] = []
    var title: String
    var subGoal: String
    var durationDays: Int
    var selectedEnergyRawValue: String
    var createdAt: Date
    var completedDays: Int
    var isCompletedToday: Bool
    var isActive: Bool
    
    init(
        title: String,
        subGoal: String,
        durationDays: Int,
        selectedEnergy: GrowthEnergy,
        createdAt: Date = Date(),
        completedDays: Int = 0,
        isCompletedToday: Bool = false,
        isActive: Bool = true
    ) {
        self.title = title
        self.subGoal = subGoal
        self.durationDays = durationDays
        self.selectedEnergyRawValue = selectedEnergy.rawValue
        self.createdAt = createdAt
        self.completedDays = completedDays
        self.isCompletedToday = isCompletedToday
        self.isActive = isActive
    }
    
    var selectedEnergy: GrowthEnergy {
        GrowthEnergy(rawValue: selectedEnergyRawValue) ?? .sunny
    }
    
    var progress: Double {
        guard durationDays > 0 else { return 0 }
        return min(Double(completedDays) / Double(durationDays), 1)
    }
    
    var remainingDays: Int {
        max(durationDays - completedDays, 0)
    }
    
    var isFinished: Bool {
        completedDays >= durationDays
    }
    
    var endDate: Date {
        Calendar.current.date(
            byAdding: .day,
            value: durationDays,
            to: createdAt
        ) ?? createdAt
    }
    
    var isExpired: Bool {
        Date() > endDate && !isFinished
    }
    
    var isDoneToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        
        return completedDates.contains { date in
            Calendar.current.isDate(date, inSameDayAs: today)
        }
    }
    
    var goalStatus: GoalStatus {
        if isFinished {
            return .finished
        } else if !isActive || isExpired {
            return .inactive
        } else {
            return .active
        }
    }
    
    func checkToday() {
        let today = Calendar.current.startOfDay(for: Date())
        
        guard isActive else { return }
        guard !isFinished else { return }
        guard !isDoneToday else { return }
        
        completedDates.append(today)
        completedDays = min(completedDays + 1, durationDays)
        isCompletedToday = true
    }
    
    func uncheckToday() {
        let today = Calendar.current.startOfDay(for: Date())
        
        completedDates.removeAll { date in
            Calendar.current.isDate(date, inSameDayAs: today)
        }
        
        completedDays = max(completedDays - 1, 0)
        isCompletedToday = false
    }
    
    func deactivateIfNeeded() {
        if isExpired && !isFinished {
            isActive = false
            isCompletedToday = false
        }
    }
    
    func restartGoal() {
        createdAt = Date()
        completedDays = 0
        completedDates = []
        isCompletedToday = false
        isActive = true
    }
}

enum GoalStatus {
    case active
    case inactive
    case finished
}
