//
//  EnergyNotificationProfile.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 11/05/2026.
//

import Foundation
import UserNotifications

// MARK: - Notification Profile

struct EnergyNotificationProfile {
    let dailyCount: Int
    let hours: [Int]
    let toneDescription: String
}

extension GrowthEnergy {
    
    var notificationProfile: EnergyNotificationProfile {
        switch self {
        case .bluey:
            return EnergyNotificationProfile(
                dailyCount: 2,
                hours: [11, 20],
                toneDescription: "Gentle, calm, no pressure"
            )
            
        case .greeny:
            return EnergyNotificationProfile(
                dailyCount: 3,
                hours: [9, 14, 19],
                toneDescription: "Consistent, routine-based, steady"
            )
            
        case .sunny:
            return EnergyNotificationProfile(
                dailyCount: 4,
                hours: [8, 12, 16, 19],
                toneDescription: "Positive, cheerful, motivating"
            )
            
        case .fiery:
            return EnergyNotificationProfile(
                dailyCount: 5,
                hours: [7, 10, 13, 16, 21],
                toneDescription: "Focused, powerful, achievement-driven"
            )
        }
    }
}

// MARK: - Notification Delegate
// This makes notifications show even when the app is open.

final class AchivoNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = AchivoNotificationDelegate()
    
    private override init() {}
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }
}

// MARK: - Notification Manager

enum AchivoNotificationManager {
    
    private static let notificationPrefix = "achivo.energy.notification"
    
    // Ask the user for notification permission
    static func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            
            print("Notification permission:", granted)
            return granted
        } catch {
            print("Notification permission error:", error.localizedDescription)
            return false
        }
    }
    
    // Schedule daily notifications based on the selected character energy
    static func scheduleDailyNotifications(for energy: GrowthEnergy) async {
        let granted = await requestPermission()
        
        guard granted else {
            print("Notifications permission was not granted.")
            return
        }
        
        removeAchivoNotifications()
        
        let profile = energy.notificationProfile
        let messages = energy.notificationMessages
        
        for index in profile.hours.indices {
            let hour = profile.hours[index]
            let message = messages[index % messages.count]
            
            let content = UNMutableNotificationContent()
            content.title = message.title
            content.body = message.body
            content.sound = .default
            content.badge = 1
            
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: true
            )
            
            let request = UNNotificationRequest(
                identifier: "\(notificationPrefix).\(index)",
                content: content,
                trigger: trigger
            )
            
            do {
                try await UNUserNotificationCenter.current().add(request)
                print("Scheduled notification at \(hour):00")
            } catch {
                print("Failed to schedule notification:", error.localizedDescription)
            }
        }
    }
    
    // Test notification after 5 seconds
    static func scheduleTestNotification(for energy: GrowthEnergy) async {
        let granted = await requestPermission()
        
        guard granted else {
            print("Notifications permission was not granted.")
            return
        }
        
        let message = energy.notificationMessages.randomElement()
        ?? EnergyNotificationContent(
            title: "Keep growing",
            body: "One small step is enough today."
        )
        
        let content = UNMutableNotificationContent()
        content.title = message.title
        content.body = message.body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 5,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "\(notificationPrefix).test",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Test notification scheduled.")
        } catch {
            print("Failed to schedule test notification:", error.localizedDescription)
        }
    }
    
    static func removeAchivoNotifications() {
        let ids = (0...10).map { "\(notificationPrefix).\($0)" } + [
            "\(notificationPrefix).test"
        ]
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ids
        )
        
        print("Old Achivo notifications removed.")
    }
}
