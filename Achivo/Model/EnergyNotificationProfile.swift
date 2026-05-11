//
//  EnergyNotificationProfile.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 11/05/2026.
//


import Foundation

struct EnergyNotificationProfile {
    let dailyCount: Int
    let hours: [Int]
    let toneDescription: String
}

extension GrowthEnergy {
    
    var notificationProfile: EnergyNotificationProfile {
        switch self {
        case .bluey:
            return EnergyNotificationProfile(
                dailyCount: 2,
                hours: [11, 20],
                toneDescription: "Gentle, calm, no pressure"
            )
            
        case .greeny:
            return EnergyNotificationProfile(
                dailyCount: 3,
                hours: [9, 14, 19],
                toneDescription: "Consistent, routine-based, steady"
            )
            
        case .sunny:
            return EnergyNotificationProfile(
                dailyCount: 4,
                hours: [8, 12, 16, 19],
                toneDescription: "Positive, cheerful, motivating"
            )
            
        case .fiery:
            return EnergyNotificationProfile(
                dailyCount: 5,
                hours: [7, 10, 13, 16, 21],
                toneDescription: "Focused, powerful, achievement-driven"
            )
        }
    }
}
