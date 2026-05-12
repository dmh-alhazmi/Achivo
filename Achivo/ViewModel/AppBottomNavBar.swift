
//
//  AppBottomNavBar.swift
//  Achivo
//
//  Created by Asma Khan on 25/11/1447 AH.
//

import SwiftUI

enum BottomTab {
    case streak
    case goal
    case badge
}

struct AppBottomNavBar: View {
    @Binding var selectedTab: BottomTab

    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let navWidth = min(screenWidth * 0.94, 370)
            let navHeight: CGFloat = 71

            HStack(spacing: 0) {
                BottomNavItem(
                    title: "Streak",
                    iconName: "streak_icon",
                    isSelected: selectedTab == .streak,
                    itemWidth: navWidth / 3
                ) {
                    selectedTab = .streak
                }

                BottomNavItem(
                    title: "Goal",
                    iconName: "goal_icon",
                    isSelected: selectedTab == .goal,
                    itemWidth: navWidth / 3
                ) {
                    selectedTab = .goal
                }

                BottomNavItem(
                    title: "Badge",
                    iconName: "badge_icon",
                    isSelected: selectedTab == .badge,
                    itemWidth: navWidth / 3
                ) {
                    selectedTab = .badge
                }
            }
            .frame(width: navWidth, height: navHeight)
            .background(
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color(red: 1.0, green: 0.98, blue: 0.94))
            )
            .shadow(
                color: Color.black.opacity(0.25),
                radius: 8,
                x: 0,
                y: 4
            )
            .position(
                x: screenWidth / 2,
                y: navHeight / 2
            )
        }
        .frame(height: 71)
    }
}

struct BottomNavItem: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let itemWidth: CGFloat
    let action: () -> Void

    private let activeColor = Color(red: 0.10, green: 0.14, blue: 0.22)
    private let inactiveColor = Color(red: 0.10, green: 0.14, blue: 0.22).opacity(0.75)

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(iconName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 31, height: 31)
                    .foregroundColor(isSelected ? activeColor : inactiveColor)

                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isSelected ? activeColor : inactiveColor)
            }
            .frame(width: itemWidth, height: 71)
        }
        .buttonStyle(.plain)
    }
}
