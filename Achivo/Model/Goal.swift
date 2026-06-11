//
//  Goal.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 03/05/2026.
//

import Foundation
import SwiftData

@Model
final class Goal {
    
    var completedDates: [Date] = []
    var completedSubGoalRecords: [String] = []
    var boostDayCount: Int = 0
    
    var title: String
    var subGoal: String
    var durationDays: Int
    var selectedEnergyRawValue: String
    var createdAt: Date
    var completedDays: Int
    var isCompletedToday: Bool
    var isActive: Bool
    
    init(
        title: String,
        subGoal: String,
        durationDays: Int,
        selectedEnergy: GrowthEnergy,
        createdAt: Date = Date(),
        completedDays: Int = 0,
        isCompletedToday: Bool = false,
        isActive: Bool = true
    ) {
        self.title = title
        self.subGoal = subGoal
        self.durationDays = durationDays
        self.selectedEnergyRawValue = selectedEnergy.rawValue
        self.createdAt = createdAt
        self.completedDays = completedDays
        self.isCompletedToday = isCompletedToday
        self.isActive = isActive
    }
    
    var selectedEnergy: GrowthEnergy {
        GrowthEnergy(rawValue: selectedEnergyRawValue) ?? .sunny
    }
    
    var subGoalItems: [String] {
        subGoal
            .split(separator: "\n")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    var totalTaskCount: Int {
        max(subGoalItems.count, 1) * max(durationDays, 1)
    }
    
    var completedTaskCount: Int {
        min(completedSubGoalRecords.count, totalTaskCount)
    }
    
    var progress: Double {
        guard totalTaskCount > 0 else { return 0 }
        return min(Double(completedTaskCount) / Double(totalTaskCount), 1)
    }
    
    var remainingDays: Int {
        max(durationDays - completedDays, 0)
    }
    
    var isFinished: Bool {
        completedTaskCount >= totalTaskCount
    }
    
    var endDate: Date {
        Calendar.current.date(
            byAdding: .day,
            value: durationDays,
            to: createdAt
        ) ?? createdAt
    }
    
    var isExpired: Bool {
        Date() > endDate && !isFinished
    }
    
    var isDoneToday: Bool {
        areAllSubGoalsDone(on: Date())
    }
    
    var goalStatus: GoalStatus {
        if isFinished {
            return .finished
        } else if !isActive || isExpired {
            return .inactive
        } else {
            return .active
        }
    }
    
    func isSubGoalDoneToday(index: Int) -> Bool {
        let key = recordKey(for: index, date: Date())
        return completedSubGoalRecords.contains(key)
    }
    
    func toggleSubGoalToday(index: Int) {
        if isSubGoalDoneToday(index: index) {
            uncheckSubGoalToday(index: index)
        } else {
            checkSubGoalToday(index: index)
        }
    }
    
    func checkSubGoalToday(index: Int) {
        let today = Calendar.current.startOfDay(for: Date())
        let key = recordKey(for: index, date: today)
        
        guard isActive else { return }
        guard !isFinished else { return }
        guard subGoalItems.indices.contains(index) else { return }
        guard !completedSubGoalRecords.contains(key) else { return }
        guard completedSubGoalRecords.count < totalTaskCount else { return }
        
        completedSubGoalRecords.append(key)
        updateTodayCompletionState()
    }
    
    func uncheckSubGoalToday(index: Int) {
        let today = Calendar.current.startOfDay(for: Date())
        let key = recordKey(for: index, date: today)
        
        completedSubGoalRecords.removeAll { $0 == key }
        updateTodayCompletionState()
    }
    
    func checkToday() {
        let items = subGoalItems
        
        guard isActive else { return }
        guard !isFinished else { return }
        guard !items.isEmpty else { return }
        
        for index in items.indices {
            checkSubGoalToday(index: index)
        }
        
        updateTodayCompletionState()
    }
    
    func uncheckToday() {
        let todayKey = dayKey(for: Date())
        
        completedSubGoalRecords.removeAll { record in
            record.hasPrefix("\(todayKey)|")
        }
        
        updateTodayCompletionState()
    }
    
    func boostOneFullDay() {
        let items = subGoalItems
        
        guard isActive else { return }
        guard !isFinished else { return }
        guard !items.isEmpty else { return }
        guard completedSubGoalRecords.count < totalTaskCount else { return }
        
        boostDayCount += 1
        
        for index in items.indices {
            guard completedSubGoalRecords.count < totalTaskCount else { break }
            
            let key = "boost-\(boostDayCount)|\(index)"
            
            if !completedSubGoalRecords.contains(key) {
                completedSubGoalRecords.append(key)
            }
        }
        
        completedDays = min(completedDates.count + boostDayCount, durationDays)
        isCompletedToday = areAllSubGoalsDone(on: Date())
    }
    
    func deactivateIfNeeded() {
        if isExpired && !isFinished {
            isActive = false
            isCompletedToday = false
        }
    }
    
    func restartGoal() {
        createdAt = Date()
        completedDays = 0
        completedDates = []
        completedSubGoalRecords = []
        boostDayCount = 0
        isCompletedToday = false
        isActive = true
    }
    
    private func updateTodayCompletionState() {
        let today = Calendar.current.startOfDay(for: Date())
        let alreadyHasToday = completedDates.contains { date in
            Calendar.current.isDate(date, inSameDayAs: today)
        }
        
        if areAllSubGoalsDone(on: today) {
            if !alreadyHasToday {
                completedDates.append(today)
            }
        } else {
            completedDates.removeAll { date in
                Calendar.current.isDate(date, inSameDayAs: today)
            }
        }
        
        completedDays = min(completedDates.count + boostDayCount, durationDays)
        isCompletedToday = areAllSubGoalsDone(on: today)
    }
    
    private func areAllSubGoalsDone(on date: Date) -> Bool {
        let items = subGoalItems
        guard !items.isEmpty else { return false }
        
        return items.indices.allSatisfy { index in
            completedSubGoalRecords.contains(recordKey(for: index, date: date))
        }
    }
    
    private func recordKey(for index: Int, date: Date) -> String {
        "\(dayKey(for: date))|\(index)"
    }
    
    private func dayKey(for date: Date) -> String {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let components = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: startOfDay
        )
        
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        
        return "\(year)-\(month)-\(day)"
    }
}

enum GoalStatus {
    case active
    case inactive
    case finished
}
