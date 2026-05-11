//
//  GrowthEnergy.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 11/05/2026.
//


import SwiftUI

enum GrowthEnergy: String, CaseIterable, Identifiable, Codable {
    case bluey
    case greeny
    case sunny
    case fiery
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .bluey:
            return "Bluey"
        case .greeny:
            return "Greeny"
        case .sunny:
            return "Sunny"
        case .fiery:
            return "Fiery"
        }
    }
    
    var title: String {
        switch self {
        case .bluey:
            return "The Calm One"
        case .greeny:
            return "The Consistent One"
        case .sunny:
            return "The Motivator"
        case .fiery:
            return "The Achiever"
        }
    }
    
    var description: String {
        switch self {
        case .bluey:
            return "Soft reminders that help you grow gently without pressure."
        case .greeny:
            return "Steady reminders that help you build habits and stay consistent."
        case .sunny:
            return "Positive reminders that help you start, continue, and celebrate small wins."
        case .fiery:
            return "Powerful reminders that push you to focus, act, and finish strong."
        }
    }
    
    var assetName: String {
        switch self {
        case .bluey:
            return "bluee"
        case .greeny:
            return "Grenny"
        case .sunny:
            return "Yellowwy"
        case .fiery:
            return "Reddy"
        }
    }
    
    var color: Color {
        switch self {
        case .bluey:
            return .blue
        case .greeny:
            return .green
        case .sunny:
            return .yellow
        case .fiery:
            return .orange
        }
    }
}