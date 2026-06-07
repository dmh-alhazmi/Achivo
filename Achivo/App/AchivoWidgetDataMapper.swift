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

        let widgetGoals = goals.map { goal in
            WidgetGoalProgress(
                id: goal.idForWidget,
                title: goal.title,
                completedDays: goal.completedDays,
                durationDays: goal.durationDays,
                energyRawValue: goal.selectedEnergyRawValue,
                tasks: []
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