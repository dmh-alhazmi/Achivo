
//
//  onboarding.swift
//  Achivo
//
//  Created by Asma Khan on 25/11/1447 AH.
//

import SwiftUI

struct PersonalityOnboardingView: View {
    @State private var currentIndex = 0
    @State private var showFinalScreen = false
    @State private var showNoGoalsScreen = false
    

    private let screens: [PersonalityScreenData] = [
        PersonalityScreenData(
            imageName: "fiery_icon",
            title: "Fiery",
            subtitle: "The Achiever",
            bestFor: "Best For\ngoals & high performance",
            accentColor: Color(red: 0.94, green: 0.36, blue: 0.11),
            cardColor: Color(red: 1.0, green: 0.94, blue: 0.87),
            imageWidth: 0.38,
            imageHeight: 0.22,
            imageX: 0.53,
            imageY: 0.38,
            contentX: 0.38,
            contentY: 0.58
        ),
        PersonalityScreenData(
            imageName: "bluey_icon",
            title: "Bluey",
            subtitle: "The Calm One",
            bestFor: "Best for\nself-care & well-being",
            accentColor: Color(red: 0.39, green: 0.59, blue: 0.88),
            cardColor: Color(red: 0.94, green: 0.95, blue: 0.97),
            imageWidth: 0.38,
            imageHeight: 0.22,
            imageX: 0.53,
            imageY: 0.38,
            contentX: 0.38,
            contentY: 0.58
        ),
        PersonalityScreenData(
            imageName: "greeny_icon",
            title: "Greeny",
            subtitle: "The Consistent One",
            bestFor: "Best for habits\n&consistency",
            accentColor: Color(red: 0.56, green: 0.72, blue: 0.25),
            cardColor: Color(red: 0.91, green: 0.94, blue: 0.78),
            imageWidth: 0.39,
            imageHeight: 0.24,
            imageX: 0.52,
            imageY: 0.39,
            contentX: 0.38,
            contentY: 0.58
        ),
        PersonalityScreenData(
            imageName: "sunny_icon",
            title: "Sunny",
            subtitle: "The Motivator",
            bestFor: "Best for\nnew beginnings",
            accentColor: Color(red: 0.91, green: 0.70, blue: 0.17),
            cardColor: Color(red: 0.98, green: 0.94, blue: 0.83),
            imageWidth: 0.45,
            imageHeight: 0.25,
            imageX: 0.53,
            imageY: 0.39,
            contentX: 0.38,
            contentY: 0.58
        )
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if showNoGoalsScreen {
                    NoGoalsView(
                        onBack: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showNoGoalsScreen = false
                            }
                        }
                    )
                        .transition(.opacity)
                } else if showFinalScreen {
                    FinalGoalScreen(
                        geo: geo,
                        onCreateGoal: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showNoGoalsScreen = true
                            }
                        }
                    )
                    .transition(.opacity)
                } else {
                    PersonalityScreenView(
                        geo: geo,
                        item: screens[currentIndex],
                        onSkip: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showNoGoalsScreen = true
                            }
                        },
                        onNext: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if currentIndex < screens.count - 1 {
                                    currentIndex += 1
                                } else {
                                    showFinalScreen = true
                                }
                            }
                        }
                    )
                    .transition(.opacity)
                }
            }
        }
    }
}

struct PersonalityScreenView: View {
    let geo: GeometryProxy
    let item: PersonalityScreenData
    let onSkip: () -> Void
    let onNext: () -> Void

