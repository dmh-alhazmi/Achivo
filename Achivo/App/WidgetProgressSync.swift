////
////  WidgetProgressSync.swift
////  Achivo
////
////  Created by Deemah Alhazmi on 18/05/2026.
////
//
//import Foundation
//import WidgetKit
//
//struct WidgetGoalProgressData: Codable {
//    let id: String
//    let title: String
//    let completedDays: Int
//    let durationDays: Int
//    let energyRawValue: String
//}
//
//enum WidgetProgressSync {
//    
//    static let appGroupID = "group.com.Achivo.widget"
//    static let storageKey = "widgetGoalsProgress"
//    static let widgetKind = "AchivoWidget"
//    
//    static func saveGoalsForWidget(_ goals: [Goal]) {
//        
//        let widgetGoals = goals.map { goal in
//            WidgetGoalProgressData(
//                id: "\(goal.title)-\(goal.createdAt.timeIntervalSince1970)",
//                title: goal.title,
//                completedDays: goal.completedDays,
//                durationDays: goal.durationDays,
//                energyRawValue: goal.selectedEnergyRawValue
//            )
//        }
//        
//        do {
//            let data = try JSONEncoder().encode(widgetGoals)
//            
//            let defaults = UserDefaults(suiteName: appGroupID)
//            defaults?.set(data, forKey: storageKey)
//            
//            WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
//            
//        } catch {
//            print("Widget sync error:", error.localizedDescription)
//        }
//    }
//}
