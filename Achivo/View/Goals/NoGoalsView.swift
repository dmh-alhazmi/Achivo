//
//  NoGoalsView.swift
//  Achivo
//
//  Created by Asma Khan on 25/11/1447 AH.
//

import SwiftUI

struct NoGoalsView: View {
    @State private var selectedTab: BottomTab = .goal
    let onBack: () -> Void

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            ZStack {
                Image("onboarding_background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipped()
                    .ignoresSafeArea()

                Button(action: {
                    onBack()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: width * 0.052, weight: .medium))
                        .foregroundColor(.black)
                }
                .position(x: width * 0.13, y: height * 0.085)

                VStack(spacing: height * 0.016) {
                    Text("You have no ")
                        .font(.system(size: width * 0.06, weight: .bold))
                        .foregroundColor(.black)
                    +
                    Text("goals")
                        .font(.system(size: width * 0.06, weight: .bold))
                        .foregroundColor(Color(red: 0.39, green: 0.58, blue: 0.04))
                    +
                    Text(" yet")
                        .font(.system(size: width * 0.06, weight: .bold))
                        .foregroundColor(.black)

                    Text("let's ")
                        .font(.system(size: width * 0.038, weight: .regular))
                        .foregroundColor(.black)
                    +
                    Text("grow")
                        .font(.system(size: width * 0.038, weight: .regular))
                        .foregroundColor(Color(red: 0.39, green: 0.58, blue: 0.04))
                    +
                    Text(" together!")
                        .font(.system(size: width * 0.038, weight: .regular))
                        .foregroundColor(.black)
                }
                .multilineTextAlignment(.center)
                .position(x: width * 0.50, y: height * 0.36)

                Image("plant_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 0.28, height: height * 0.22)
                    .position(x: width * 0.50, y: height * 0.52)

                Button(action: {
                    // open create goal form
                }) {
                    HStack(spacing: width * 0.045) {
                        Image("plus_icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: width * 0.085, height: width * 0.085)

                        Text("Start your first goal")
                            .font(.system(size: width * 0.04, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(width: width * 0.56, height: height * 0.058)
                    .padding(.horizontal, width * 0.035)
                    .background(
                        RoundedRectangle(cornerRadius: width * 0.032)
                            .fill(Color(red: 0.39, green: 0.58, blue: 0.04))
                    )
                    .shadow(color: .black.opacity(0.22), radius: 10, x: 0, y: 7)
                }
                .position(x: width * 0.50, y: height * 0.72)

                AppBottomNavBar(selectedTab: $selectedTab)
                    .position(x: width * 0.50, y: height * 0.94)
            }
        }
    }
}

#Preview {
    NoGoalsView(onBack: {})
}
