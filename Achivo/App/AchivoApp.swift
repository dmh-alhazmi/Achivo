//
//  AchivoApp.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 03/05/2026.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct AchivoApp: App {
    
    @State private var router = AppRouter()
    
    init() {
        UNUserNotificationCenter.current().delegate = AchivoNotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(router)
        }
        .modelContainer(for: [
            Goal.self,
            AchievementBadge.self
        ])
    }
}
