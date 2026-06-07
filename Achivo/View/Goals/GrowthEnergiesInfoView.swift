//
//  GrowthEnergiesInfoView.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 18/05/2026.
//

import SwiftUI

struct GrowthEnergiesInfoView: View {
    
    let onBack: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedEnergy: GrowthEnergy? = .fiery
    
    private let energies = GrowthEnergy.allCases
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            ZStack {
                background(width: width, height: height)
                
                backButton(width: width, height: height)
                
                VStack(spacing: height * 0.026) {
                    header(width: width)
                    
                    VStack(spacing: height * 0.022) {
                        ForEach(energies) { energy in
                            energyCard(
                                energy: energy,
                                width: width,
                                height: height
                            )
                        }
                    }
                    .padding(.top, height * 0.025)
                    
                    Spacer()
                }
                .padding(.horizontal, width * 0.075)
                .padding(.top, height * 0.115)
                
                decorativePlant(width: width, height: height)
            }
        }
    }
}

// MARK: - Colors

private extension GrowthEnergiesInfoView {
    
    var primaryTextColor: Color {
        colorScheme == .dark
        ? Color(red: 1.0, green: 0.97, blue: 0.90)
        : .black
    }
    
    var secondaryTextColor: Color {
        colorScheme == .dark
        ? Color(red: 0.92, green: 0.88, blue: 0.78)
        : Color(red: 0.42, green: 0.42, blue: 0.42)
    }
    
    var cardBackgroundColor: Color {
        colorScheme == .dark
        ? Color(red: 0.22, green: 0.22, blue: 0.19)
        : Color.white.opacity(0.58)
    }
    
    var cardBorderColor: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.32)
        : Color.black.opacity(0.18)
    }
    
    var selectedCardBorderColor: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.45)
        : Color.black.opacity(0.18)
    }
    
    var cardShadowColor: Color {
        colorScheme == .dark
        ? Color.black.opacity(0.30)
        : Color.black.opacity(0.04)
    }
    
    var bodyTextColor: Color {
        colorScheme == .dark
        ? Color(red: 0.95, green: 0.91, blue: 0.82)
        : Color(red: 0.23, green: 0.23, blue: 0.23)
    }
}

// MARK: - UI

private extension GrowthEnergiesInfoView {
    
    func background(width: CGFloat, height: CGFloat) -> some View {
        Image("AppBackground")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
    
    func backButton(width: CGFloat, height: CGFloat) -> some View {
        Button {
            onBack()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: width * 0.052, weight: .medium))
                .foregroundStyle(primaryTextColor)
        }
        .position(x: width * 0.13, y: height * 0.085)
        .accessibilityLabel("Back")
    }
    
    func header(width: CGFloat) -> some View {
        VStack(spacing: 8) {
            (
                Text("Meet your ")
                    .foregroundColor(primaryTextColor)
                +
                Text("growth")
                    .foregroundColor(Color(red: 0.39, green: 0.58, blue: 0.04))
                +
                Text(" energies")
                    .foregroundColor(primaryTextColor)
            )
            .font(.system(size: width * 0.057, weight: .bold))
            .multilineTextAlignment(.center)
            
            Text("Each energy has a unique strength\nChoose the one that fits you, or collect them all!")
                .font(.system(size: width * 0.035, weight: .regular))
                .foregroundStyle(secondaryTextColor)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
    }
    
    func energyCard(
        energy: GrowthEnergy,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        let isSelected = selectedEnergy == energy
        
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                selectedEnergy = isSelected ? nil : energy
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: width * 0.04, style: .continuous)
                    .fill(cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: width * 0.04, style: .continuous)
                            .stroke(
                                isSelected ? energy.color.opacity(0.85) : cardBorderColor,
                                lineWidth: isSelected ? 1.4 : 0.8
                            )
                    )
                    .shadow(
                        color: isSelected ? energy.color.opacity(0.22) : cardShadowColor,
                        radius: isSelected ? 12 : 5,
                        x: 0,
                        y: isSelected ? 6 : 2
                    )
                
                if isSelected {
                    selectedCardContent(
                        energy: energy,
                        width: width,
                        height: height
                    )
                } else {
                    Image(energy.assetName)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: width * characterWidth(for: energy),
                            height: height * 0.13
                        )
                        .accessibilityHidden(true)
                }
            }
            .frame(height: height * 0.145)
            .scaleEffect(isSelected ? 1.015 : 1.0)
        }
        .buttonStyle(.plain)
    }
    
    func selectedCardContent(
        energy: GrowthEnergy,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        HStack(spacing: width * 0.035) {
            VStack(alignment: .leading, spacing: 4) {
                Text(energy.name)
                    .font(.system(size: width * 0.048, weight: .bold))
                    .foregroundStyle(energy.color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(energy.title)
                    .font(.system(size: width * 0.032, weight: .bold))
                    .foregroundStyle(primaryTextColor)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: width * 0.31, alignment: .leading)
            
            Text(infoText(for: energy))
                .font(.system(size: width * 0.026, weight: .semibold))
                .foregroundStyle(bodyTextColor)
                .lineSpacing(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .minimumScaleFactor(0.85)
        }
        .padding(.horizontal, width * 0.052)
    }
    
    func decorativePlant(width: CGFloat, height: CGFloat) -> some View {
        Image("Plant_icon")
            .resizable()
            .scaledToFit()
            .frame(width: width * 0.20)
            .opacity(colorScheme == .dark ? 0.55 : 1)
            .position(x: width * 0.82, y: height * 0.92)
    }
    
    func infoText(for energy: GrowthEnergy) -> String {
        switch energy {
        case .fiery:
            return "Fiery is all about focus and action.\nHelps you push limits and achieve big goals."
        case .greeny:
            return "Greeny helps you stay steady.\nBest for building habits and consistency."
        case .sunny:
            return "Sunny brings positive energy.\nBest for starting fresh and celebrating small wins."
        case .bluey:
            return "Bluey keeps things calm.\nBest for gentle growth and self-care."
        }
    }
    
    func characterWidth(for energy: GrowthEnergy) -> CGFloat {
        switch energy {
        case .fiery:
            return 0.30
        case .greeny:
            return 0.27
        case .sunny:
            return 0.28
        case .bluey:
            return 0.27
        }
    }
}

// MARK: - Preview

#Preview {
    GrowthEnergiesInfoView {}
}
