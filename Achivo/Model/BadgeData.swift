//
//  BadgeData.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 18/05/2026.
//
//
//  BadgeData.swift
//  Achivo
//

import Foundation

struct BadgeData {
    
    static let defaultBadges: [AchievementBadge] = [
        
        // MARK: - Character Badges
        
        AchievementBadge(
            id: "first-yellow-step",
            name: "First Yellow Step",
            badgeDescription: "Complete your first goal with the Yellow character.",
            iconName: "Sun_icon",
            kind: .character,
            character: .yellow
        ),
        
        AchievementBadge(
            id: "first-blue-step",
            name: "First Blue Step",
            badgeDescription: "Complete your first goal with the Blue character.",
            iconName: "BlueBadge_icon",
            kind: .character,
            character: .blue
        ),
        
        AchievementBadge(
            id: "first-green-step",
            name: "First Green Step",
            badgeDescription: "Complete your first goal with the Green character.",
            iconName: "Star_icon",
            kind: .character,
            character: .green
        ),
        
        AchievementBadge(
            id: "first-red-step",
            name: "First Red Step",
            badgeDescription: "Complete your first goal with the Red character.",
            iconName: "RedGoal_icon",
            kind: .character,
            character: .red
        ),
        
        
        // MARK: - Streak Badges
        
        AchievementBadge(
            id: "momentum",
            name: "Momentum",
            badgeDescription: "Finish goals 3 days in a row.",
            iconName: "Light_icon",
            kind: .streak,
            requiredStreakDays: 3
        ),
        
        AchievementBadge(
            id: "breathing-space",
            name: "Breathing Space",
            badgeDescription: "Complete goals for 5 days.",
            iconName: "CupPlant_icon",
            kind: .streak,
            requiredStreakDays: 5
        ),
        
        AchievementBadge(
            id: "locked-in",
            name: "Locked In",
            badgeDescription: "Finish 7 goals in one week.",
            iconName: "Fire_icon",
            kind: .streak,
            requiredStreakDays: 7
        ),
        
        AchievementBadge(
            id: "growing-slowly",
            name: "Growing Slowly",
            badgeDescription: "Grow your habit one step at a time for 10 days.",
            iconName: "Plant_icon",
            kind: .streak,
            requiredStreakDays: 10
        ),
        
        AchievementBadge(
            id: "blooming-mind",
            name: "Blooming Mind",
            badgeDescription: "Stay committed for 14 days.",
            iconName: "Flower_icon",
            kind: .streak,
            requiredStreakDays: 14
        ),
        
        AchievementBadge(
            id: "inner-peace",
            name: "Inner Peace",
            badgeDescription: "Stay consistent for 21 days.",
            iconName: "Cloud_icon",
            kind: .streak,
            requiredStreakDays: 21
        ),
        
        
        // MARK: - Extra Badges
        
        AchievementBadge(
            id: "read-10-pages",
            name: "Read 10 Pages",
            badgeDescription: "Complete a reading goal.",
            iconName: "Book_icon",
            kind: .streak,
            requiredStreakDays: 1
        ),
        
        AchievementBadge(
            id: "focus-mode",
            name: "Focus Mode",
            badgeDescription: "Stay focused for one hour.",
            iconName: "HeadPhone_icon",
            kind: .streak,
            requiredStreakDays: 1
        ),
        
        AchievementBadge(
            id: "rest-counts-too",
            name: "Rest Counts Too",
            badgeDescription: "Take a break without guilt.",
            iconName: "Pillow_icon",
            kind: .streak,
            requiredStreakDays: 1
        ),
        
        AchievementBadge(
            id: "night-owl",
            name: "Night Owl",
            badgeDescription: "Complete a late-night task.",
            iconName: "Night_icon",
            kind: .streak,
            requiredStreakDays: 1
        ),
        
        AchievementBadge(
            id: "soft-day",
            name: "Soft Day",
            badgeDescription: "Complete one gentle goal.",
            iconName: "Candle_icon",
            kind: .streak,
            requiredStreakDays: 1
        ),
        
        AchievementBadge(
            id: "keep-going",
            name: "Keep Going",
            badgeDescription: "You are building something.",
            iconName: "YellowFlower_icon",
            kind: .streak,
            requiredStreakDays: 1
        ),
        
        AchievementBadge(
            id: "still-showing-up",
            name: "Still Showing Up",
            badgeDescription: "You kept going today.",
            iconName: "Grow_icon",
            kind: .streak,
            requiredStreakDays: 1
        ),
        
        AchievementBadge(
            id: "good-energy",
            name: "Good Energy",
            badgeDescription: "You finished with good energy.",
            iconName: "Cup_icon",
            kind: .streak,
            requiredStreakDays: 1
        )
    ]
}
