//
//  AchievementBadge.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 18/05/2026.
//
//
//  AchievementBadge.swift
//  Achivo
//

import Foundation
import SwiftData

enum BadgeKind: String, Codable, CaseIterable {
    case character
    case streak
}

enum GoalCharacter: String, Codable, CaseIterable {
    case yellow
    case blue
    case green
    case red
    
    var displayName: String {
        switch self {
        case .yellow:
            return "Yellow"
        case .blue:
            return "Blue"
        case .green:
            return "Green"
        case .red:
            return "Red"
        }
    }
}

@Model
final class AchievementBadge {
    
    @Attribute(.unique) var id: String
    
    var name: String
    var badgeDescription: String
    var iconName: String
    
    // This decides if the badge is collected or still locked
    var isUnlocked: Bool
    
    // This is nil until the user collects the badge
    var earnedDate: Date?
    
    // Stored as String because SwiftData works better with raw values
    private var kindRawValue: String
    private var characterRawValue: String?
    
    // Only used for streak badges
    var requiredStreakDays: Int?
    
    var kind: BadgeKind {
        get {
            BadgeKind(rawValue: kindRawValue) ?? .character
        }
        set {
            kindRawValue = newValue.rawValue
        }
    }
    
    var character: GoalCharacter? {
        get {
            guard let characterRawValue else { return nil }
            return GoalCharacter(rawValue: characterRawValue)
        }
        set {
            characterRawValue = newValue?.rawValue
        }
    }
    
    init(
        id: String = UUID().uuidString,
        name: String,
        badgeDescription: String,
        iconName: String,
        isUnlocked: Bool = false,
        earnedDate: Date? = nil,
        kind: BadgeKind,
        character: GoalCharacter? = nil,
        requiredStreakDays: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.badgeDescription = badgeDescription
        self.iconName = iconName
        self.isUnlocked = isUnlocked
        self.earnedDate = earnedDate
        self.kindRawValue = kind.rawValue
        self.characterRawValue = character?.rawValue
        self.requiredStreakDays = requiredStreakDays
    }
}
