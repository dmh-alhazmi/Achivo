
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
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: date) else { break }
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
                    .foregroundColor(.gray)
                    .padding(.top, 30)
                
                streakCircle
                    .padding(.top, 36)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Journey")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    
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
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.98, green: 0.90, blue: 0.80).opacity(0.85))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.9), lineWidth: 1)
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
    
    
    private var header: some View {
        HStack {

            Spacer()

            Text("Streak")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)

            Spacer()

            Button {
                showInfo = true
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                    .frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 25)
    }
    
    private var streakCircle: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.98, green: 0.90, blue: 0.80))
                .frame(width: 150, height: 150)
                .shadow(color: .black.opacity(0.22), radius: 5, x: 0, y: 3)
            
            HStack(spacing: 5) {
                Text("Day")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.gray)
                
                Text("\(streakCount)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 0.42, green: 0.62, blue: 0.13))
                
                Text("🔥")
                    .font(.system(size: 17))
            }
        }
    }
    
    
    private var background: some View {
        Image("AppBackground")
            .resizable()
            //.scaledToFill()
            .ignoresSafeArea()
    }
    
    private func setupMonths() {
        guard months.isEmpty else { return }
        
        let currentMonth = calendar.date(
            from: calendar.dateComponents([.year, .month], from: Date())
        ) ?? Date()
        
        months = (0...12).compactMap {
            calendar.date(byAdding: .month, value: $0, to: currentMonth)
        }
    }
    
    private func loadMoreIfNeeded(_ month: Date) {
        guard month == months.last else { return }
        guard let last = months.last else { return }
        
        let moreMonths = (1...12).compactMap {
            calendar.date(byAdding: .month, value: $0, to: last)
        }
        
        months.append(contentsOf: moreMonths)
    }
}

struct MonthCalendarView: View {
    let monthDate: Date
    let completedDates: Set<Date>
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    private let weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: monthDate)
    }
    
    private var days: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: monthDate),
              let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate)) else {
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
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.black)
                .padding(.leading, 5)
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(.black)
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
                .fill(Color.black.opacity(0.25))
                .frame(height: 1)
                .padding(.horizontal, 5)
                .padding(.top, 2)
        }
    }
    
    private func dayView(_ date: Date) -> some View {
        let day = calendar.component(.day, from: date)
        let isCompleted = completedDates.contains(calendar.startOfDay(for: date))
        let isToday = calendar.isDateInToday(date)
        
        return Text("\(day)")
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(isCompleted ? .white : .white.opacity(0.95))
            .frame(width: 28, height: 28)
            .background(
                Circle()
                    .fill(
                        isCompleted
                        ? Color(red: 0.42, green: 0.62, blue: 0.13)
                        : isToday
                        ? Color(red: 0.78, green: 0.84, blue: 0.45)
                        : Color.clear
                    )
            )
    }
}

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

#Preview {
    NavigationStack {
        StreakScreen()
    }
    .modelContainer(for: Goal.self, inMemory: true)
}
