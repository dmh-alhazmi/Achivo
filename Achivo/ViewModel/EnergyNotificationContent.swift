//
//  EnergyNotificationContent.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 11/05/2026.
//


import Foundation

struct EnergyNotificationContent: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}
extension GrowthEnergy {
    
    var notificationMessages: [EnergyNotificationContent] {
        switch self {
        case .bluey:
            return [
                EnergyNotificationContent(
                    title: "You don’t have to rush",
                    body: "Take one calm step today."
                ),
                EnergyNotificationContent(
                    title: "Breathe first",
                    body: "Your progress can be gentle too."
                ),
                EnergyNotificationContent(
                    title: "No pressure today",
                    body: "One peaceful step is enough."
                )
            ]
            
        case .greeny:
            return [
                EnergyNotificationContent(
                    title: "Let’s keep the streak alive",
                    body: "Tiny habits create big change."
                ),
                EnergyNotificationContent(
                    title: "Your routine misses you",
                    body: "Even two minutes count today."
                ),
                EnergyNotificationContent(
                    title: "Stay steady",
                    body: "Consistency beats perfection."
                )
            ]
            
        case .sunny:
            return [
                EnergyNotificationContent(
                    title: "Let’s do one tiny step!",
                    body: "Starting is already progress."
                ),
                EnergyNotificationContent(
                    title: "Fresh start energy",
                    body: "Today is a good day to begin again."
                ),
                EnergyNotificationContent(
                    title: "Small win time",
                    body: "Do one simple thing for your future self."
                ),
                EnergyNotificationContent(
                    title: "You got this",
                    body: "Even small wins matter."
                )
            ]
            
        case .fiery:
            return [
                EnergyNotificationContent(
                    title: "Focus mode ON",
                    body: "Pick one goal and move."
                ),
                EnergyNotificationContent(
                    title: "One more push",
                    body: "Big goals need action."
                ),
                EnergyNotificationContent(
                    title: "No excuses today",
                    body: "Your future needs this version of you."
                ),
                EnergyNotificationContent(
                    title: "Lock in",
                    body: "Do the task before the day ends."
                ),
                EnergyNotificationContent(
                    title: "Finish strong",
                    body: "You are closer than you think."
                )
            ]
        }
    }
}
