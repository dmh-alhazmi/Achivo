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
    
    init(
        title: String,
        subGoal: String,
        durationDays: Int,
        selectedEnergy: GrowthEnergy,
        createdAt: Date = Date(),
        completedDays: Int = 0,
        isCompletedToday: Bool = false
    ) {
        self.title = title
        self.subGoal = subGoal
        self.durationDays = durationDays
        self.selectedEnergyRawValue = selectedEnergy.rawValue
        self.createdAt = createdAt
        self.completedDays = completedDays
        self.isCompletedToday = isCompletedToday
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
}
