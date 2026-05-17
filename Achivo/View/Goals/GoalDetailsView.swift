//
//  GoalDetailsView.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 17/05/2026.
//

import SwiftUI
import SwiftData

struct GoalDetailsView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    let goal: Goal
    
    private var energy: GrowthEnergy {
        goal.selectedEnergy
    }
    
    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    characterHeader
                    goalInfoCard
                    progressCard
                    boostButton
                }
                .padding(.horizontal, 22)
                .padding(.top, 24)
                .padding(.bottom, 60)
            }
        }
        .navigationTitle("Goal Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - UI

private extension GoalDetailsView {
    
    var characterHeader: some View {
        VStack(spacing: 8) {
            Image(energy.assetName)
                .resizable()
                .scaledToFit()
                .frame(height: 120)
            
            Text(energy.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(energy.color)
            
            Text(energy.title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    var goalInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            infoRow(title: "Main goal", value: goal.title)
            infoRow(title: "Daily task", value: goal.subGoal)
            infoRow(title: "Duration", value: "\(goal.durationDays) days")
            infoRow(title: "Remaining", value: "\(goal.remainingDays) days")
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
    var progressCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Progress")
                .font(.headline)
                .fontWeight(.bold)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.16))
                    
                    Capsule()
                        .fill(energy.color)
                        .frame(width: geometry.size.width * goal.progress)
                }
            }
            .frame(height: 12)
            
            Text("\(goal.completedDays) of \(goal.durationDays) days completed")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(Color.white.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
    var boostButton: some View {
        Button {
            boostOneDay()
        } label: {
            VStack(spacing: 4) {
                Text("Boost +1 Day")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("Use it when you did extra today")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                Capsule()
                    .fill(goal.isFinished ? Color.gray : energy.color)
            )
        }
        .disabled(goal.isFinished)
    }
    
    func infoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.headline)
                .foregroundStyle(.black)
        }
    }
}

// MARK: - Logic

private extension GoalDetailsView {
    
    func boostOneDay() {
        guard !goal.isFinished else { return }
        
        goal.completedDays = min(goal.completedDays + 1, goal.durationDays)
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to boost goal:", error.localizedDescription)
        }
    }
}

#Preview {
    NavigationStack {
        GoalDetailsView(
            goal: Goal(
                title: "Read more books",
                subGoal: "Read 10 pages",
                durationDays: 10,
                selectedEnergy: .bluey,
                completedDays: 6
            )
        )
    }
    .modelContainer(for: Goal.self, inMemory: true)
}
