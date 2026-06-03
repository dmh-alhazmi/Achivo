//
//  AppBottomNavBar.swift
//  Achivo
//
//  Created by Asma Khan on 25/11/1447 AH.
//

import SwiftUI

typealias BottomTab = AppTab

struct AppBottomNavBar: View {
    
    @Binding var selectedTab: AppTab
    @Namespace private var animation
    
    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let navWidth = min(screenWidth * 0.86, 340)
            
            HStack(spacing: 6) {
                BottomNavItem(
                    tab: .streak,
                    selectedTab: $selectedTab,
                    title: "Streak",
                    iconName: "flame.fill",
                    selectedColor: Color(red: 0.96, green: 0.50, blue: 0.20),
                    selectedBackground: Color(red: 1.00, green: 0.86, blue: 0.66),
                    animation: animation
                )
                
                BottomNavItem(
                    tab: .goal,
                    selectedTab: $selectedTab,
                    title: "Goal",
                    iconName: "target",
                    selectedColor: Color(red: 0.22, green: 0.72, blue: 0.32),
                    selectedBackground: Color(red: 0.78, green: 0.93, blue: 0.65),
                    animation: animation
                )
                
                BottomNavItem(
                    tab: .badge,
                    selectedTab: $selectedTab,
                    title: "Badge",
                    iconName: "shield.fill",
                    selectedColor: Color(red: 0.46, green: 0.60, blue: 0.88),
                    selectedBackground: Color(red: 0.78, green: 0.86, blue: 1.00),
                    animation: animation
                )
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .frame(width: navWidth, height: 70)
            .background(navBackground)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay(navBorder)
            .shadow(color: Color.black.opacity(0.08), radius: 18, x: 0, y: 8)
            .position(x: screenWidth / 2, y: 35)
        }
        .frame(height: 70)
    }
    
    private var navBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.00, green: 0.97, blue: 0.91),
                           // Color(red: 0.96, green: 0.98, blue: 0.89)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.22))
        }
    }
    
    private var navBorder: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .stroke(
                Color.white.opacity(0.75),
                lineWidth: 1
            )
    }
}

// MARK: - Bottom Nav Item

private struct BottomNavItem: View {
    
    let tab: AppTab
    @Binding var selectedTab: AppTab
    
    let title: String
    let iconName: String
    let selectedColor: Color
    let selectedBackground: Color
    let animation: Namespace.ID
    
    private var isSelected: Bool {
        selectedTab == tab
    }
    
    private let inactiveColor = Color(red: 0.25, green: 0.28, blue: 0.25).opacity(0.50)
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.76)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: isSelected ? 7 : 0) {
                
                ZStack {
                    if isSelected {
//                        Circle()
//                            .fill(Color.white.opacity(0.33))
//                            .frame(width: 32, height: 32)
                    }
                    
                    Image(systemName: iconName)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(isSelected ? selectedColor : inactiveColor)
                        .frame(width: 30, height: 30)
                        .scaleEffect(isSelected ? 1.08 : 1.0)
                }
                
                if isSelected {
                    Text(title)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.14, green: 0.18, blue: 0.14))
                        .lineLimit(1)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }
            .frame(maxWidth: isSelected ? 122 : 62)
            .frame(height: 52)
            .background {
                if isSelected {
                    selectedPill
                        .matchedGeometryEffect(id: "selectedTab", in: animation)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
    }
    
    private var selectedPill: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        selectedBackground.opacity(0.95),
                        selectedBackground.opacity(0.55),
                        Color.white.opacity(0.58)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.80), lineWidth: 1)
            }
            .shadow(color: selectedColor.opacity(0.18), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color("background")
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            
            AppBottomNavBar(selectedTab: .constant(.badge))
                .padding(.horizontal, 18)
                .padding(.bottom, 20)
        }
    }
}