    var body: some View {
        let width = geo.size.width
        let height = geo.size.height

        ZStack {
            Image("onboarding_background")
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipped()
                .ignoresSafeArea()

            Button(action: onSkip) {
                Text("Skip")
                    .font(.system(size: width * 0.045, weight: .regular))
                    .foregroundColor(Color(red: 0.50, green: 0.53, blue: 0.58))
            }
            .position(
                x: width * 0.87,
                y: height * 0.09
            )

            Image(item.imageName)
                .resizable()
                .scaledToFit()
                .frame(
                    width: width * item.imageWidth,
                    height: height * item.imageHeight
                )
                .position(
                    x: width * item.imageX,
                    y: height * item.imageY
                )

            VStack(alignment: .leading, spacing: height * 0.015) {
                Text(item.title)
                    .font(.system(size: width * 0.07, weight: .bold))
                    .foregroundColor(item.accentColor)

                Text(item.subtitle)
                    .font(.system(size: width * 0.047, weight: .bold))
                    .foregroundColor(.black)

                Text(item.bestFor)
                    .font(.system(size: width * 0.04, weight: .regular))
                    .foregroundColor(item.accentColor)
                    .lineSpacing(4)
                    .frame(
                        width: width * 0.618,
                        height: width * 0.165,
                        alignment: .leading
                    )
                    .padding(.leading, width * 0.045)
                    .background(
                        RoundedRectangle(cornerRadius: width * 0.038)
                            .fill(item.cardColor)
                    )
                    .padding(.top, height * 0.015)
            }
            .frame(width: width * 0.68, alignment: .leading)
            .position(
                x: width * item.contentX,
                y: height * item.contentY
            )

            PrimaryButton(
                title: "Next",
                width: width,
                height: height,
                action: onNext
            )
            .position(
                x: width * 0.52,
                y: height * 0.85
            )
        }
    }
}

struct FinalGoalScreen: View {
    let geo: GeometryProxy
    let onCreateGoal: () -> Void
    var body: some View {
        let width = geo.size.width
        let height = geo.size.height

        ZStack {
            Image("onboarding_background")
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipped()
                .ignoresSafeArea()
                .background()

            // Bluey
            Image("bluey_icon")
                .resizable()
                .scaledToFit()
                .frame(
                    width: width * 0.27,
                    height: height * 0.14
                )
                .position(
                    x: width * 0.20,
                    y: height * 0.38
                )

            // Greeny
            Image("greeny_icon")
                .resizable()
                .scaledToFit()
                .frame(
                    width: width * 0.31,
                    height: height * 0.18
                )
                .position(
                    x: width * 0.36,
                    y: height * 0.33
                )

            // Sunny
            Image("sunny_icon")
                .resizable()
                .scaledToFit()
                .frame(
                    width: width * 0.27,
                    height: height * 0.16
                )
                .position(
                    x: width * 0.55,
                    y: height * 0.39
                )

            // Fiery
            Image("mewo")
                .resizable()
                .scaledToFit()
                .frame(
                    width: width * 0.31,
                    height: height * 0.18
                )
                .position(
                    x: width * 0.78,
                    y: height * 0.36
                )

            VStack(spacing: height * 0.025) {
                VStack(spacing: height * 0.004) {
                    Text("Let’s grow")
                        .font(.system(size: width * 0.065, weight: .bold))
                        .foregroundColor(Color(red: 0.47, green: 0.63, blue: 0.27))

                    Text("toghether")
                        .font(.system(size: width * 0.065, weight: .bold))
                        .foregroundColor(Color(red: 0.12, green: 0.15, blue: 0.20))
                }

                Text("Small steps today,\nbig change tomorrow")
                    .font(.system(size: width * 0.045, weight: .bold))
                    .foregroundColor(Color(red: 0.46, green: 0.46, blue: 0.46))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .position(
                x: width * 0.50,
                y: height * 0.59
            )

            PrimaryButton(
                title: "Create Goal",
                width: width,
                height: height,
                action: onCreateGoal
            )
            .position(
                x: width * 0.52,
                y: height * 0.85
            )
        }
    }
}

struct PrimaryButton: View {
    let title: String
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: width * 0.038, weight: .bold))
                .foregroundColor(.white)
                .frame(
                    width: title == "Create Goal" ? width * 0.39 : width * 0.36,
                    height: height * 0.047
                )
                .background(
                    RoundedRectangle(cornerRadius: width * 0.03)
                        .fill(Color(red: 0.39, green: 0.58, blue: 0.04))
                )
                .shadow(
                    color: .black.opacity(0.18),
                    radius: 12,
                    x: 0,
                    y: 8
                )
        }
    }
}

struct PersonalityScreenData {
    let imageName: String
    let title: String
    let subtitle: String
    let bestFor: String
    let accentColor: Color
    let cardColor: Color
    let imageWidth: CGFloat
    let imageHeight: CGFloat
    let imageX: CGFloat
    let imageY: CGFloat
    let contentX: CGFloat
    let contentY: CGFloat
}

#Preview {
    PersonalityOnboardingView()
}
