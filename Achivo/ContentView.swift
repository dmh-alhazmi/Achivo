//
//  ContentView.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 03/05/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(AppRouter.self) private var router
    
    @AppStorage("hasSeenPersonalityOnboarding")
    private var hasSeenPersonalityOnboarding: Bool = false
    
    @State private var showAddGoalView: Bool = false
    
    var body: some View {
        @Bindable var router = router
        
        Group {
            if hasSeenPersonalityOnboarding {
                ZStack {
                    selectedPage
                    
                    VStack {
                        Spacer()
                        
                        AppBottomNavBar(selectedTab: $router.selectedTab)
                            .padding(.horizontal, 18)
                            .padding(.bottom, 10)
                    }
                }
            } else {
                PersonalityOnboardingView {
                    hasSeenPersonalityOnboarding = true
                    router.goToGoals()
                    showAddGoalView = true
                }
            }
        }
        .fullScreenCover(isPresented: $showAddGoalView) {
            AddGoalView()
        }
    }
    
    @ViewBuilder
    private var selectedPage: some View {
        switch router.selectedTab {
        case .streak:
            StreakScreen()
            
        case .goal:
            MyGoalsView()
            
        case .badge:
            BadgesView()
        }
    }
}

#Preview {
    ContentView()
        .environment(AppRouter())
}
