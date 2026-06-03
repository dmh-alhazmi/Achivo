//
//  BadgesView.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 18/05/2026.
//

import SwiftUI
import SwiftData

struct BadgesView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \AchievementBadge.name, order: .forward)
    private var badges: [AchievementBadge]
    
    @State private var selectedBadge: AchievementBadge?
    
    private var orderedBadges: [AchievementBadge] {
        badges.sorted { first, second in
            badgeOrder(first) < badgeOrder(second)
        }
    }
    
    private var badgeRows: [[AchievementBadge]] {
        stride(from: 0, to: orderedBadges.count, by: 2).map { index in
            Array(orderedBadges[index..<min(index + 2, orderedBadges.count)])
        }
    }
    
    var body: some View {
        ZStack {
            background
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    
                    header
                    
                    if orderedBadges.isEmpty {
                        emptyBadgesView
                    } else {
                        badgesGrid
                    }
                }
                .padding(.bottom, 110)
            }
            
            if let selectedBadge {
                BadgePopupView(
                    badge: selectedBadge,
                    onClose: {
                        self.selectedBadge = nil
                    }
                )
            }
        }
        .onAppear {
            BadgeAwardManager.prepareBadgesIfNeeded(
                modelContext: modelContext
            )
        }
    }
}

// MARK: - UI

private extension BadgesView {
    
    var background: some View {
        Image("AppBackground")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
    
    var header: some View {
        VStack(spacing: 8) {
            Text("The Badges")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.black)
                .padding(.top, 70)
            
            Text("\(unlockedCount) collected • \(lockedCount) locked")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.black.opacity(0.55))
        }
    }
    
    var badgesGrid: some View {
        VStack(spacing: 22) {
            ForEach(badgeRows.indices, id: \.self) { rowIndex in
                HStack(spacing: 28) {
                    ForEach(badgeRows[rowIndex], id: \.id) { badge in
                        BadgeCardView(badge: badge)
                            .onTapGesture {
                                selectedBadge = badge
                            }
                    }
                    
                    if badgeRows[rowIndex].count == 1 {
                        Spacer()
                            .frame(width: 128, height: 160)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 28)
    }
    
    var emptyBadgesView: some View {
        VStack(spacing: 12) {
            Image(systemName: "seal")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(Color.green)
            
            Text("No badges yet")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.black)
            
            Text("Complete goals and build streaks to collect badges.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
        }
        .padding(.top, 120)
    }
    
    var unlockedCount: Int {
        badges.filter { $0.isUnlocked }.count
    }
    
    var lockedCount: Int {
        badges.filter { !$0.isUnlocked }.count
    }
    
    func badgeOrder(_ badge: AchievementBadge) -> Int {
        if badge.isUnlocked {
            return 0
        }
        
        switch badge.kind {
        case .character:
            return 1
        case .streak:
            return 2
        }
    }
}

// MARK: - Badge Card

private struct BadgeCardView: View {
    
    let badge: AchievementBadge
    
    var body: some View {
        ZStack {
            Image("Badge")
                .resizable()
                .scaledToFit()
                .opacity(badge.isUnlocked ? 1 : 0.7)
            
            VStack(spacing: 5) {
                
                Image(badge.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 54, height: 54)
                    .opacity(badge.isUnlocked ? 1 : 0.23)
                    .saturation(badge.isUnlocked ? 1 : 0)
                    .padding(.top, 18)
                
                Text(badge.isUnlocked ? badge.name : "Locked Badge")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.black.opacity(badge.isUnlocked ? 1 : 0.45))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 10)
                
                Text(badge.isUnlocked ? badge.badgeDescription : lockedMessage)
                    .font(.system(size: 7, weight: .regular))
                    .foregroundStyle(.black.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 14)
                
                Spacer(minLength: 2)
                
                Text(badge.earnedDate?.badgeDateFormat ?? "Not collected yet")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundStyle(.black.opacity(0.5))
                    .padding(.bottom, 12)
            }
            .frame(width: 124, height: 154)
        }
        .frame(width: 128, height: 160)
    }
    
    private var lockedMessage: String {
        switch badge.kind {
        case .character:
            return "Complete a goal with this character."
        case .streak:
            if let days = badge.requiredStreakDays {
                return "Build a \(days)-day streak."
            } else {
                return "Keep going to collect it."
            }
        }
    }
}

// MARK: - Badge Popup

private struct BadgePopupView: View {
    
    let badge: AchievementBadge
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }
            
            ZStack {
                RoundedRectangle(cornerRadius: 36)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.94, blue: 0.84),
                                Color(red: 1.0, green: 0.90, blue: 0.76)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.15), radius: 18, x: 0, y: 8)
                
                VStack(spacing: 18) {
                    
                    ZStack {
                        Image("Badge")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 175, height: 210)
                            .opacity(badge.isUnlocked ? 1 : 0.7)
                        
                        VStack(spacing: 7) {
                            
                            Image(badge.iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 82, height: 82)
                                .opacity(badge.isUnlocked ? 1 : 0.23)
                                .saturation(badge.isUnlocked ? 1 : 0)
                                .padding(.top, 22)
                            
                            Text(badge.isUnlocked ? badge.name : "Locked Badge")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.black.opacity(badge.isUnlocked ? 1 : 0.45))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 18)
                            
                            Text(badge.isUnlocked ? badge.badgeDescription : lockedPopupMessage)
                                .font(.system(size: 9))
                                .foregroundStyle(.black.opacity(0.65))
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                                .padding(.horizontal, 24)
                            
                            Spacer(minLength: 2)
                            
                            Text(badge.earnedDate?.badgeDateFormat ?? "Not collected yet")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(.black.opacity(0.55))
                                .padding(.bottom, 18)
                        }
                        .frame(width: 175, height: 210)
                    }
                    
                    Button {
                        onClose()
                    } label: {
                        Text("Got it!")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 120, height: 44)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.36, green: 0.57, blue: 0.05))
                            )
                    }
                }
                .padding(.vertical, 30)
            }
            .frame(width: 330, height: 420)
        }
    }
    
    private var lockedPopupMessage: String {
        switch badge.kind {
        case .character:
            return "Complete a full goal with this character to collect this badge."
        case .streak:
            if let days = badge.requiredStreakDays {
                return "Complete goals for \(days) days in a row to collect this badge."
            } else {
                return "Keep completing goals and building your streak to collect this badge."
            }
        }
    }
}

// MARK: - Date Format

private extension Date {
    
    var badgeDateFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, yyyy"
        return formatter.string(from: self)
    }
}

// MARK: - Preview

#Preview {
    BadgesView()
        .modelContainer(
            for: [
                Goal.self,
                AchievementBadge.self
            ],
            inMemory: true
        )
}
