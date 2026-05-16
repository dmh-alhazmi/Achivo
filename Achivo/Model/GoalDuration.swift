//
//  GoalDuration.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 14/05/2026.
//


import Foundation

enum GoalDuration: String, CaseIterable, Identifiable, Codable {
    case threeDays
    case oneWeek
    case twoWeeks
    case oneMonth
    case custom
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .threeDays:
            return "3 Days"
        case .oneWeek:
            return "1 Week"
        case .twoWeeks:
            return "2 Weeks"
        case .oneMonth:
            return "1 Month"
        case .custom:
            return "Custom"
        }
    }
    
    var days: Int {
        switch self {
        case .threeDays:
            return 3
        case .oneWeek:
            return 7
        case .twoWeeks:
            return 14
        case .oneMonth:
            return 30
        case .custom:
            return 7
        }
    }
}
