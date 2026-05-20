//
//  BadgeAwardManager.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 20/05/2026.
//
//  BadgeAwardManager.swift
//  Achivo
//

import Foundation
import SwiftData

enum BadgeAwardManager {
    
    static func prepareBadgesIfNeeded(modelContext: ModelContext) {
        do {
            let existingBadges = try modelContext.fetch(FetchDescriptor<AchievementBadge>())
            let existingIDs = Set(existingBadges.map { $0.id })
            
            for badge in makeDefaultBadges() {
                if !existingIDs.contains(badge.id) {
                    modelContext.insert(badge)
                }
            }
            
            try modelContext.save()
            
        } catch {
            print("Failed to prepare badges:", error.localizedDescription)
        }
    }
    
    static func awardBadgesIfNeeded(
        afterUpdating goal: Goal,
        allGoals: [Goal],
        modelContext: ModelContext
    ) -> [AchievementBadge] {
        
        prepareBadgesIfNeeded(modelContext: modelContext)
        
        do {
            let badges = try modelContext.fetch(FetchDescriptor<AchievementBadge>())
            var newlyUnlockedBadges: [AchievementBadge] = []
            
            if let characterBadge = unlockCharacterBadgeIfNeeded(
                for: goal,
                badges: badges
            ) {
                newlyUnlockedBadges.append(characterBadge)
            }
            
            let streakBadges = unlockStreakBadgesIfNeeded(
                allGoals: allGoals,
                badges: badges
            )
            
            newlyUnlockedBadges.append(contentsOf: streakBadges)
            
            return newlyUnlockedBadges
            
        } catch {
            print("Failed to award badges:", error.localizedDescription)
            return []
        }
    }
    
    private static func unlockCharacterBadgeIfNeeded(
        for goal: Goal,
        badges: [AchievementBadge]
    ) -> AchievementBadge? {
        
        guard goal.isFinished else { return nil }
        
        let character = characterForGoal(goal)
        
        guard let badge = badges.first(where: {
            $0.kind == .character &&
            $0.character == character
        }) else {
            return nil
        }
        
        return unlock(badge)
    }
    
    private static func unlockStreakBadgesIfNeeded(
        allGoals: [Goal],
        badges: [AchievementBadge]
    ) -> [AchievementBadge] {
        
        let streak = currentStreak(from: allGoals)
        var newlyUnlockedBadges: [AchievementBadge] = []
        
        for badge in badges {
            guard badge.kind == .streak else { continue }
            guard let requiredDays = badge.requiredStreakDays else { continue }
            
            if streak >= requiredDays {
                if let unlockedBadge = unlock(badge) {
                    newlyUnlockedBadges.append(unlockedBadge)
                }
            }
        }
        
        return newlyUnlockedBadges
    }
    
    private static func unlock(_ badge: AchievementBadge) -> AchievementBadge? {
        guard !badge.isUnlocked else { return nil }
        
        badge.isUnlocked = true
        badge.earnedDate = Date()
        
        return badge
    }
    
    private static func currentStreak(from goals: [Goal]) -> Int {
        let calendar = Calendar.current
        
        let completedDates = Set(
            goals
                .flatMap { $0.completedDates }
                .map { calendar.startOfDay(for: $0) }
        )
        
        var count = 0
        var date = calendar.startOfDay(for: Date())
        
        while completedDates.contains(date) {
            count += 1
            
            guard let previousDay = calendar.date(
                byAdding: .day,
                value: -1,
                to: date
            ) else {
                break
            }
            
            date = previousDay
        }
        
        return count
    }
    
    private static func characterForGoal(_ goal: Goal) -> GoalCharacter {
        switch goal.selectedEnergy {
        case .sunny:
            return .yellow
        case .bluey:
            return .blue
        case .greeny:
            return .green
        case .fiery:
            return .red
        }
    }
    
    private static func makeDefaultBadges() -> [AchievementBadge] {
        [
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
            )
        ]
    }
}
