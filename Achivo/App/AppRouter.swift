//
//  AppRouter.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 03/05/2026.
//

import Foundation
import Observation

@Observable
final class AppRouter {
    
    var selectedTab: AppTab = .goal
    
    func goToStreak() {
        selectedTab = .streak
    }
    
    func goToGoals() {
        selectedTab = .goal
    }
    
    func goToBadge() {
        selectedTab = .badge
    }
}

enum AppTab {
    case streak
    case goal
    case badge
}
