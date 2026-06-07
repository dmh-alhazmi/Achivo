//
//  GrowthEnergyMiniCard.swift
//  Achivo
//
//  Created by Deemah Alhazmi on 14/05/2026.
//

import SwiftUI

struct GrowthEnergyMiniCard: View {
    
    let energy: GrowthEnergy
    let isSelected: Bool
    let action: () -> Void
    let infoAction: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    @ScaledMetric(relativeTo: .body) private var imageHeight: CGFloat = 68
    @ScaledMetric(relativeTo: .body) private var cardMinHeight: CGFloat = 190
    @ScaledMetric(relativeTo: .body) private var cornerRadius: CGFloat = 18
    
    private var strokeColor: Color {
        isSelected ? energy.color : borderColor
    }
    
    private var strokeWidth: CGFloat {
        isSelected ? 2.4 : 1
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.10)
        : Color.white.opacity(0.82)
    }
    
    private var titleColor: Color {
        colorScheme == .dark
        ? Color(red: 1.0, green: 0.96, blue: 0.88)
        : .black
    }
    
    private var borderColor: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.22)
        : Color.black.opacity(0.22)
    }
    
    private var infoCircleBackground: Color {
        colorScheme == .dark
        ? Color.black.opacity(0.35)
        : .white
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                imageArea
                
                Text(energy.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(energy.color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(energy.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(titleColor)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .frame(minHeight: cardMinHeight, alignment: .top)
            .background(cardBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(strokeColor, lineWidth: strokeWidth)
            )
            .shadow(
                color: colorScheme == .dark
                ? .black.opacity(0.25)
                : .black.opacity(0.10),
                radius: 6,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(.plain)
    }
    
    private var imageArea: some View {
        ZStack(alignment: .topTrailing) {
            Image(energy.assetName)
                .resizable()
                .scaledToFit()
                .frame(height: imageHeight)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
            
            Button {
                infoAction()
            } label: {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(energy.color)
                    .background(
                        Circle()
                            .fill(infoCircleBackground)
                    )
                    .accessibilityLabel("More information about \(energy.name)")
            }
            .buttonStyle(.plain)
        }
        .frame(minHeight: imageHeight + 4)
    }
}

#Preview {
    GrowthEnergyMiniCard(
        energy: .bluey,
        isSelected: true
    ) {
        
    } infoAction: {
        
    }
    .padding()
    .background(Color("background"))
}
