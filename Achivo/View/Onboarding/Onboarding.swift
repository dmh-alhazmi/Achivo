//
//  onboarding.swift
//  Achivo
//
//  Created by Asma Khan on 25/11/1447 AH.
//

import SwiftUI

struct PersonalityOnboardingView: View {
    @State private var currentIndex = 0
    
    let onCreateGoal: () -> Void
    
    private let energies = GrowthEnergy.allCases
    
    private var isLastCharacter: Bool {
        currentIndex == energies.count - 1
    }
    
    var body: some View {
        GeometryReader { geo in
            onboardingContent(geo: geo)
        }
    }
    
    private func onboardingContent(geo: GeometryProxy) -> some View {
        let width = geo.size.width
        let height = geo.size.height
        
        return ZStack {
            Image("onboarding_background")
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipped()
                .ignoresSafeArea()
            
            TabView(selection: $currentIndex) {
                ForEach(Array(energies.enumerated()), id: \.element.id) { index, energy in
                    PersonalityCharacterPage(
                        geo: geo,
                        energy: energy
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            
            VStack(spacing: height * 0.025) {
                pageDots
                
                PrimaryButton(
                    title: "Create Goal",
                    width: width,
                    height: height,
                    isEnabled: isLastCharacter
                ) {
                    onCreateGoal()
                }
            }
            .position(
                x: width * 0.52,
                y: height * 0.84
            )
        }
    }
    
    private var pageDots: some View {
            HStack(spacing: 8) {
                ForEach(energies.indices, id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex ? GrowthEnergy.allCases[currentIndex].color : Color.gray.opacity(0.25))
                        .frame(
                            width: index == currentIndex ? 10 : 7,
                            height: index == currentIndex ? 10 : 7
                        )
                        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: currentIndex)
                }
            }
        }
}

// MARK: - Character Page

struct PersonalityCharacterPage: View {
    let geo: GeometryProxy
    let energy: GrowthEnergy
    
    var body: some View {
        let width = geo.size.width
        let height = geo.size.height
        
        ZStack {
            Image(energy.assetName)
                .resizable()
                .scaledToFit()
                .frame(
                    width: width * energy.imageWidth,
                    height: height * energy.imageHeight
                )
                .position(
                    x: width * energy.imageX,
                    y: height * energy.imageY
                )
            
            VStack(alignment: .leading, spacing: height * 0.015) {
                Text(energy.name)
                    .font(.system(size: width * 0.07, weight: .bold))
                    .foregroundColor(energy.color)
                
                Text(energy.title)
                    .font(.system(size: width * 0.047, weight: .bold))
                    .foregroundColor(.black)
                
                Text("Best for\n\(energy.bestFor)")
                    .font(.system(size: width * 0.04, weight: .regular))
                    .foregroundColor(energy.color)
                    .lineSpacing(4)
                    .frame(
                        width: width * 0.618,
                        height: width * 0.165,
                        alignment: .leading
                    )
                    .padding(.leading, width * 0.045)
                    .background(
                        RoundedRectangle(cornerRadius: width * 0.038)
                            .fill(energy.cardColor)
                    )
                    .padding(.top, height * 0.015)
            }
            .frame(width: width * 0.68, alignment: .leading)
            .position(
                x: width * 0.38,
                y: height * 0.58
            )
        }
    }
}

// MARK: - Primary Button

struct PrimaryButton: View {
    let title: String
    let width: CGFloat
    let height: CGFloat
    var isEnabled: Bool = true
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(isEnabled ? title : "Swipe to continue")
                    .font(.system(size: width * 0.038, weight: .bold, design: .rounded))
                
                Image(systemName: isEnabled ? "arrow.right" : "hand.draw")
                    .font(.system(size: width * 0.034, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(
                width: isEnabled ? width * 0.46 : width * 0.52,
                height: height * 0.056
            )
            .background(buttonBackground)
            .clipShape(Capsule())
            .overlay(buttonBorder)
            .shadow(
                color: isEnabled
                ? Color(red: 0.39, green: 0.58, blue: 0.04).opacity(0.30)
                : .black.opacity(0.06),
                radius: isEnabled ? 18 : 8,
                x: 0,
                y: isEnabled ? 9 : 4
            )
            .scaleEffect(isEnabled ? 1.0 : 0.96)
            .opacity(isEnabled ? 1.0 : 0.72)
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isEnabled)
        }
        .disabled(!isEnabled)
    }
    
    private var buttonBackground: some View {
        ZStack {
            if isEnabled {
                LinearGradient(
                    colors: [
                        Color(red: 0.48, green: 0.68, blue: 0.08),
                        Color(red: 0.32, green: 0.54, blue: 0.04)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                LinearGradient(
                    colors: [
                        Color.gray.opacity(0.46),
                        Color.gray.opacity(0.30)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            
            Circle()
                .fill(Color.white.opacity(isEnabled ? 0.18 : 0.10))
                .frame(width: 54, height: 54)
                .offset(x: -70, y: -16)
        }
    }
    
    private var buttonBorder: some View {
        Capsule()
            .stroke(Color.white.opacity(0.55), lineWidth: 1)
    }
}

// MARK: - Growth Energy UI Helpers

private extension GrowthEnergy {
    
    var cardColor: Color {
        switch self {
        case .bluey:
            return Color(red: 0.94, green: 0.95, blue: 0.97)
        case .greeny:
            return Color(red: 0.91, green: 0.94, blue: 0.78)
        case .sunny:
            return Color(red: 0.98, green: 0.94, blue: 0.83)
        case .fiery:
            return Color(red: 1.00, green: 0.94, blue: 0.87)
        }
    }
    
    var imageWidth: CGFloat {
        switch self {
        case .bluey:
            return 0.38
        case .greeny:
            return 0.39
        case .sunny:
            return 0.45
        case .fiery:
            return 0.38
        }
    }
    
    var imageHeight: CGFloat {
        switch self {
        case .bluey:
            return 0.22
        case .greeny:
            return 0.24
        case .sunny:
            return 0.25
        case .fiery:
            return 0.22
        }
    }
    
    var imageX: CGFloat {
        switch self {
        case .bluey:
            return 0.53
        case .greeny:
            return 0.52
        case .sunny:
            return 0.53
        case .fiery:
            return 0.53
        }
    }
    
    var imageY: CGFloat {
        switch self {
        case .bluey:
            return 0.38
        case .greeny:
            return 0.39
        case .sunny:
            return 0.39
        case .fiery:
            return 0.38
        }
    }
}

// MARK: - Preview

#Preview {
    PersonalityOnboardingView {
        print("Create Goal tapped")
    }
}
