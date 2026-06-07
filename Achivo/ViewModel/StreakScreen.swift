//
//  StreakScreen.swift
//  Achivo
//
//  Created by Asma Khan on 30/11/1447 AH.
//

import SwiftUI
import SwiftData

struct StreakScreen: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @Query(sort: \Goal.createdAt, order: .reverse)
    private var goals: [Goal]
    
    @State private var showInfo = false
    @State private var months: [Date] = []
    
    private let calendar = Calendar.current
    
    private var completedDates: Set<Date> {
        Set(
            goals
                .flatMap { $0.completedDates }
                .map { calendar.startOfDay(for: $0) }
        )
    }
    
    private var streakCount: Int {
        var count = 0
        var date = calendar.startOfDay(for: Date())
        
        while completedDates.contains(date) {
            count += 1
            guard let previousDay = calendar.date(
                byAdding: .day,
                value: -1,
                to: date
            ) else {
                break
            }
            date = previousDay
        }
        
        return count
    }
    
    var body: some View {
        ZStack {
            background
            
            VStack(spacing: 0) {
                header
                
                Text("Keep showing up, keep growing!")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(secondaryTextColor)
                    .padding(.top, 30)
                
                streakCircle
                    .padding(.top, 36)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Journey")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(primaryTextColor)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 22) {
                            ForEach(months, id: \.self) { month in
                                MonthCalendarView(
                                    monthDate: month,
                                    completedDates: completedDates
                                )
                                .onAppear {
                                    loadMoreIfNeeded(month)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(calendarCardColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(calendarBorderColor, lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal, 28)
                .padding(.top, 52)
                
                Spacer(minLength: 0)
            }
            .padding(.top, 18)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            setupMonths()
        }
        .alert("Streak Info", isPresented: $showInfo) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Current streak is Day \(streakCount). Completed dates are based on checked goals.")
        }
    }
}

// MARK: - Colors

private extension StreakScreen {
    
    var primaryTextColor: Color {
        colorScheme == .dark
        ? Color(red: 1.0, green: 0.97, blue: 0.90)
        : .black
    }
    
    var secondaryTextColor: Color {
        colorScheme == .dark
        ? Color(red: 0.92, green: 0.88, blue: 0.78)
        : Color.gray
    }
    
    var calendarCardColor: Color {
        colorScheme == .dark
        ? Color(red: 0.22, green: 0.22, blue: 0.19)
        : Color(red: 0.98, green: 0.90, blue: 0.80).opacity(0.85)
    }
    
    var calendarBorderColor: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.32)
        : Color.white.opacity(0.9)
    }
    
    var streakCircleColor: Color {
        colorScheme == .dark
        ? Color(red: 0.22, green: 0.22, blue: 0.19)
        : Color(red: 0.98, green: 0.90, blue: 0.80)
    }
    
    var accentGreen: Color {
        Color(red: 0.42, green: 0.62, blue: 0.13)
    }
}

// MARK: - UI

private extension StreakScreen {
    
    var header: some View {
        HStack {
            Spacer()
            
            Text("Streak")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(primaryTextColor)
            
            Spacer()
            
            Button {
                showInfo = true
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(primaryTextColor)
                    .frame(width: 36, height: 36)
            }
            .accessibilityLabel("Streak information")
        }
        .padding(.horizontal, 22)
        .padding(.top, 25)
    }
    
    var streakCircle: some View {
        ZStack {
            Circle()
                .fill(streakCircleColor)
                .frame(width: 150, height: 150)
                .overlay(
                    Circle()
                        .stroke(
                            colorScheme == .dark
                            ? Color.white.opacity(0.25)
                            : Color.white.opacity(0.55),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: .black.opacity(colorScheme == .dark ? 0.32 : 0.22),
                    radius: 5,
                    x: 0,
                    y: 3
                )
            
            HStack(spacing: 5) {
                Text("Day")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(secondaryTextColor)
                
                Text("\(streakCount)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(accentGreen)
                
                Text("🔥")
                    .font(.system(size: 17))
            }
        }
    }
    
    var background: some View {
        Image("AppBackground")
            .resizable()
           // .scaledToFill()
            .ignoresSafeArea()
    }
}

// MARK: - Logic

private extension StreakScreen {
    
    func setupMonths() {
        guard months.isEmpty else { return }
        
        let currentMonth = calendar.date(
            from: calendar.dateComponents([.year, .month], from: Date())
        ) ?? Date()
        
        months = (0...12).compactMap {
            calendar.date(byAdding: .month, value: $0, to: currentMonth)
        }
    }
    
    func loadMoreIfNeeded(_ month: Date) {
        guard month == months.last else { return }
        guard let last = months.last else { return }
        
        let moreMonths = (1...12).compactMap {
            calendar.date(byAdding: .month, value: $0, to: last)
        }
        
        months.append(contentsOf: moreMonths)
    }
}

// MARK: - Month Calendar

struct MonthCalendarView: View {
    
    let monthDate: Date
    let completedDates: Set<Date>
    
    @Environment(\.colorScheme) private var colorScheme
    
    private let calendar = Calendar.current
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 8),
        count: 7
    )
    
