//
//  GoalViewModel.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 03/05/2026.
//

import Foundation
import SwiftData
import Observation

@Observable
final class GoalViewModel {
    
    var goalTitle: String = ""
    var subGoal: String = ""
    var selectedDuration: GoalDuration = .oneWeek
    var selectedEnergy: GrowthEnergy = .bluey
    
    var canCreateGoal: Bool {
        !goalTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !subGoal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func createGoal(context: ModelContext) {
        let newGoal = Goal(
            title: goalTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            subGoal: subGoal.trimmingCharacters(in: .whitespacesAndNewlines),
            durationDays: selectedDuration.days,
            selectedEnergy: selectedEnergy
        )
        
        context.insert(newGoal)
        
        do {
            try context.save()
            resetForm()
        } catch {
            print("Failed to save goal:", error.localizedDescription)
        }
    }
    
    private func resetForm() {
        goalTitle = ""
        subGoal = ""
        selectedDuration = .oneWeek
        selectedEnergy = .bluey
    }
}
