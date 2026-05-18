//
//  StreakScreen.swift
//  Achivo
//
//  Created by Asma Khan on 30/11/1447 AH.
//
import SwiftUI

struct StreakScreen: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var streakCount: Int = 1
    @State private var selectedMonth: String = "January 2025"
    @State private var selectedDay: Int = 26
    @State private var showInfo: Bool = false
    
    private let months: [JourneyMonth] = [
        JourneyMonth(title: "January 2025", activeDays: Array(1...26), selectedDay: 26),
        JourneyMonth(title: "September 2025", activeDays: Array(1...26), selectedDay: nil),
        JourneyMonth(title: "October 2025", activeDays: Array(1...26), selectedDay: 26),
        JourneyMonth(title: "November 2025", activeDays: [6, 7, 12, 13], selectedDay: nil),
        JourneyMonth(title: "December 2025", activeDays: [1, 2, 3, 4, 5, 8, 9], selectedDay: nil)
    ]
    
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
                        VStack(spacing: 22) {
                            ForEach(months) { month in
                                MonthCalendarView(month: month) { day in
                                    selectedMonth = month.title
                                    selectedDay = day
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
        .alert("Streak Info", isPresented: $showInfo) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your current streak is Day \(streakCount). Selected date is \(selectedDay) \(selectedMonth).")
        }
    }
    
    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black)
                    .frame(width: 36, height: 36)
            }
            
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
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.97, blue: 0.92),
                Color(red: 0.98, green: 0.90, blue: 0.80)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .overlay {
            DecorativeBackground()
        }
    }
}

struct JourneyMonth: Identifiable {
    let id = UUID()
    let title: String
    let activeDays: [Int]
    let selectedDay: Int?
}

struct MonthCalendarView: View {
    let month: JourneyMonth
    let onDayTap: (Int) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    private let weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    private let days = Array(1...30)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(month.title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.black)
                .padding(.leading, 5)
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(.white)
                }
                
                ForEach(days, id: \.self) { day in
                    Button {
                        onDayTap(day)
                    } label: {
                        Text("\(day)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(textColor(for: day))
                            .frame(width: 28, height: 28)
                            .background(background(for: day))
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Rectangle()
                .fill(Color.black.opacity(0.25))
                .frame(height: 1)
                .padding(.horizontal, 5)
                .padding(.top, 2)
        }
    }
    
    private func background(for day: Int) -> some View {
        Group {
            if month.selectedDay == day {
                Circle()
                    .fill(Color(red: 0.42, green: 0.62, blue: 0.13))
            } else if month.activeDays.contains(day) {
                Circle()
                    .fill(Color(red: 0.78, green: 0.84, blue: 0.45))
            } else {
                Circle()
                    .fill(Color.clear)
            }
        }
    }
    
    private func textColor(for day: Int) -> Color {
        if month.selectedDay == day {
            return .white
        }
        
        if month.activeDays.contains(day) {
            return Color(red: 0.42, green: 0.62, blue: 0.13)
        }
        
        return .white.opacity(0.95)
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
}
