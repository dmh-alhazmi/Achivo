//
//  AchivoWidgetDataMapper.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 07/06/2026.
//


import Foundation
import WidgetKit

enum AchivoWidgetDataMapper {
    
    static func syncGoals(_ goals: [Goal]) {
        let activeGoals = goals.filter { !$0.isFinished }
        
        let widgetGoals = activeGoals.map { goal in
            WidgetGoalProgress(
                id: goal.idForWidget,
                title: goal.title,
                completedDays: goal.completedDays,
                durationDays: goal.durationDays,
                energyRawValue: goal.selectedEnergyRawValue,
                tasks: [
                    WidgetTaskProgress(
                        id: "\(goal.idForWidget)-daily",
                        title: goal.subGoal,
                        isCompleted: goal.isCompletedToday
                    )
                ]
            )
        }
        
        AchivoWidgetSync.saveGoalsForWidget(widgetGoals)
    }
}

extension Goal {
    var idForWidget: String {
        "\(title)-\(createdAt.timeIntervalSince1970)"
    }
}