    private let weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: monthDate)
    }
    
    private var days: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: monthDate),
              let startOfMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: monthDate)
              ) else {
            return []
        }
        
        return range.compactMap {
            calendar.date(byAdding: .day, value: $0 - 1, to: startOfMonth)
        }
    }
    
    private var leadingSpaces: Int {
        guard let firstDay = days.first else { return 0 }
        return calendar.component(.weekday, from: firstDay) - 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(monthTitle)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(monthTitleColor)
                .padding(.leading, 5)
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(weekdayColor)
                }
                
                ForEach(0..<leadingSpaces, id: \.self) { _ in
                    Color.clear
                        .frame(width: 28, height: 28)
                }
                
                ForEach(days, id: \.self) { date in
                    dayView(date)
                }
            }
            
            Rectangle()
                .fill(dividerColor)
                .frame(height: 1)
                .padding(.horizontal, 5)
                .padding(.top, 2)
        }
    }
}

// MARK: - Month Calendar Colors

private extension MonthCalendarView {
    
    var monthTitleColor: Color {
        colorScheme == .dark
        ? Color(red: 1.0, green: 0.97, blue: 0.90)
        : .black
    }
    
    var weekdayColor: Color {
        colorScheme == .dark
        ? Color(red: 0.90, green: 0.86, blue: 0.76)
        : .black.opacity(0.75)
    }
    
    var normalDayColor: Color {
        colorScheme == .dark
        ? Color(red: 1.0, green: 0.97, blue: 0.90)
        : .black.opacity(0.82)
    }
    
    var todayTextColor: Color {
        colorScheme == .dark ? .black : .black
    }
    
    var completedDayColor: Color {
        .white
    }
    
    var completedCircleColor: Color {
        Color(red: 0.42, green: 0.62, blue: 0.13)
    }
    
    var todayCircleColor: Color {
        colorScheme == .dark
        ? Color(red: 0.96, green: 0.82, blue: 0.42)
        : Color(red: 0.78, green: 0.84, blue: 0.45)
    }
    
    var dividerColor: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.25)
        : Color.black.opacity(0.25)
    }
}

// MARK: - Day View

private extension MonthCalendarView {
    
    func dayView(_ date: Date) -> some View {
        let day = calendar.component(.day, from: date)
        let isCompleted = completedDates.contains(calendar.startOfDay(for: date))
        let isToday = calendar.isDateInToday(date)
        
        return Text("\(day)")
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(
                isCompleted
                ? completedDayColor
                : isToday
                ? todayTextColor
                : normalDayColor
            )
            .frame(width: 28, height: 28)
            .background(
                Circle()
                    .fill(
                        isCompleted
                        ? completedCircleColor
                        : isToday
                        ? todayCircleColor
                        : Color.clear
                    )
            )
    }
}

// MARK: - Decorative Background

struct DecorativeBackground: View {
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.98, green: 0.84, blue: 0.66).opacity(0.45))
                .frame(width: 135, height: 135)
                .offset(x: -150, y: -360)
            
            Text("✧")
                .font(.system(size: 36))
                .foregroundColor(Color(red: 0.95, green: 0.67, blue: 0.38).opacity(0.45))
                .offset(x: 145, y: -250)
            
            VStack(spacing: 4) {
                Circle()
                    .fill(Color.orange.opacity(0.25))
                    .frame(width: 3, height: 3)
                
                Circle()
                    .fill(Color.orange.opacity(0.25))
                    .frame(width: 3, height: 3)
            }
            .offset(x: 160, y: -322)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        StreakScreen()
    }
    .modelContainer(for: Goal.self, inMemory: true)
}
