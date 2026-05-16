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
    var title: String
    var subGoal: String
    var durationDays: Int
    var selectedEnergyRawValue: String
    var createdAt: Date
    var completedDays: Int
    
    init(
        title: String,
        subGoal: String,
        durationDays: Int,
        selectedEnergy: GrowthEnergy,
        createdAt: Date = Date(),
        completedDays: Int = 0
    ) {
        self.title = title
        self.subGoal = subGoal
        self.durationDays = durationDays
        self.selectedEnergyRawValue = selectedEnergy.rawValue
        self.createdAt = createdAt
        self.completedDays = completedDays
    }
    
    var selectedEnergy: GrowthEnergy {
        GrowthEnergy(rawValue: selectedEnergyRawValue) ?? .sunny
    }
    
    var progress: Double {
        guard durationDays > 0 else { return 0 }
        return min(Double(completedDays) / Double(durationDays), 1)
    }
}
