//
//  ContentView.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 03/05/2026.
//

import SwiftUI
import SwiftData
import SwiftUI

struct ContentView: View {
    
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        @Bindable var router = router
        
        ZStack {
            selectedPage
            
            VStack {
                Spacer()
                
                AppBottomNavBar(selectedTab: $router.selectedTab)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 10)
            }
        }
    }
    
    @ViewBuilder
    private var selectedPage: some View {
        switch router.selectedTab {
        case .streak:
            Text("Streak Page")
            
        case .goal:
            MyGoalsView()
            
        case .badge:
            Text("Badge Page")
        }
    }
}

#Preview {
    ContentView()
        .environment(AppRouter())
}
