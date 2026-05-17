//
//  NoGoalsView.swift
//  Achivo
//
//  Created by Asma Khan on 25/11/1447 AH.
//

import SwiftUI

struct NoGoalsView: View {
    
    @Environment(AppRouter.self) private var router
    
    let onBack: () -> Void
    
    @State private var showAddGoalView: Bool = false
    
    var body: some View {
        @Bindable var router = router
        
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            ZStack {
                background(width: width, height: height)
                
                backButton(width: width, height: height)
                
                titleSection(width: width, height: height)
                
                plantImage(width: width, height: height)
                
                startGoalButton(width: width, height: height)
                
                AppBottomNavBar(selectedTab: $router.selectedTab)
                    .position(x: width * 0.50, y: height * 0.94)
            }
        }
        .fullScreenCover(isPresented: $showAddGoalView) {
            AddGoalView()
        }
    }
}

// MARK: - UI

private extension NoGoalsView {
    
    func background(width: CGFloat, height: CGFloat) -> some View {
        Image("onboarding_background")
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .clipped()
            .ignoresSafeArea()
    }
    
    func backButton(width: CGFloat, height: CGFloat) -> some View {
        Button {
            onBack()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: width * 0.052, weight: .medium))
                .foregroundColor(.black)
        }
        .position(x: width * 0.13, y: height * 0.085)
    }
    
    func titleSection(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: height * 0.016) {
            (
                Text("You have no ")
                    .foregroundColor(.black)
                +
                Text("goals")
                    .foregroundColor(Color(red: 0.39, green: 0.58, blue: 0.04))
                +
                Text(" yet")
                    .foregroundColor(.black)
            )
            .font(.system(size: width * 0.06, weight: .bold))
            
            (
                Text("let's ")
                    .foregroundColor(.black)
                +
                Text("grow")
                    .foregroundColor(Color(red: 0.39, green: 0.58, blue: 0.04))
                +
                Text(" together!")
                    .foregroundColor(.black)
            )
            .font(.system(size: width * 0.038, weight: .regular))
        }
        .multilineTextAlignment(.center)
        .position(x: width * 0.50, y: height * 0.36)
    }
    
    func plantImage(width: CGFloat, height: CGFloat) -> some View {
        Image("plant_icon")
            .resizable()
            .scaledToFit()
            .frame(width: width * 0.28, height: height * 0.22)
            .position(x: width * 0.50, y: height * 0.52)
    }
    
    func startGoalButton(width: CGFloat, height: CGFloat) -> some View {
        Button {
            showAddGoalView = true
        } label: {
            HStack(spacing: width * 0.035) {
                Image(systemName: "plus")
                    .font(.system(size: width * 0.045, weight: .bold))
                
                Text("Start your first goal")
                    .font(.system(size: width * 0.04, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(width: width * 0.60, height: height * 0.058)
            .background(
                RoundedRectangle(cornerRadius: width * 0.032)
                    .fill(Color(red: 0.39, green: 0.58, blue: 0.04))
            )
            .shadow(color: .black.opacity(0.22), radius: 10, x: 0, y: 7)
        }
        .position(x: width * 0.50, y: height * 0.72)
    }
}

// MARK: - Preview

#Preview {
    NoGoalsView(onBack: {})
        .environment(AppRouter())
}
