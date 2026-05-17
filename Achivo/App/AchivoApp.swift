//
//  AchivoApp.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 03/05/2026.
//

import SwiftUI
import SwiftData

@main
struct AchivoApp: App {
    
    @State private var router = AppRouter()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(router)
        }
        .modelContainer(for: Goal.self)
    }
}
